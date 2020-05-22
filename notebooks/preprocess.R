# Process raw daily report data.

options(scipen = 999)

library(tidyverse)
library(magrittr)
library(hablar)
library(data.table)

# FUNCTIONS

readFiles <- function(path) {
  
  # Reads report data and adds filename to new column
  
  data_filenames <- list.files(path = paste0(path), pattern='*.csv')
  data_path <- as.character(paste0(path, '/', collapse=''))
  data_files <- paste(data_path, data_filenames, sep='')
  print('Reading data...')
  data <- lapply(data_files, fread, stringsAsFactors=TRUE, encoding='Latin-1')
  filename_col <- as.factor(c(data_filenames))
  filename_col <- as.Date(filename_col, '%y%m%d')
  print('Binding data frames...')
  tmp_df <- mapply(cbind, data, 'FECHA_ARCHIVO'=filename_col, SIMPLIFY=F)
  df <- data.table::rbindlist(l=tmp_df, use.names = TRUE, fill=TRUE)
  print('Done.')
  return(df)
}

uniqueRecords <- function(df, status) {
  
  # Finds delay in lat test processing results
  
  df <- df %>%
    filter(grepl(status, RESULTADO)) %>%
    distinct(ID_REGISTRO, RESULTADO, .keep_all=TRUE) %>%
    group_by(ID_REGISTRO) %>% mutate(dup=n()>1) %>%
    group_by(ID_REGISTRO) %>% mutate(DELAY=difftime(FECHA_ARCHIVO, lag(FECHA_ARCHIVO,1), units='days')) %>% ungroup() %>%
    mutate(DELAY=str_replace(DELAY, 'NA days', 'NA')) %>% mutate(DELAY=str_replace(DELAY, ' days', '')) %>%
    mutate(DELAY=as.numeric(DELAY)) %>% mutate(DELAY=if_na(DELAY, 0)) %>%
    mutate(DELAY = abs(DELAY))
  # get last unique occurrence
  df <- df[!rev(duplicated(rev(df$ID_REGISTRO))), ]
  return(df)
}

fixRegions <- function(data) {
  
  # Fixes inconsistent report regions as specified in README
  
  data <- data %>% mutate(FECHA_ARCHIVO=as.Date(FECHA_ARCHIVO, format='%Y-%m-%d'))
  data_1 <- data %>% filter(FECHA_ARCHIVO>'2020-01-01' & FECHA_ARCHIVO<='2020-04-20') %>% mutate(ENTIDAD_REGISTRO=ENTIDAD_UM)
  data_2 <- data %>% filter(FECHA_ARCHIVO>'2020-04-20' & FECHA_ARCHIVO<='2022-12-31') %>% mutate(ENTIDAD_REGISTRO=ENTIDAD_RES)
  clean_data <- bind_rows(data_1, data_2)
  return(clean_data)
}

# DATA

# Separate two dfs (one with all data and other with features to fix) to make process faster
raw_data_df <- readFiles('../data/dge') %>% mutate(id = row_number()) %>% arrange(FECHA_ARCHIVO, ID_REGISTRO) %>% select(id, everything())
params_df <- raw_data_df %>% select(c(id, FECHA_ARCHIVO, ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, RESULTADO))

# DELAYS

# To find the delay in time for lab tests results
# 1) Keep only distinct patient records since new reports are concatenated.
# 2) Check if there are updates in records (delays are TRUE, same-day confirmation are FALSE).
# 3) Find difference in days for duplicate records (for each patient) and keep only last occurrence.

# This could be done once with an if/else condition on the date
unique_positives <- uniqueRecords(params_df, '1') 
unique_negatives <- uniqueRecords(params_df, '2')

# Get unique values
uniques <- fixRegions(bind_rows(unique_positives, unique_negatives))

# ADD GEO ATTRIBUTES

# Get official geo attributes and rename cols to match current data
geo_data <- fread('../data/geo/entidades.csv')
geo_data <- geo_data %>% rename(., NOM_ENT=ENTIDAD_FEDERATIVA, ABR_ENT=ABREVIATURA, ENTIDAD_REGISTRO=CLAVE_ENTIDAD)
geo_data <- geo_data %>% mutate(ENTIDAD_REGISTRO=as.numeric(ENTIDAD_REGISTRO))

# CLEAN UP
  
# Final clean up, conserving official structure as closely as possible and with all vars
final_data <- left_join(uniques, geo_data) %>%
  select(-c(dup)) %>%
  rename(ENTIDAD=NOM_ENT) %>%
  mutate(ENTIDAD=stringi::stri_trans_general(str=ENTIDAD, id='Latin-ASCII')) %>%
  arrange(FECHA_ARCHIVO, ID_REGISTRO) %>%
  left_join(., raw_data_df)
#final_data %>%filter(grepl('1', RESULTADO)) # check nrow and delay is correct

# OUTPUT DATA
write.csv(final_data, '../latest_raw.csv', row.names=FALSE, fileEncoding='UTF-8')
