library(tidyverse)

# Extract the polygon IDs poligons from original map
map$polygonID <- sapply(slot(map, 'polygons'), function(x) slot(x, 'ID'))
map_df <- merge(map_df, map, by.x = 'id', by.y='polygonID')
head(map_df)

# Change col names
map_df <- map_df %>%
  rename(
    state_id=CVE_ENT, # new = old
    state_name=NOM_ENT
  ) %>%
  mutate(
    state_id=as.factor(as.numeric(as.character(state_id))) # remove leading zeros
    )

# Save
writeOGR(map, '.', 'mx_map', driver='ESRI Shapefile')

# PLOT
###

ggplot() +                                               # initialize ggplot object
  geom_polygon(                                          # make a polygon
    data = map_df,                                       # data frame
    aes(x = long, y = lat, group = group,                # coordinates, and group them by polygons
        fill = cut_number(as.numeric(state_id), 5))) +   # variable to use for filling
  scale_fill_brewer('Test', palette = 'OrRd') +          # fill with brewer colors 
  ggtitle('Mexico') +                                    # add title
  theme(line = element_blank(),                          # remove axis lines .. 
        axis.text=element_blank(),                       # .. tickmarks..
        axis.title=element_blank(),                      # .. axis labels..
        panel.background = element_blank()) +            # .. background gridlines
  coord_equal()                                          # both axes the same scale







# Key
key <- as.data.frame(subset(dat, select = c(CVE_ENT, NOM_ENT)))

# Old-school fortify
map.data <- dat
map.df <- data.frame(id = rownames(map.data@data), map.data@data)
map.f <- fortify(map.data)
map <- merge(map.f, map.df, by = 'id')

# Friendly colnames
map <- map %>%
  rename(
    state_id=CVE_ENT, # new = old
    state_name=NOM_ENT
  )

# Remove leading 0 in state_id and mun_id
map <- map %>%
  mutate(
    state_id=as.factor(as.numeric(as.character(state_id)))
  )

# Save
write.csv(map, 'mexico_states.csv', row.names = FALSE, quote = FALSE)

map_geojson <- geojson_json(map)
geojson_write(map_gejosn, file='mx_nowcasts_data.json')

# SUMMARY DATA
###

# Read data
summary_data <- readRDS('summary_data.rds')
summary_data$avg <- round((summary_data$mid_lower+summary_data$mid_upper/2),0)
ids <- read.csv('inegi_entidades.csv')
summary_data <- summary_data %>% 
  rename(ENTIDAD_FEDERATIVA = region)
mx_data <- left_join(summary_data, ids, by="ENTIDAD_FEDERATIVA")
mx_data$CLAVE_ENTIDAD <- as.character(mx_data$CLAVE_ENTIDAD)

# Map data
mx_nowcasts_map <- mx_data %>% 
  left_join(map, ., by = c('id' = 'CLAVE_ENTIDAD'))

# Save
write.csv(map, 'mexico_states_nowcasts.csv', row.names = FALSE, quote = FALSE)

# PLOTS
#########

theme_maps <- function(base_size = 12, base_family = 'sans') {
  (theme_foundation(base_size = base_size, base_family = base_family)
   + theme(
     line = element_line(),
     rect = element_rect(fill = '#ffffff', linetype = 0, colour = NA),
     text = element_text(colour = '#333333'),
     axis.text = element_text(size = rel(1)),
     axis.text = element_blank(),
     axis.line = element_blank(),
     axis.line.x = element_blank(),
     axis.line.y = element_blank(),
     axis.text.x = element_blank(),
     axis.text.y = element_blank(),
     axis.ticks = element_line(),
     axis.ticks.x = element_blank(),
     axis.ticks.y = element_blank(),
     axis.title = element_blank(),
     axis.title.x = element_blank(),
     axis.title.y = element_blank(),
     legend.key = element_rect(),
     legend.background = element_rect(),
     legend.box = 'vertical',
     legend.direction = 'vertical',
     legend.position = 'right',
     legend.text = element_text(),
     legend.title = element_text(size = rel(1.25)),
     panel.background = element_rect(),
     panel.grid = element_line(colour = NULL),
     panel.grid.major = element_blank(),
     panel.grid.major.x = element_blank(),
     panel.grid.minor = element_blank(),
     panel.margin = unit(c(2), 'lines'),
     plot.background = element_rect(),
     plot.title = element_text(hjust = 0, vjust = 3, size = rel(1.75)),
     plot.margin = unit(c(2, 1.5, 1, 2), 'lines'),
     strip.background = element_rect(),
     strip.text.x = element_text()))
}

require(RColorBrewer)

myPalette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space = 'Lab')

test <- ggplot(mx_nowcasts_map, aes(x = long, y = lat, group = group, fill = (avg))) +
  coord_equal() +
  geom_polygon(aes(fill = (avg)))