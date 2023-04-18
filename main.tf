# Configure the GCP provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Postgres Database instance
resource "google_sql_database_instance" "my_instance" {
  name             = "my-instance"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier             = "db-f1-micro"
    activation_policy = "ALWAYS"
  }
}

# Create a Cloud Function to perform an action
resource "google_cloudfunctions_function" "my_function_1" {
  name        = "my-function-1"
  description = "My Cloud Function 1"
  runtime     = "nodejs14"

  source_archive_bucket = google_storage_bucket.my_bucket.name
  source_archive_object = "function1.zip"

  entry_point = "function1"

  trigger_http = true

  environment_variables = {
    PROJECT_ID = var.project_id
  }
}

# Create another Cloud Function to perform another action
resource "google_cloudfunctions_function" "my_function_2" {
  name        = "my-function-2"
  description = "My Cloud Function 2"
  runtime     = "nodejs14"

  source_archive_bucket = google_storage_bucket.my_bucket.name
  source_archive_object = "function2.zip"

  entry_point = "function2"

  trigger_http = true

  environment_variables = {
    PROJECT_ID = var.project_id
  }
}

# Create a storage bucket for the Cloud Functions source code
resource "google_storage_bucket" "my_bucket" {
  name     = "my-bucket"
  location = var.region
}
