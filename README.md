
# 🎬 Azure Cinematic Data Pipeline Project

This project implements an end-to-end data pipeline on Azure to process a movie dataset. The pipeline orchestrates the ingestion, transformation, and loading of data using Azure Data Factory and Azure Blob Storage, with the entire infrastructure defined and managed via Terraform.

-----

## 🎯 Project Goal

The mission is to transform a raw, unfiltered movie dataset into a clean, relevant, and analysis-ready format. The pipeline automates the data cleansing and enrichment process, ensuring that only high-quality information (in this case, top-rated movies) is made available for downstream applications like streaming platforms, business intelligence dashboards, or recommendation systems.

The objective is to demonstrate the ability to build a robust and scalable ETL (Extract, Transform, Load) process in a cloud environment, managing data cleansing, structural transformation, and final delivery.

-----

## 🏗️ Solution Architecture

The workflow is designed with a multi-stage approach to ensure separation of concerns, traceability, and robustness.

```
[Blob: input] ---> [ADF Pipeline: Step 1 - Data Flow] ---> [Blob: staging] ---> [ADF Pipeline: Step 2 - Copy Data] ---> [Blob: output]
```

1.  **Ingestion (Input):** The original CSV file (`moviesDB.csv`) is uploaded to the `input` container in Azure Blob Storage. This is the landing zone for raw, immutable data.
2.  **Transformation (Data Flow):** An **Azure Data Factory (ADF) Data Flow** reads the raw data, performs the following in-memory transformations, and writes the result to a staging area:
      * **Filtering:** It keeps only records that meet the business criteria: movies with a `Rating` greater than 7 out of 10.
      * **Remapping (Mapping):** It translates the column names from English to Italian for a target audience (`Title` -\> `Film`, `genresgenregenre` -\> `Genere`, `Rating` -\> `Valutazione`).
3.  **Staging Area:** The transformed file (`transformed_movies.csv`) is saved in the `staging` container. This area acts as a buffer, holding clean and validated intermediate data, ready for final loading.
4.  **Final Load (Copy Data):** A **Copy Data** activity retrieves the transformed file from the staging area and loads it into the final `output` container. This final step handles the data transfer and metadata preservation, ensuring reliable delivery.

-----

## 💡 Architectural Decisions

Every technical choice was made to meet requirements for efficiency, maintainability, and professionalism.

  * **Use of a Staging Area:** A three-container architecture (`input`, `staging`, `output`) was chosen to implement the **Separation of Concerns** principle. This is a data engineering best practice because it:
      * **Protects Source Data:** The `input` folder remains an archive of raw, untouched data.
      * **Simplifies Debugging:** If an error occurs, it's easy to determine whether the issue is in the transformation (by analyzing the `staging` output) or in the final load.
      * **Increases Robustness:** It prevents the risk of reprocessing already processed data or creating accidental loops.
  * **Data Flow for Transformation:** The filtering and remapping logic was assigned to a **Data Flow** activity. This tool was chosen over a simple `Copy Activity` for its ability to handle complex transformations visually and scalably by leveraging the power of a managed Apache Spark cluster.
  * **Infrastructure as Code (IaC) with Terraform:** The entire Azure infrastructure is defined as code using **Terraform**. This approach ensures the environment is reproducible, versionable, and easily managed, allowing all resources to be created and destroyed with a single command.

-----

## 🛠️ Technologies Used

  * **Cloud:** Microsoft Azure
  * **Storage:** Azure Blob Storage
  * **ETL/Orchestration:** Azure Data Factory (ADF)
  * **Infrastructure as Code:** Terraform
  * **Command-Line Interface:** Azure CLI

-----

## 🚀 Deployment Guide

### Prerequisites

Before you begin, ensure you have the following tools installed:

  * An Azure Account with an active subscription.
  * [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
  * [Terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli) (version \>= 1.0)

### 1\. Local Setup & Authentication

Clone the repository and log in to your Azure account.

```bash
git clone <YOUR_REPOSITORY_URL>
cd <PROJECT_FOLDER_NAME>
az login
```

### 2\. Deploy Infrastructure with Terraform

Navigate to the Terraform directory and run the commands to create the Azure resources.

```bash
cd terraform

# Initialize Terraform to download the necessary providers
terraform init

# (Optional) Review the execution plan to see what will be created
terraform plan

# Apply the configuration and create the resources. Type 'yes' when prompted.
terraform apply
```

This will create the Resource Group, Storage Account (with `input`, `staging`, and `output` containers), and the Azure Data Factory instance.

### 3\. ADF Pipeline Configuration

The pipeline logic is defined in the ARM template files located in the `/adf` folder. For this project, the pipeline was configured manually in the ADF Studio, but these files represent its configuration and can be used for automated deployments.

-----

## 🏃 Running the Pipeline

1.  **Upload the Input Dataset:**

      * Upload the `moviesDB.csv` file to the **`input`** container in the newly created Azure Storage Account.

2.  **Trigger the Pipeline:**

      * Open the **ADF Studio** from the Azure Portal.
      * Navigate to your main pipeline and click **Debug** to start a test run.

3.  **Expected Result:**

      * After the run completes (check the status in the "Monitor" tab), the **`output`** container will contain a new CSV file. This file will include only the movies with a rating higher than 7 and the remapped Italian column names (`Film`, `Genere`, `Valutazione`).

-----

## 🧹 Resource Cleanup

**This step is crucial to avoid any unexpected costs.**

To delete **all** the resources created by this project, run the following command from the `terraform` directory:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the deletion.
