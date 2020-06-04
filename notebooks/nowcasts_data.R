# Generate parameters for EpiEstim nowcast model.

options(scipen = 999)

library(tidyverse)
library(data.table)

data <- fread('../mexico_covid19.csv')

# Nowcasts
nowcasts <- data %>%
  filter(FECHA_ARCHIVO>'2020-04-12') %>% # exclude earlier dates because 'delay' won't show since earlier data has different structure
  select(
    PAIS_ORIGEN, FECHA_SINTOMAS, FECHA_ARCHIVO, DELAY, ENTIDAD, # params
    FECHA_DEF, ENTIDAD_REGISTRO, RESULTADO) %>% # filters
  rename(., import_status=PAIS_ORIGEN, date_onset=FECHA_SINTOMAS, date_confirm=FECHA_ARCHIVO, report_delay=DELAY, region=ENTIDAD) %>%
  # keep only positive cases
  filter(grepl('1', RESULTADO)) %>%
  # assume these are local and match case as in original data (ie 'Local' not 'local')
  mutate(import_status=str_replace(import_status, '99', 'Local')) %>% 
  mutate(import_status=str_replace(import_status, '98', 'Local')) %>%
  mutate(import_status=str_replace(import_status, '97', 'Local')) %>%
  # these don't count as active cases for the model
  filter(!grepl('9999-99-99', FECHA_DEF)) %>%
  # remove these if present
  filter(!grepl('99', ENTIDAD_REGISTRO)) %>%
  filter(!grepl('98', ENTIDAD_REGISTRO)) %>%
  filter(!grepl('97', ENTIDAD_REGISTRO))

# `import_status`, `date`, region`, cases`
cases <- nowcasts %>%
  select(import_status, date_confirm, region) %>%
  rename(date=date_confirm) %>%
  mutate(import_status = ifelse(import_status == 'Local' , 'local', 'imported')) %>% # use nowcasts values
  group_by(region, date, import_status, date) %>%
  summarize(cases = n())
write.csv(cases, '../cases.csv', row.names=FALSE, fileEncoding='UTF-8')

# `import_status` (values 'local' and 'imported'), `date_onset`, `date_confirm`, `report_delay`, and `region`
linelist <- nowcasts %>%
  select(import_status, date_onset, date_confirm, report_delay, region) %>%
  mutate(import_status = ifelse(import_status == 'Local' , 'local', 'imported')) # use nowcasts values
write.csv(linelist, '../linelist.csv', row.names=FALSE, fileEncoding='UTF-8')

# https://stackoverflow.com/questions/38025866/find-difference-between-dates-in-consecutive-rows
# https://stackoverflow.com/questions/41194878/how-to-delete-duplicates-from-groups-in-r-where-group-is-formed-by-three-columns
# https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://stackoverflow.com/questions/8161836/how-do-i-replace-na-values-with-zeros-in-an-r-dataframe
# https://stackoverflow.com/questions/15641924/remove-all-duplicates-except-last-instance
