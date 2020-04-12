# COVID-19 series de tiempo y datos diarios

**Last Updated (12/04/2020)**

Esta carpeta contiene las series de tiempo y datos diarios procesados a partir de los reportes diarios de la Secretaría de Salud (por cada estado en México) y el Hospital John Hopkins (para cada país/región mundial). El prefijo `ts` se refiere a "time series" (datos acumulados), mientras que el prefijo `delta` se refiere al número de casos nuevos diarios.

**Nota:** En los siguientes días, el campo `Date_Confirmed` en los archivos para México corresponderá a la fecha de inicio de síntomas y no a la fecha de dentificación de COVID-19 por RT-PCR en tiempo real. Más info en este excelente [(post de Tim Churches)](https://timchurches.github.io/blog/posts/2020-03-01-analysing-covid-19-2019-ncov-outbreak-data-with-r-part-2/#data-limitations). El problema es que para los días 07/marzo y 08/marzo **no** tienen los campos de síntomas - en cambio, contiene úmeros arbitrarios (ejemplo: `43912`, `43914`, `43916`), en vez de fechas.

### Formato de fechas
* `ts_world_covid_19.csv`, `delta_world_covid19.csv` - MM-DD-YYYY
* `ts_mexico_covid_19.csv`, `delta_mexico_covid19.csv` - MM/DD/YYYY