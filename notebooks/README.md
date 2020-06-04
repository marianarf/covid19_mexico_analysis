# COVID-19 clinical data

### Source

<p>This daset contains the results of real-time PCR testing for COVID-19 from the [General Directorate of Epidemiology](https://www.gob.mx/salud/documentos/datos-abiertos-152127) (more details [here](href="https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico/resource/e8c7079c-dc2a-4b6e-8035-08042ed37165)).
    
<p>These units follow a centinel model that samples 10% of the patients that present a viral respiratory diagnosis to test for COVID-19, and consists of data reported by 475 viral respiratory disease monitoring units (hospitals) named USMER (**U**nidade**s** **M**onitoras de **E**nfermedad **R**espiratoria **V**iral) throughout the country in the entire health sector (IMSS, ISSSTE, SEDENA, SEMAR, and more).</p>

<p>Preliminary data subject to validation by the Ministry of Health through the General Directorate of Epidemiology. The information contained corresponds only to the data obtained from the epidemiological study of a suspected case of viral respiratory disease at the time it is identified in the medical units of the Health Sector.</p>

<p>According to the clinical diagnosis of admission, it is considered as an outpatient or hospitalized patient. The base does not include the evolution during the stay in the medical units, with the exception of updates to your discharge by the hospital epidemiological surveillance units or health jurisdictions in the case of deaths.</p>

### Preprocess
Data is processed [with this .R script](https://github.com/marianarf/covid19_mexico_analysis/blob/master/notebooks/preprocess.R), and is also available as a <code>'csv'</code> [in this github repository](https://raw.githubusercontent.com/marianarf/covid19_mexico_analysis/master/mexico_covid19.csv).

- The data aggregates official daily reports of patients admitted in COVID-19 designated units.
- New cases are usually concatenated at the end of the file, but each individual case also contains a unique (official) identifier <code>'ID_REGISTRO'</code> as well as a (new) unique reference <code>'id'</code> to remove duplicates.
- Data also includes missing regional names, fixes changes in methodology at the time of reporting and finally calculates <code>'DELAY'</code> in the processing lab results (since new data contains records from the previous day, this allows to keep track of the lag in lab reporting).

It preserves the original column names and factors as closely as possible to the official data, so that code is reproducible in reference to the official sources.

### Additional info
The data is updated whenever the daily official reports is published. More details and analysis here: https://github.com/marianarf/covid19_mexico_analysis.