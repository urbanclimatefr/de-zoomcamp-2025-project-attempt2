variable "project" {
  description = "Project"
  default     = "kestra-de-zoomcamp-kenneth"
}

variable "region" {
  description = "Region"
  default     = "europe-west2"
}

variable "location" {
  description = "GCS Bucket and BigQuery Location"
  default     = "europe-west2"
}

variable "gcs_bucket_name" {
  description = "Name of Storage Bucket "
  default     = " kestra-de-zoomcamp-kenneth-bucket-project"
}

variable "bq_dataset_name" {
  description = "Name of BigQuery Dataset "
  default     = "zoomcamp"
}