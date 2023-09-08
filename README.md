# Snowflake Terraform Configuration

## Overview

This Terraform configuration sets up basic resources in Snowflake, including a user, a role, a database, and a schema. It also grants the role to the user.

## Prerequisites

- Terraform v1.x.x
- Snowflake account

## Configuration

### Providers

- **Snowflake**: The Snowflake provider is used to interact with the Snowflake resources.

### Variables

- `snowflake_password` (required): The password for the Snowflake account. This is sensitive data and should be set through an environment variable.

## Resources

- `snowflake_user`: Creates a Snowflake user named `example_user`.
- `snowflake_role`: Creates a Snowflake role named `example_role`.
- `snowflake_database`: Creates a Snowflake database named `example_database`.
- `snowflake_schema`: Creates a Snowflake schema named `example_schema` in the `example_database`.
- `snowflake_role_grants`: Grants the `example_role` to the `example_user`.

## Usage

1. Initialize the Terraform directory:

    ```
    terraform init
    ```

2. Set the required environment variables:

    ```bash
    export TF_VAR_snowflake_password="YourActualPasswordHere"
    ```

3. Apply the Terraform configuration:

    ```
    terraform apply
    ```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

