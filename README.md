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

- `snowflake_user`: Creates a Snowflake user named `example_user1`.
- `snowflake_role`: Creates a Snowflake role named `example_role1`.
- `snowflake_database`: Creates a Snowflake database named `example_database1`.
- `snowflake_schema`: Creates a Snowflake schema named `example_schema1` in the `example_database1`.
- `snowflake_role_grants`: Grants the `example_role1` to the `example_user1`.

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

## Versioning and Incremental Changes

### Versioning
This repository uses semantic versioning. Each version is tagged with a git tag corresponding to its version number. For example, version `1.0.0` would be tagged as `v1.0.0`.

### Incremental Changes
Changes to the infrastructure are made incrementally. Each change is reviewed as a pull request, and upon approval, the changes are applied using `terraform apply`.

- **Development Environment**: Changes are first applied to a development environment for testing.
- **Staging and Production**: After successful testing, changes are promoted to staging and then to production.

### Rollbacks
In case of errors, the previous version of the infrastructure can be rolled back by checking out the corresponding git tag and running `terraform apply`.

## Adding New Resources

### Adding a New Database

To add a new database, you can extend the `main.tf` file by adding another `snowflake_database` resource block:

```hcl
resource "snowflake_database" "new_database" {
  name    = "new_database"
  comment = "This is a new database"
}
```

## Implementing CI/CD

Continuous Integration and Continuous Deployment (CI/CD) can be implemented to automate the provisioning and management of resources. This section outlines how CI/CD could be implemented.

### Using GitHub Actions

1. **Initial Setup**: Create a new GitHub Actions workflow file in your repository under `.github/workflows/terraform.yml`.

2. **Environment Variables**: Use GitHub Secrets to store sensitive information like a Snowflake password, and reference them in the GitHub Actions workflow.

3. **Workflow Steps**:
    - Checkout the code
    - Setup Terraform
    - Initialize Terraform
    - Validate the Terraform configuration (CI)
    - Plan the Terraform changes
    - Apply the Terraform changes (CD)

### Example GitHub Actions Workflow

Here's a simplified example of a GitHub Actions workflow:

```yaml
# Name of the GitHub Actions workflow
name: "Terraform CI/CD"

# Events that trigger the workflow
on:
  # Trigger when code is pushed
  push:
    # Only for pushes to these branches
    branches:
      - main        # main branch
      - qa          # staging branch
      - development # development branch

# Define the jobs to be run
jobs:
  # Name of the job
  terraform:
    # Environment where the job will run
    runs-on: ubuntu-latest
    
    # Steps the job will execute
    steps:
      # Step 1: Checkout the repository code to the runner
      - name: Checkout code
        uses: actions/checkout@v2

      # Step 2: Setup Terraform on the runner
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      # Step 3: Initialize Terraform (downloads providers and modules)
      - name: Initialize Terraform
        run: terraform init

      # Step 4: Validate the Terraform code (syntax and basic checks)
      - name: Validate Terraform
        run: terraform validate

      # Step 5: Generate a Terraform plan (shows intended changes)
      - name: Plan Terraform
        run: terraform plan

      # Step 6: Apply the Terraform plan (make changes to infrastructure)
      - name: Apply Terraform
        run: terraform apply -auto-approve

```

## Environment-Specific Deployments and CI/CD

### Terraform Workspaces

Terraform workspaces allow you to manage separate state files for different environments such as Dev, QA, and Prod. To create a workspace, use:

```bash
terraform workspace new <WORKSPACE_NAME>
```

To switch between workspaces, use:

```bash
terraform workspace select <WORKSPACE_NAME>
```

Inside the Terraform configuration, you can utilize the workspace name to differentiate resources:

```
resource "snowflake_database" "example_database" {
  name = "example_database_${terraform.workspace}"
  comment = "Database for ${terraform.workspace} environment"
}

resource "snowflake_schema" "example_schema" {
  name     = "example_schema_${terraform.workspace}"
  database = snowflake_database.example_database.name
  comment  = "Schema for ${terraform.workspace} environment"
}

```

## Automating Deployment with GitHub Actions

To automate deployments for Dev, QA, and Prod, you can set up a GitHub Actions workflow that switches to the appropriate workspace and then applies the Terraform configuration.

Here's an example .github/workflows/terraform.yml:

```yaml
# Name of the GitHub Actions workflow
name: "Terraform CI/CD"

# Trigger this workflow on push events to the main, development, and qa branches
on:
  push:
    branches:
      - main
      - qa
      - development

# Define the jobs to be executed
jobs:
  # Name of the job, 'deploy' in this case
  deploy:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Determine environment based on the branch name
    env:
      TF_ENV: ${{ github.ref == 'refs/heads/main' && 'prod' || (github.ref == 'refs/heads/development' && 'dev') || (github.ref == 'refs/heads/qa' && 'qa') }}

    # List of steps to execute
    steps:
      # Step 1: Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v2

      # Step 2: Setup Terraform on the runner
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      # Step 3: Initialize Terraform
      - name: Initialize Terraform
        run: terraform init

      # Step 4: Select or create Terraform workspace based on the environment
      - name: Select Workspace
        run: terraform workspace select $TF_ENV || terraform workspace new $TF_ENV

      # Step 5: Validate the Terraform configuration
      - name: Validate Configuration
        run: terraform validate

      # Step 6: Apply the Terraform changes
      - name: Apply Changes
        run: terraform apply -auto-approve

```

## Auditing and Reviewing Changes to `main.tf`

### Code Reviews

1. **Pull Requests**: All changes to `main.tf` should be made via pull requests. This ensures that no single individual can make changes without review.

2. **Peer Reviews**: Pull requests should be reviewed by at least one other team member before being merged. Look for security risks, compliance issues, and whether the changes align with best practices.

3. **Automated Checks**: Utilize automated linting and security scanning tools to catch issues automatically. These can be integrated into the pull request process.

### Version Control

1. **Git History**: All changes are recorded in the Git history, providing an audit trail that shows what changes were made, who made them, and when they were made.

2. **Tags and Releases**: Use Git tags to mark important states of the codebase or releases. This helps in quickly identifying what code is in each environment.

### Terraform State

1. **Remote State**: Use a secure backend to store Terraform state files. This allows you to keep track of changes to your infrastructure.

2. **State Locking**: Use state locking to prevent conflicts and ensure consistency.

### Continuous Integration (CI)

1. **Automated Testing**: Run automated tests as part of your CI pipeline to catch issues early.

2. **Plan Output**: Before applying changes, review the output of `terraform plan` to understand what changes will be made.

### Audit Logs

1. **Cloud Provider Logs**: Use your cloud provider's audit logging features to keep track of actions taken on your infrastructure.

2. **Third-Party Tools**: Consider third-party logging and monitoring solutions for additional auditing capabilities.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

