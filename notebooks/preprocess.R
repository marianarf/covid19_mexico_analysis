# Process raw daily report data.

# https://stackoverflow.com/questions/38025866/find-difference-between-dates-in-consecutive-rows
# https://stackoverflow.com/questions/41194878/how-to-delete-duplicates-from-groups-in-r-where-group-is-formed-by-three-columns
# https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://stackoverflow.com/questions/8161836/how-do-i-replace-na-values-with-zeros-in-an-r-dataframe
# https://stackoverflow.com/questions/15641924/remove-all-duplicates-except-last-instance

options(scipen = 999)

library(tidyverse)
library(magrittr)
library(hablar)

# Read multiple files
data_filenames <- list.files(path = '../data/dge', pattern = '*.csv')
data_path <- as.character('../data/dge/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(
  data_files,
  read.csv,
  header=TRUE,
  stringsAsFactors=TRUE,
  encoding = 'latin-ascii') # contains both utf-8 / latin-1

# Factor
filename <- as.factor(c(data_filenames))

# Bind list of data frames
filename <- as.Date(filename, '%y%m%d') # set filename date format
dat <- mapply(cbind, data, 'FECHA_ARCHIVO'=filename, SIMPLIFY=F) # set previous column before bind
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE)  %>% # bind list of data frames
  select(FECHA_ARCHIVO, ID_REGISTRO, 
         FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF,
         ENTIDAD_UM, ENTIDAD_RES, MUNICIPIO_RES,
         PAIS_ORIGEN,
         RESULTADO) %>%
  mutate(id = row_number()) %>% # add id in case needed for future joins
  arrange(ID_REGISTRO, FECHA_INGRESO)

# test <- dat %>%
#mutate_all(funs(str_replace(., 'Á', 'A'))) %>% # search all data frame 
#mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, 'Á', 'A'), regex=TRUE) # wat

# Problem:
# There exists a lag between not only lab tests, but also the date when daily report reflects these results.
# Solution:
# 1) Keep only distinct patient records
# 2) Find distinct patient reconds with different results, ie TRUE for delays and FALSE for same day hospitalization and confirmation
# 3) Find duplicates between patient records, ie if confirmation was delayed, there should be two rows
# 4) Find difference in days in date of report between consecutive patient records
# 5) Keep only last ocurrence of value, so we should have only distinct patient records and their lab tests delay date as shown in daily reports

tmp.x <- dat %>% 
  filter(!grepl('2', RESULTADO)) %>% # remove negative test results before finding distinct
  distinct(ID_REGISTRO, RESULTADO, .keep_all=TRUE) %>% # find distinct, and keep all cols
  group_by(ID_REGISTRO) %>% # prepare to find duplicates
  mutate(dup = n()>1) %>% # find duplicates between patient records, ie for each 2 rows for each patient record = TRUE
  group_by(ID_REGISTRO) %>% # prepare for lag calculation
  mutate(diffDate=difftime(FECHA_ARCHIVO, lag(FECHA_ARCHIVO,1), units='days')) %>% # find difference in days between consecutive patiend records
  ungroup() %>% # go back to original structure
  mutate(diffDate=str_replace(diffDate, 'NA days', 'NA')) %>% # remove string output
  mutate(diffDate=str_replace(diffDate, ' days', '')) %>% # here as well
  mutate(diffDate=as.numeric(diffDate)) %>% # convert to numeric
  mutate(diffDate = if_na(diffDate, 0)) %>% # replace NA with package 'hablar'
  as.data.frame() # no tibble here
tmp.x <- tmp.x[!rev(duplicated(rev(tmp.x$ID_REGISTRO))), ] # filter out all but the last unique occurrences of value

tmp.y <- dat %>% 
  filter(!grepl('1', RESULTADO)) %>% # remove positive test results before finding distinct
  distinct(ID_REGISTRO, RESULTADO, .keep_all=TRUE) %>% # find distinct, and keep all cols
  group_by(ID_REGISTRO) %>% # prepare to find duplicates
  mutate(dup = n()>1) %>% # find duplicates between patient records, ie for each 2 rows for each patient record = TRUE
  group_by(ID_REGISTRO) %>% # prepare for lag calculation
  mutate(diffDate=difftime(FECHA_ARCHIVO, lag(FECHA_ARCHIVO,1), units='days')) %>% # find difference in days between consecutive patiend records
  ungroup() %>% # go back to original structure
  mutate(diffDate=str_replace(diffDate, 'NA days', 'NA')) %>% # remove string output
  mutate(diffDate=str_replace(diffDate, ' days', '')) %>% # here as well
  mutate(diffDate=as.numeric(diffDate)) %>% # convert to numeric
  mutate(diffDate = if_na(diffDate, 0)) %>% # replace NA with package hablar
  as.data.frame() # no tibble here
tmp.y <- tmp.y[!rev(duplicated(rev(tmp.y$ID_REGISTRO))), ] # filter out all but the last unique occurrences of value

tmp <- bind_rows(tmp.x, tmp.y) %>%
  mutate(diffDate = abs(diffDate)) # convert to absolute values (some date were not properly sorted)

# Fix regions
df.x <- tmp %>%
  mutate(FECHA_ARCHIVO=as.Date(FECHA_ARCHIVO, format='%Y-%m-%d')) %>%
  filter(FECHA_ARCHIVO>'2020-01-01' & FECHA_ARCHIVO<='2020-04-20') %>% # for these dates
  rename(ENTIDAD_REGISTRO=ENTIDAD_UM) # assign medical unit region to cases
df.y <- tmp %>%
  mutate(FECHA_ARCHIVO=as.Date(FECHA_ARCHIVO, format='%Y-%m-%d')) %>%
  filter(FECHA_ARCHIVO>'2020-04-20' & FECHA_ARCHIVO<='2022-12-31') %>% # after these dates
  rename(ENTIDAD_REGISTRO=ENTIDAD_RES) # assign region of residence to cases

# Geo names and ids
ent <- read_csv('../data/geo/entidades.csv') %>%
  rename(NOM_ENT=ENTIDAD_FEDERATIVA) %>%
  rename(ABR_ENT=ABREVIATURA) %>%
  rename(ENTIDAD_REGISTRO=CLAVE_ENTIDAD) %>% # change names to match df cols
  mutate(ENTIDAD_REGISTRO=as.numeric(ENTIDAD_REGISTRO)) %>%
  as.data.frame()

# Raw time series containing only positive cases to date
df <- bind_rows(df.x, df.y) %>% # bind region dataframes
  left_join(., ent) %>% # add geo data
  rename(FECHA_DEFUNCION=FECHA_DEF) %>% # rename
  rename(ENTIDAD_RESIDENCIA=ENTIDAD_RES) %>%
  rename(ENTIDAD_MEDICA=ENTIDAD_UM) %>%
  rename(MUNICIPIO_RESIDENCIA=MUNICIPIO_RES) %>%
  rename(ENTIDAD=NOM_ENT) %>%
  rename(OFFSET=diffDate) %>%
  select(FECHA_ARCHIVO, ID_REGISTRO,
         FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEFUNCION,
         ENTIDAD, ENTIDAD_REGISTRO, ENTIDAD_MEDICA, ENTIDAD_RESIDENCIA, MUNICIPIO_RESIDENCIA,
         PAIS_ORIGEN, RESULTADO, OFFSET) %>% # select relevant data
  mutate(ENTIDAD=stringi::stri_trans_general(str=ENTIDAD, id='Latin-ASCII')) %>% # remove accents
  arrange(FECHA_ARCHIVO, ID_REGISTRO)

# df %>%filter(grepl('1', RESULTADO)) # check nrow and offset is correct

write.csv(df, '../latest_raw.csv')

# Nowcasts

nowcasts <- df %>%
  select(PAIS_ORIGEN, FECHA_SINTOMAS, FECHA_ARCHIVO, OFFSET, ENTIDAD, # params
         FECHA_DEFUNCION, ENTIDAD_REGISTRO, RESULTADO) %>% # filters
  rename(import_status=PAIS_ORIGEN) %>%
  rename(date_onset=FECHA_SINTOMAS) %>%
  rename(date_confirm=FECHA_ARCHIVO) %>%
  rename(report_delay=OFFSET) %>%
  rename(region=ENTIDAD) %>%
  filter(grepl('1', RESULTADO)) %>% # keep only positive cases
  mutate(import_status=str_replace(import_status, '99', 'Local')) %>% # assume these are local
  mutate(import_status=str_replace(import_status, '98', 'Local')) %>% # match case in original data (ie 'Local' not 'local')
  mutate(import_status=str_replace(import_status, '97', 'Local')) %>%
  filter(!grepl('9999-99-99', FECHA_DEFUNCION)) %>% # these don't count as active cases
  filter(!grepl('99', ENTIDAD_REGISTRO)) %>% # don't use these
  filter(!grepl('98', ENTIDAD_REGISTRO)) %>%
  filter(!grepl('97', ENTIDAD_REGISTRO))

# `import_status`, `date`, region`, cases`
cases <- nowcasts %>%
  select(import_status, date_confirm, region) %>%
  rename(date=date_confirm) %>%
  mutate(import_status = ifelse(import_status == 'Local' , 'local', 'imported')) %>% # use nowcasts values
  group_by(region, date, import_status, date) %>%
  summarize(cases = n())

write.csv(cases, '../latest_cases.csv')

# `import_status` (values 'local' and 'imported'), `date_onset`, `date_confirm`, `report_delay`, and `region`
linelist <- nowcasts %>%
  select(import_status, date_onset, date_confirm, report_delay, region) %>%
  mutate(import_status = ifelse(import_status == 'Local' , 'local', 'imported')) # use nowcasts values

write.csv(linelist, '../latest_linelist.csv')
