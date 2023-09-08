# Configure the required providers and their versions
terraform {
  required_providers {
    snowflake = {
      source = "chanzuckerberg/snowflake"
      version = "0.25.0"
    }
  }
}

# Declare a variable for the Snowflake password
variable "snowflake_password" {
  description = "The Snowflake password"
  sensitive   = true
}

# Login information
provider "snowflake" {
  account  = "lgsuydq-xe04196"
  username = "kstangline"
  role     = "ACCOUNTADMIN"
  password = var.snowflake_password
}

# Create new user
resource "snowflake_user" "example_user" {
  name = "example_user"
  comment = "Example user"
}

# Create new role
resource "snowflake_role" "example_role" {
  name = "example_role"
  comment = "Example role"
}

# Create new database
resource "snowflake_database" "example_database" {
  name = "example_database"
  comment = "Example database"
}

# Create new database schema
resource "snowflake_schema" "example_schema" {
  name       = "example_schema"
  database   = snowflake_database.example_database.name
  comment    = "Example schema"
}

# Assign role to example_user
resource "snowflake_role_grants" "example_role_to_user" {
  role_name = snowflake_role.example_role.name
  
  users = [
    snowflake_user.example_user.name
  ]
}
