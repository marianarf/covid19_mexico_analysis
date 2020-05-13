# Process raw daily report data.

options(scipen = 999)

library(tidyverse)
library(magrittr)
library(hablar)

# Read multiple files
data_filenames <- list.files(path = '../data/dge', pattern = '*.csv')
data_path <- as.character('../data/dge/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(data_files, read.csv, header=TRUE, stringsAsFactors=TRUE, encoding = 'latin-ascii') # contains both utf-8 / latin-1

# Bind list of data frames
filename <- as.factor(c(data_filenames))
filename <- as.Date(filename, '%y%m%d') # set filename date format
dat <- mapply(cbind, data, 'FECHA_ARCHIVO'=filename, SIMPLIFY=F) # set previous column before bind
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE)  %>% # bind list of data frames
  mutate(id = row_number()) %>% # add id in case needed for future joins
  arrange(FECHA_ARCHIVO, ID_REGISTRO)

# Keep smaller df with ids to keep things running faster
ids <- dat
var <- dat %>% select(c(id, FECHA_ARCHIVO, ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, RESULTADO))

# test <- dat %>%
#mutate_all(funs(str_replace(., 'Á', 'A'))) %>% # search all data frame 
#mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, 'Á', 'A'), regex=TRUE) # wat

# We need to find the delay in time for lab tests results:
# 1) Keep only distinct patient records
# 2) Find distinct patient reconds with updated results, ie TRUE for delays and FALSE for same-day lab confirmation
# 3) Find duplicates between patient records, ie if confirmation was delayed, there should be two rows
# 4) Find difference in days in date of report between consecutive patient records
# 5) Keep only last ocurrence of value, as patient records and their lab tests delay in days

# Separate into positive and negative lab results

  # Only positive lab results
tmp.x <- var %>% 
  filter(!grepl('2', RESULTADO)) %>%
  # find distinct, and keep all cols
  distinct(ID_REGISTRO, RESULTADO, .keep_all=TRUE) %>%
  group_by(ID_REGISTRO) %>%
  # find duplicates between patient records, ie for each 2 rows for each patient record = TRUE
  mutate(dup = n()>1) %>%
  group_by(ID_REGISTRO) %>%
  # find difference in days between consecutive patiend records
  mutate(diffDate=difftime(FECHA_ARCHIVO, lag(FECHA_ARCHIVO,1), units='days')) %>%
  ungroup() %>%
  mutate(diffDate=str_replace(diffDate, 'NA days', 'NA')) %>%
  mutate(diffDate=str_replace(diffDate, ' days', '')) %>%
  mutate(diffDate=as.numeric(diffDate)) %>%
  mutate(diffDate = if_na(diffDate, 0)) %>%
  as.data.frame()
tmp.x <- tmp.x[!rev(duplicated(rev(tmp.x$ID_REGISTRO))), ] # get last unique occurrence

  # Only negative lab results
tmp.y <- var %>% 
  filter(!grepl('1', RESULTADO)) %>%
  # find distinct, and keep all cols
  distinct(ID_REGISTRO, RESULTADO, .keep_all=TRUE) %>%
  group_by(ID_REGISTRO) %>%
  # find duplicates between patient records, ie for each 2 rows for each patient record = TRUE
  mutate(dup = n()>1) %>%
  group_by(ID_REGISTRO) %>%
  # find difference in days between consecutive patiend records
  mutate(diffDate=difftime(FECHA_ARCHIVO, lag(FECHA_ARCHIVO,1), units='days')) %>%
  ungroup() %>%
  mutate(diffDate=str_replace(diffDate, 'NA days', 'NA')) %>%
  mutate(diffDate=str_replace(diffDate, ' days', '')) %>%
  mutate(diffDate=as.numeric(diffDate)) %>%
  mutate(diffDate = if_na(diffDate, 0)) %>%
  as.data.frame()
tmp.y <- tmp.y[!rev(duplicated(rev(tmp.y$ID_REGISTRO))), ] # get last unique occurrence

# Bind both dfs
tmp <- bind_rows(tmp.x, tmp.y) %>%
  mutate(diffDate = abs(diffDate)) # convert to absolute values (some date were not properly sorted)

# Fix regions

  # Assign medical unit region to these cases
df.x <- tmp %>%
  mutate(FECHA_ARCHIVO=as.Date(FECHA_ARCHIVO, format='%Y-%m-%d')) %>%
  filter(FECHA_ARCHIVO>'2020-01-01' & FECHA_ARCHIVO<='2020-04-20') %>%
  rename(ENTIDAD_REGISTRO=ENTIDAD_UM)

  # Assign region of residence to these cases
df.y <- tmp %>%
  mutate(FECHA_ARCHIVO=as.Date(FECHA_ARCHIVO, format='%Y-%m-%d')) %>%
  filter(FECHA_ARCHIVO>'2020-04-20' & FECHA_ARCHIVO<='2022-12-31') %>%
  rename(ENTIDAD_REGISTRO=ENTIDAD_RES) 

# Geostat
ent <- read_csv('../data/geo/entidades.csv') %>%
  rename(NOM_ENT=ENTIDAD_FEDERATIVA) %>%
  rename(ABR_ENT=ABREVIATURA) %>%
  rename(ENTIDAD_REGISTRO=CLAVE_ENTIDAD) %>% # change names to match df cols
  mutate(ENTIDAD_REGISTRO=as.numeric(ENTIDAD_REGISTRO)) %>%
  as.data.frame()

# Clean time series conserving official structure
df <- bind_rows(df.x, df.y) %>% # bind region dataframes
  left_join(., ent) %>% # add geostat data
  rename(ENTIDAD=NOM_ENT) %>%
  rename(DELAY=diffDate) %>%
  select(-c(dup, ENTIDAD_RES, ENTIDAD_UM)) %>%
  mutate(ENTIDAD=stringi::stri_trans_general(str=ENTIDAD, id='Latin-ASCII')) %>% # remove accents
  arrange(FECHA_ARCHIVO, ID_REGISTRO)
# df %>%filter(grepl('1', RESULTADO)) # check nrow and delay is correct

# Get all vars by id
dd <- left_join(df, ids)
write.csv(dd, '../latest_raw.csv', row.names=FALSE, fileEncoding='UTF-8')

# Nowcasts
nowcasts <- dd %>%
  filter(FECHA_ARCHIVO>'2020-04-12') %>% # exclude earlier dates because 'delay' won't show since earlier data has different structure
  select(PAIS_ORIGEN, FECHA_SINTOMAS, FECHA_ARCHIVO, DELAY, ENTIDAD, # params
         FECHA_DEF, ENTIDAD_REGISTRO, RESULTADO) %>% # filters
  rename(import_status=PAIS_ORIGEN) %>%
  rename(date_onset=FECHA_SINTOMAS) %>%
  rename(date_confirm=FECHA_ARCHIVO) %>%
  rename(report_delay=DELAY) %>%
  rename(region=ENTIDAD) %>%
  filter(grepl('1', RESULTADO)) %>% # keep only positive cases
  mutate(import_status=str_replace(import_status, '99', 'Local')) %>% # assume these are local
  mutate(import_status=str_replace(import_status, '98', 'Local')) %>% # match case in original data (ie 'Local' not 'local')
  mutate(import_status=str_replace(import_status, '97', 'Local')) %>%
  filter(!grepl('9999-99-99', FECHA_DEF)) %>% # these don't count as active cases
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
write.csv(cases, '../latest_cases.csv', row.names=FALSE, fileEncoding='UTF-8')

# `import_status` (values 'local' and 'imported'), `date_onset`, `date_confirm`, `report_delay`, and `region`
linelist <- nowcasts %>%
  select(import_status, date_onset, date_confirm, report_delay, region) %>%
  mutate(import_status = ifelse(import_status == 'Local' , 'local', 'imported')) # use nowcasts values
write.csv(linelist, '../latest_linelist.csv', row.names=FALSE, fileEncoding='UTF-8')

# https://stackoverflow.com/questions/38025866/find-difference-between-dates-in-consecutive-rows
# https://stackoverflow.com/questions/41194878/how-to-delete-duplicates-from-groups-in-r-where-group-is-formed-by-three-columns
# https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://stackoverflow.com/questions/8161836/how-do-i-replace-na-values-with-zeros-in-an-r-dataframe
# https://stackoverflow.com/questions/15641924/remove-all-duplicates-except-last-instance
