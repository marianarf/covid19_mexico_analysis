# covid-19_mex

Los archivos en esta carpeta contienen los datos utilizados para generar las series de tiempo en este repositorio están en formato `csv` en [(esta carpeta)](https://github.com/marianarf/covid19_mexico_analysis/tree/master/output_data). [(tablas limpias aquí)](https://github.com/marianarf/covid19_mexico_analysis/tree/master/output_data)

_Última actualización: 10/04/2020_

_Observaciones:_

* 06/04/2020 - La Secretaría de Salud cambió la estructura de sus datos y no es claro cómo reporta (si es que lo hace) casos nuevos. También eliminó la columna `Origen`.
* 09/04/2020 - Parece ser que a partir del 06/04/2020, los nuevos casos se están agregando al final de los reportes pasados
* 10/04/2020 - Por alguna razón en la columna de `Date_Symptoms` se ingresaron números arbitrarios (`43912`, `43914`, `43916`) en vez de fechas (reportes del día 07/04/2020 y 08/04/2020). Este comportamiento no sucede para los reportes para 09/04/2020 y 10/04/2020.

* `csv` - Datos manualment tabulados a partir de los reportes diarios de la Secretaría de Salud [(link)](https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449).

Notas:
* La Secretaría de Salud **no archiva** las publicaciones diarias.
* Los casos nuevos no se muestran en forma tabular (aparecen como filas resaltadas en color azul).
* Los datos diarios oficiales (pdf) tienen inconsistencias. Para más contexto, consultar el repo de [Katia Guzmán](https://github.com/guzmart/covid19_mex).

