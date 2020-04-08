# covid-19_mex

Elaborados con los datos más reciente del reporte diario de la Secretaría de Salud.

_Última actualización: 08/04/2020_

### Casos confirmados

##### Por fecha de RT-PCT
* `confirmed_cases_by_date.csv` - Casos confirmados, registrados de acuerdo a la fecha en que fueron confirmados mediante una pueba RT-PCR en tiempo real.
* `daily_confirmed_cases_by_date.csv` - Nuevos casos confirmados (diariamente), registrados de acuerdo a la fecha en que fueron confirmados mediante una pueba RT-PCR en tiempo real.
* `daily_confirmed_cases_by_date.csv` - Casos confirmados, registrados de acuerdo a la fecha en que fueron confirmados mediante una pueba RT-PCR en tiempo real *en formato long*, esto es, cada estado tiene su propia fila (tanto acumulados como los diarios). TL;DR junta los archivos anteriores en otro formato.

##### Por fecha de inicio de síntomas
* `confirmed_cases_by_symptoms_date.csv` - Casos confirmados, registrados de acuerdo a la fecha en que iniciaron síntomas.
* `daily_confirmed_cases_by_symptoms_date.csv` - Nuevos casos confirmados (diariamente), registrados de acuerdo a la fecha en que iniciaron síntomas.

##### Por número mínimo de casos
`start_at_min_cases.csv` - Casos confirmados, comenzando la serie de tiempo por el momento en que cada región tuviera un mínimo acumulado de n=15 casos.
`start_at_min_cases_daily.` - Nuevos casos confirmados, comenzando la serie de tiempo por el momento en que cada región tuviera un mínimo acumulado de n=15 casos.