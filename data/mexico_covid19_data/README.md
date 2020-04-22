# covid-19_mex

**Update - 2020-04-21**
La Secretaría de Salud **dejó de publicar los reportes diarios** a partir del día `2020-04-19`.

**Update - 2020-04-13**
La Dirección General de Epidemiología [(acaba de anunciar)](https://twitter.com/RicardoDGPS/status/1249864573936644096) el release de datos que se publicará diariamente [(aquí)](https://www.gob.mx/salud/documentos/datos-abiertos-152127). 
<br>

Los archivos en esta carpeta contienen los archivos pre-procesados de la Secretaría de Salud (InDRE) [(publicados diariamente aquí)])https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449) en formato `pdf`. El pre-procesamiento de datos consiste en convertir cada `pdf` a `csv` usando servicios como [(ZAMAR)](https://www.zamzar.com) y [(ILovePDF)](https://www.ilovepdf.com).

#### Observaciones
* `2020-04-19` - La secretaría
* `2020-04-10` - En la la columna de `Date_Symptoms` se ingresaron números arbitrarios (`43912`, `43914`, `43916`) en vez de fechas para los reportes del día `2020-04-07` y `2020-04-07`.
* `2020-04-09` - Parece ser que a partir del `2020-04-06`, los nuevos casos se están agregando al final de los reportes pasados
* `2020-04-01` - La Secretaría de Salud cambió la estructura de sus datos y no es claro cómo reporta (si es que lo hace) casos nuevos. También eliminó la columna `Origen`.



<br>

#### Notas
* La Secretaría de Salud **no archiva** las publicaciones diarias.
* Los casos (hasta el día `2020-04-09`) se muestran como filas resaltadas en color azul.
* Existen diferentes erroes, omisiones e inconsitencias en los datos. Consultar [(este artículo)](https://serendipia.digital/2020/04/secretaria-de-salud-publica-datos-abiertos-sobre-casos-de-covid-19-en-mexico) de Serendipia.