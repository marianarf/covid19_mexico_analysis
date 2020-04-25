# COVID-19 series de tiempo y datos diarios

Esta carpeta contiene las series de tiempo y datos diarios procesados a partir de los reportes diarios de la Secretaría de Salud (por cada estado en México) y el Hospital John Hopkins (para cada país/región mundial). El prefijo `ts` se refiere a la serie de tiempo del total de casos acumulados, mientras que el prefijo `daily` se refiere al número de casos nuevos diarios.

**Nota:** Tenemos pensado agregar series de tiempo basadas en las fechas de **inicio de síntomas** (y no a la fecha de dentificación de COVID-19 por RT-PCR en tiempo real). Más info en este excelente [(post de Tim Churches)](https://timchurches.github.io/blog/posts/2020-03-01-analysing-covid-19-2019-ncov-outbreak-data-with-r-part-2/#data-limitations). Importante notar que los reportes con fecha 2020-04-07 y 2020-04-08 **no** tienen los campos de síntomas - en cambio, contienen una serie de números no secuenciales (ejemplo: `43912`, `43914`, `43916`), en vez de fechas.

### Formato de fechas
* `ts_world_covid19.csv`, `daily_world_covid19.csv` - YYYY-mm-dd
* `ts_mexico_covid19.csv`, `daily_mexico_covid19.csv` - YYYY-mm-dd