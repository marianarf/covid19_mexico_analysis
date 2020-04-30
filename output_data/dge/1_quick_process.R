options(scipen = 999)

library(tidyverse)
library(magrittr)

# Read multiple files
data_filenames <- list.files(path = '../../data/dge', pattern = '*.csv')
data_path <- as.character('../../data/dge/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(
  data_files,
  read.csv,
  header=TRUE,
  stringsAsFactors=TRUE,
  encoding = 'latin1')

# Use factor
filename <- as.factor(c(data_filenames))

# Timesamp
filename <- as.Date(filename, '%y%m%d')

dat <- mapply(cbind, data, 'FECHA_CORTE'=filename, SIMPLIFY=F)
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE)
dat <- dat %>% mutate(RESULTADO=as.factor(RESULTADO))
#dat <- dat %>% select(-c(ID_REGISTRO))

levels(as.factor(dat$FECHA_CORTE))
levels(as.factor(dat$FECHA_ACTUALIZACION))
nrow((dat))

dd_mun <- dat %>% select(ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF, RESULTADO, MUNICIPIO_RES) %>%
  filter(as.integer(RESULTADO)==1) %>%
  mutate(., FECHA_INGRESO = as.POSIXct(FECHA_INGRESO, format='%Y-%m-%d')) %>%
  arrange(desc(FECHA_INGRESO))

dd <- dat %>% select(ID_REGISTRO, ENTIDAD_UM, ENTIDAD_RES, FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF, RESULTADO, ) %>%
  filter(as.integer(RESULTADO)==1) %>%
  mutate(., FECHA_INGRESO = as.POSIXct(FECHA_INGRESO, format='%Y-%m-%d')) %>%
  arrange(desc(FECHA_INGRESO))

write_csv(dd_mun, 'filter_mun.csv')
write_csv(dd, 'filter.csv')