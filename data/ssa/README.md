# covid-19_mex

### Datos
Los archivos en esta carpeta contienen los archivos pre-procesados de la Secretaría de Salud (InDRE) [(publicados diariamente aquí)])https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449) en formato `pdf`. El pre-procesamiento de datos consiste en convertir cada `pdf` a `csv` usando servicios como [(ZAMAR)](https://www.zamzar.com) y [(ILovePDF)](https://www.ilovepdf.com).

**Update - 2020-04-24**
<br>
A partir del día``2020-04-24``  los reportes de datos oficiales de la SSA han sido descontinuados. Por lo tanto, los datos y análisis en este repositorio tomarán como fuente la  [(Dirección General de Epidemiología)](https://www.gob.mx/salud/documentos/datos-abiertos-152127). Presumiblemente, los datos de la SSA a partir del día  `2020-04-19` (que documentan los casos del día previo) fueron asimilados por la DGE.

**Update - 2020-04-21**
<br>
La Secretaría de Salud **dejó de publicar los reportes diarios** a partir del día `2020-04-19` (ie, corte al día ``2020-04-18´´), sin embargo, aún se puede consultar el el [(Comunicado Técnico Diario)](https://www.go..mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449).

**Update - 2020-04-13**
<br>
La Dirección General de Epidemiología [(acaba de anunciar)](https://twitter.com/RicardoDGPS/status/1249864573936644096) el release de datos que se publicará diariamente [(aquí)](https://www.gob.mx/salud/documentos/datos-abiertos-152127). 
<br>

### Observaciones
* `2020-04-19` - La secretaría
* `2020-04-10` - En la la columna de `Date_Symptoms` se ingresaron números arbitrarios (`43912`, `43914`, `43916`) en vez de fechas para los reportes del día `2020-04-07` y `2020-04-07`.
* `2020-04-09` - Parece ser que a partir del `2020-04-06`, los nuevos casos se están agregando al final de los reportes pasados
* `2020-04-01` - La Secretaría de Salud cambió la estructura de sus datos y no es claro cómo reporta (si es que lo hace) casos nuevos. También eliminó la columna `Origen`.

<br>

### Notas
* La Secretaría de Salud **no archiva** las publicaciones diarias.
* Los casos (hasta el día `2020-04-09`) se muestran como filas resaltadas en color azul.
* Existen diferentes erroes, omisiones e inconsitencias en los datos. Consultar [(este artículo)](https://serendipia.digital/2020/04/secretaria-de-salud-publica-datos-abiertos-sobre-casos-de-covid-19-en-mexico) de Serendipia.
