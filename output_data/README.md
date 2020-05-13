# COVID-19 series de tiempo y datos diarios

Esta carpeta contiene las series de tiempo y datos diarios procesados a partir de los reportes diarios de la Secretaría de Salud (por cada estado en México) y el Hospital John Hopkins (para cada país/región mundial). El prefijo `total` se refiere a la serie de tiempo del total de casos acumulados, mientras que el prefijo `daily` se refiere al número de casos nuevos diarios.

**Nota:** Sería ideal agregar series de tiempo basadas en las fechas de **inicio de síntomas** (y no a la fecha de dentificación de COVID-19 por RT-PCR en tiempo real). Más info en este [(post de Tim Churches)](https://timchurches.github.io/blog/posts/2020-03-01-analysing-covid-19-2019-ncov-outbreak-data-with-r-part-2/#data-limitations).

* `total_world_covid19.csv` - World countries time series of daily cases.
* `daily_world_covid19.csv` - World countries time series of daily cases.
* `total_mexico_covid19.csv` - Mexico regional time series of total cases. 
* `daily_mexico_covid19.csv` - Mexico regional time series of daily cases. 

* `rolling-time-series.csv` - Long time series used to plot log Covid-19 world trends.
