# Data Pipeline

## Overview

This document describes the pipelines and triggers implemented for this project.

The end-to-end data batch processing pipeline consists of 4 pieces.

The first 2 pipeline pieces are created by using Kestra flows to set up the infrastructure and other 2 pieces are created by using Kestra flow to extract, transform and load the data into GCS and Bigquery, as well as having data quality check using dbt.


## Infrastructure pipelines

There are two Kestra flows created for this project.

**Create key value store in Kestra**

This workflow is designed to set key-value pairs in a key-value store, which can be used to store configuration data or secrets for a Google Cloud Platform (GCP) project.

<img width="536" alt="image" src="https://github.com/user-attachments/assets/9f2ca265-b2ba-4ab6-a814-fdd26d571b03" />


The key value store is in namespaces zoomcamp.

<img width="1217" alt="image" src="https://github.com/user-attachments/assets/21809b06-c4d9-4592-88f1-1b5a25fd5bc4" />

The gcp_key stores the GCP credential in json format.

 **Set up in GCP**

 This workflow is designed to set up resources on Google Cloud Platform (GCP) using Kestra, an orchestration and scheduling platform
 
 <img width="400" alt="image" src="https://github.com/user-attachments/assets/080b7615-c89e-4e88-9784-8ab227b6cc82" />

<br>

<br>

## ETL with Kestra and data quality check with dbt

Kestra ETL workflow consists of total 9 blocks

**1. Scheduling**

<img width="208" alt="image" src="https://github.com/user-attachments/assets/3470331c-32e3-42d2-bc5b-416c0eaff69b" />

This schedules the workflow to run ETL job every 5 minute.


<br>

**2. Set label** 

This set the label for this workflow.

<img width="248" alt="image" src="https://github.com/user-attachments/assets/a250f04e-aaa0-4cc3-9af1-70909ffdb53c" />


<br>

**3. Fetch data**

<img width="470" alt="image" src="https://github.com/user-attachments/assets/27e46962-8072-4fc0-b5bf-3d216df4889f" />

This task fetches data by using HTTP Get method.

<br>


**4. Parse json/ Transform** 

This uses Python to run the transform script to change json output to csv output with desired columns: parameter, place, value, unit, record_time.


<img width="236" alt="image" src="https://github.com/user-attachments/assets/1b00a2ad-4b79-4db6-930a-b8969a38571b" />



<br>



**5. Upload data to Google Cloud Storage (GCS)** 

<img width="365" alt="image" src="https://github.com/user-attachments/assets/0a1cca6a-233b-49dd-b167-8e119b261bbd" />

This task uploads the transformed csv data output to the GCS bucket.

<img width="1271" alt="image" src="https://github.com/user-attachments/assets/56a5c317-096a-43e8-9b88-b5aa25df487e" />



<br>

**6. Create weather table** 

<img width="382" alt="image" src="https://github.com/user-attachments/assets/8e157db0-5896-4ed7-b363-4e0f8757218d" />


This tasks creates weather table in Bigquery with the desired data schema.

The data table is clustered by place and parameter type, and partitioned by date.
Clustering by place and parameter speeds up location-specific queries by physically grouping related data. Partitioning by date makes time-based queries faster by scanning only relevant date ranges. Together they reduce query costs by minimizing scanned data. This structure perfectly matches weather analysis patterns that typically filter by location and time.

<img width="550" alt="image" src="https://github.com/user-attachments/assets/b7f01325-a258-4c43-972e-2aff2bc69124" />




<br>

**7. Load weather data** 

<img width="471" alt="image" src="https://github.com/user-attachments/assets/8001204d-6b46-4d56-a627-bff90d54e9f5" />

This task loads weather data from GCS to the created temporary weather table in BigQuery.

**8. Merge weather data** 

<img width="380" alt="image" src="https://github.com/user-attachments/assets/bd869119-9599-4019-940a-5a85d967b14d" />


This task merges temporary weather table to the final destination weather_table.

<img width="1258" alt="image" src="https://github.com/user-attachments/assets/ad8be7ef-d021-4629-9e12-25ebce4b2236" />

<br>

**9. Purge file** 

<img width="352" alt="image" src="https://github.com/user-attachments/assets/dc87a270-4eaf-4c2b-bb7a-0f19332e8d9b" />

This task purges temporary files after processing.

<img width="1275" alt="image" src="https://github.com/user-attachments/assets/8c89d26a-e32d-42fa-b850-51f3af220ba2" />


## data quality check and data transformation with dbt

<img width="893" alt="image" src="https://github.com/user-attachments/assets/15c8493b-04d6-4c5a-b7d3-a0d437911069" />

A table hk_heat_index_from_parameters is created.
<img width="773" alt="image" src="https://github.com/user-attachments/assets/f2799d90-7e42-498a-9b5d-fbb37556dc02" />

with model sql file

<img width="804" alt="image" src="https://github.com/user-attachments/assets/535d67e2-8eb4-4963-9ee3-6e6bed361791" />
<img width="872" alt="image" src="https://github.com/user-attachments/assets/fb8b8308-5e58-4145-b6c3-80d259c2828b" />
<img width="557" alt="image" src="https://github.com/user-attachments/assets/5a12b8c1-e2bd-4c1d-a11d-83cef69385c6" />


This also performs dbt data quality checks after fetch_weather_data flow successfully ran


<img width="1166" alt="image" src="https://github.com/user-attachments/assets/bd433acc-9662-463b-97ae-bddc66797db3" />





