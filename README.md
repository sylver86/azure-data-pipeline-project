
# Progetto Pipeline Dati Cinematografica su Azure

Questo progetto implementa una pipeline di dati end-to-end su Azure per processare un dataset di film. La pipeline orchestra l'ingestione, la trasformazione e il caricamento dei dati utilizzando Azure Data Factory e Azure Blob Storage.

-----

## Scopo del Progetto

La missione è trasformare un dataset grezzo di film, disomogeneo e contenente informazioni non filtrate, in un formato pulito, rilevante e pronto per l'analisi. La pipeline automatizza il processo di pulizia e arricchimento dei dati, garantendo che solo le informazioni di alta qualità (in questo caso, film con un'ottima valutazione) siano rese disponibili per applicazioni a valle, come piattaforme di streaming, dashboard di business intelligence o sistemi di raccomandazione.

L'obiettivo è dimostrare la capacità di costruire un processo ETL (Extract, Transform, Load) robusto e scalabile in un ambiente cloud, gestendo la pulizia dei dati, la trasformazione della loro struttura e il loro caricamento in una destinazione finale.

-----

## Architettura della Soluzione

Il flusso di lavoro è stato progettato seguendo un approccio a più fasi per garantire la separazione delle responsabilità, la tracciabilità e la robustezza del processo.

```
[Blob: input] ---> [ADF Pipeline: Fase 1 - Data Flow] ---> [Blob: staging] ---> [ADF Pipeline: Fase 2 - Copy Data] ---> [Blob: output]
```

1.  **Ingestione (Input):** Il file CSV originale (`moviesDB.csv`) viene caricato nel container `input` di un Azure Blob Storage. Questa è la zona di atterraggio dei dati grezzi, che vengono mantenuti nel loro stato originale per garantire la riprocessabilità e l'auditing.
2.  **Trasformazione (Data Flow):** Un'attività di **Data Flow** in Azure Data Factory (ADF) legge i dati grezzi ed esegue le seguenti trasformazioni in memoria:
      * **Filtraggio:** Mantiene solo i record che soddisfano il criterio di business, ovvero film con una valutazione (`Rating`) superiore a 7 su 10.
      * **Rimappatura (Mapping):** Converte i nomi delle colonne dall'inglese all'italiano per renderli più comprensibili per un pubblico italiano (`Title` -\> `Film`, `genresgenregenre` -\> `Genere`, `Rating` -\> `Valutazione`).
3.  **Area di Sosta (Staging):** Il file trasformato (`transformed_movies.csv`) viene salvato nel container `staging`. Questa area funge da cuscinetto e contiene dati intermedi già puliti e validati, pronti per essere caricati nella destinazione finale.
4.  **Caricamento Finale (Copy Data):** Un'attività di **Copy Data** preleva il file dall'area di staging e lo carica nel container `output`. Quest'ultima fase si occupa del trasferimento finale e della gestione dei metadati, assicurando che il dato arrivi a destinazione in modo affidabile.

-----

## Motivazioni delle Scelte (Decisioni Architetturali)

Ogni scelta tecnica è stata ponderata per rispondere a requisiti di efficienza, manutenibilità e professionalità.

  * **Uso di un'area di Staging:** È stata scelta un'architettura a tre container (`input`, `staging`, `output`) per implementare il principio della **Separation of Concerns**. Questo approccio è una best practice di data engineering perché:

      * **Protegge i dati sorgente:** La cartella `input` rimane un archivio di dati grezzi e immutabili.
      * **Semplifica il Debug:** Se si verifica un errore, è facile capire se il problema risiede nella trasformazione (analizzando l'output in `staging`) o nel caricamento finale.
      * **Aumenta la Robustezza:** Previene il rischio di riprocessare dati già elaborati o di creare loop accidentali.

  * **Data Flow per la Trasformazione:** La logica di filtro e rimappatura è stata affidata a un'attività di **Data Flow**. Questo strumento è stato preferito a una semplice `Copy Activity` per la sua capacità di gestire trasformazioni complesse in modo visuale e scalabile, sfruttando la potenza di un cluster Apache Spark gestito da Azure. Permette di incatenare più logiche di business (filtri, join, aggregazioni) in un unico flusso coerente.

  * **Copy Activity per il Caricamento Finale:** Sebbene il Data Flow potesse scrivere direttamente nell'output, è stata aggiunta un'attività di **Copy Data** dedicata per il caricamento finale. Questa scelta è stata fatta per soddisfare letteralmente il requisito di "gestione dei metadati durante la copia", una funzionalità specifica e ottimizzata di questa attività, che è progettata per trasferimenti di dati massivi e affidabili.

-----

## Tecnologie Utilizzate

  * **Cloud:** Microsoft Azure
  * **Storage:** Azure Blob Storage
  * **ETL/Orchestrazione:** Azure Data Factory (ADF)

-----

## Guida all'Implementazione

### 1\. Setup Manuale dell'Infrastruttura

Per eseguire il progetto, è necessario creare manualmente le seguenti risorse nel portale Azure:

1.  Un **Resource Group** per contenere tutte le risorse.
2.  Un **Azure Storage Account**. All'interno di questo, creare tre **container**:
      * `input`
      * `staging`
      * `output`
3.  Un'istanza di **Azure Data Factory (V2)**.

### 2\. Configurazione della Pipeline in ADF

All'interno di Azure Data Factory Studio, la pipeline e i suoi componenti (Linked Services, Datasets, Data Flow) devono essere creati e configurati come descritto nella sezione "Architettura". I file JSON esportati dal progetto (`/adf`) rappresentano l'esatta configurazione di ogni componente.

-----

## Esecuzione della Pipeline

1.  **Carica il Dataset di Input:**

      * Dal portale Azure, carica il file `moviesDB.csv` nel container **`input`**.

2.  **Avvia la Pipeline:**

      * Apri **ADF Studio**.
      * Naviga fino alla pipeline principale e clicca su **Debug** per avviare un'esecuzione.

3.  **Risultato Atteso:**

      * Al termine dell'esecuzione (visibile nel tab "Monitor"), il container **`output`** conterrà un file CSV. Questo file includerà solo i film con una valutazione superiore a 7 e le colonne `Film`, `Genere`, `Valutazione`.
