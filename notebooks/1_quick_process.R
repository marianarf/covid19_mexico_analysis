options(scipen = 999)

library(tidyverse)
library(magrittr)

# Read multiple files
data_filenames <- list.files(path = '../data/dge', pattern = '*.csv')
data_path <- as.character('../data/dge/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(
  data_files,
  read.csv,
  header=TRUE,
  stringsAsFactors=TRUE,
  encoding = 'latin-ascii') # damn

# Factor
filename <- as.factor(c(data_filenames))

# Bind listo of data frames
filename <- as.Date(filename, '%y%m%d') # timesamp
dat <- mapply(cbind, data, 'FECHA_CORTE'=filename, SIMPLIFY=F) # set previous column before bind
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE) # bind list of data frames
dat <- dat %>% mutate(RESULTADO=as.factor(RESULTADO)) # factor

dat <- dat %>% select(FECHA_CORTE, FECHA_ACTUALIZACION,
                      ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, MUNICIPIO_RES, FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF, PAIS_ORIGEN, RESULTADO)

# test <- dat %>%
  #mutate_all(funs(str_replace(., 'Á', 'A'))) %>% # search all data frame 
  #mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, 'Á', 'A'), regex=TRUE) # wat

#levels(as.factor(dat$PAIS))
#levels(as.factor(dat$FECHA_CORTE))
#levels(as.factor(dat$FECHA_ACTUALIZACION))

nrow((dat))

dd <- dat %>% select(ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, MUNICIPIO_RES, FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF, PAIS_ORIGEN, RESULTADO) %>%
  filter(as.integer(RESULTADO)==1) %>%
  mutate(., FECHA_INGRESO = as.POSIXct(FECHA_INGRESO, format='%Y-%m-%d')) %>%
  mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, '99', 'Local')) %>%
  mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, '98', 'Local')) %>%
  mutate(PAIS_ORIGEN = str_replace(PAIS_ORIGEN, '97', 'Local')) %>%
  filter(!grepl('99', ENTIDAD_RES)) %>%
  filter(!grepl('98', ENTIDAD_RES)) %>%
  filter(!grepl('97', ENTIDAD_RES)) %>%
  filter(!grepl('999', MUNICIPIO_RES)) %>%
  filter(!grepl('998', MUNICIPIO_RES)) %>%
  filter(!grepl('997', MUNICIPIO_RES)) %>%
  arrange(desc(FECHA_INGRESO))

write_csv(dd, '../latest_raw.csv')