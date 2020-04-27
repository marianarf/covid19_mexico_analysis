options(scipen = 999)

library(tidyverse)
library(stringr)
library(magrittr)

# Data
data_filenames <- list.files(path = 'dge', pattern = '*.csv')
data_path <- as.character('dge/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(
  data_files,
  read.csv,
  header=TRUE,
  stringsAsFactors=TRUE,
  encoding = 'latin1')

filename <- as.factor(c(data_filenames))
filename <- as.Date(filename, '%y%m%d')

dat <- mapply(cbind, data, 'FECHA_CORTE'=filename, SIMPLIFY=F)
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE)
dat <- dat %>% mutate(RESULTADO=as.factor(RESULTADO))
#dat <- dat %>% select(-c(ID_REGISTRO))

levels(as.factor(dat$FECHA_CORTE))
levels(as.factor(dat$FECHA_ACTUALIZACION))
nrow((dat))

dd <- dat %>% select(ID_REGISTRO, ENTIDAD_UM, FECHA_INGRESO, RESULTADO) %>%
  filter(as.integer(RESULTADO)==1) %>%
  mutate(., FECHA_INGRESO = as.POSIXct(FECHA_INGRESO, format = '%Y-%m-%d')) %>%
  arrange(desc(FECHA_INGRESO)) %>%
  group_by(ENTIDAD_UM, FECHA_INGRESO, RESULTADO)

write_csv(dd, 'filter.csv')