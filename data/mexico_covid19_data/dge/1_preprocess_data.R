library(tidyverse)
library(reshape)

# Region ids
ids <- read.csv('entidades.csv')
ids$ENTIDAD_FEDERATIVA <- gsub('Á','A', ids$ENTIDAD_FEDERATIVA)
ids$ENTIDAD_FEDERATIVA <- gsub('É','E', ids$ENTIDAD_FEDERATIVA)
ids$ENTIDAD_FEDERATIVA <- gsub('Í','I', ids$ENTIDAD_FEDERATIVA)
ids$ENTIDAD_FEDERATIVA <- gsub('Ó','O', ids$ENTIDAD_FEDERATIVA)
ids$ENTIDAD_FEDERATIVA <- gsub('Ú','U', ids$ENTIDAD_FEDERATIVA)
ids <- ids %>%
    rename(ENTIDAD_UM = CLAVE_ENTIDAD) %>% # to pre-match main data columns
    mutate(ENTIDAD_UM=as.factor(as.numeric(as.character(ENTIDAD_UM)))) # remove leading zeros

# Data
data_filenames <- list.files(path = 'raw', pattern = '*csv')
data_path <- as.character('raw/')
data_files <- paste(data_path, data_filenames, sep = '')
data <- lapply(
    data_files,
    read.csv,
    header=TRUE,
    stringsAsFactors=TRUE,
    encoding='latin1')
str(data[[1]])
names(data[[1]])

# Add filenames to check if there are undocumented updates :p
file_name <- as.factor(c(data_files)) # vector with filenames
dat <- mapply(cbind, data, 'FILE_NAME'=file_name, SIMPLIFY=F) # and add to new column
dat <- data.table::rbindlist(l=dat, use.names=TRUE, fill=TRUE) # now bind list into data frame
levels(factor(dat$FECHA_ACTUALIZACION)) # there are missing many updates! so we will look at each resport

# Long data format
out <- dat %>%
    select(., 'FILE_NAME', 'ENTIDAD_UM', 'FECHA_INGRESO', 'FECHA_SINTOMAS', 'RESULTADO') %>%
    mutate_at(vars(FILE_NAME, ENTIDAD_UM, FECHA_INGRESO, FECHA_SINTOMAS, RESULTADO), funs(factor)) %>%
    group_by(FILE_NAME, ENTIDAD_UM, FECHA_INGRESO, FECHA_SINTOMAS, RESULTADO) %>%
    summarize(NUMERO_CASOS = n()) %>%
    as.data.frame(.) %>%
    left_join(., ids, by='ENTIDAD_UM') %>%
    select(FILE_NAME, ENTIDAD_UM, ENTIDAD_FEDERATIVA, ABREVIATURA, FECHA_SINTOMAS, FECHA_INGRESO, RESULTADO, NUMERO_CASOS) %>%
    arrange(FILE_NAME, ENTIDAD_UM, FECHA_SINTOMAS, FECHA_INGRESO)

# Write
write.csv(dd, '../../../output_data/dge-covid19-latest.csv', row.names=F)