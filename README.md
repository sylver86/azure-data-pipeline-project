
# Progetto Pipeline Dati Cinematografica su Azure

Questo progetto implementa una pipeline di dati end-to-end su Azure per processare un dataset di film. La pipeline orchestra l'ingestione, la trasformazione e il caricamento dei dati utilizzando Azure Data Factory e Azure Blob Storage, con un'infrastruttura definita e gestita tramite Terraform.

## Descrizione del Processo

L'obiettivo è processare un file CSV contenente informazioni su film, genere e valutazioni. Il flusso di lavoro esegue le seguenti operazioni:

1.  **Ingestione:** Un file sorgente (`moviesDB.csv`) viene caricato in un container di **`input`** su Azure Blob Storage.
2.  **Trasformazione:** Un'attività di **Data Flow** in Azure Data Factory (ADF) esegue due operazioni di pulizia:
      * **Filtraggio:** Mantiene solo i film con una valutazione superiore a 7/10.
      * **Rimappatura:** "Traduce" i nomi delle colonne dall'inglese all'italiano (`Film`, `Genere`, `Valutazione`).
3.  **Salvataggio Intermedio:** Il risultato della trasformazione viene salvato con un nuovo nome (`moviesDB_TRANSFORMER.csv`) all'interno dello stesso container di **`input`**.
4.  **Caricamento Finale:** Un'attività di **Copy Data** identifica e preleva il file trasformato dalla cartella di `input` e lo carica nel container di **`output`** finale, preservando i metadati del file durante la copia.


