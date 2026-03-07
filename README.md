# github-actions

This is the main repo where our github actions and also general technical documentation are located.

## Reusable Workflows

### Docker Build & Push

This reusable workflow builds a Dockerfile located in the root of the project, pushes the new Docker image to an ECR Registry, and optionally updates ECS task definitions for services or scheduled tasks.

#### Usage

To use this workflow, call it from another workflow file as shown in `.github/workflows/dev-build-upload.yml`:

```yaml
jobs:
  build-push:
    uses: gsoftcolombia/github-actions/.github/workflows/docker-build-upload.yml@main
    with:
      AWS_DEFAULT_REGION: ${{ vars.AWS_DEFAULT_REGION }}
      AWS_ROLE_TO_ASSUME: ${{ vars.AWS_ROLE_TO_ASSUME }}
      ECR_REPOSITORY: ${{ vars.ECR_REPOSITORY }}
      NAME_PREFIX: ${{ vars.NAME_PREFIX }}
      
      DEPLOY_SCHEDULED_TASK: true
      EXECUTION_NAME: ${{ vars.EXECUTION_NAME }}
      
      DEPLOY_ECS_SERVICE: false
      SERVICE_NAME: ${{ vars.SERVICE_NAME }}
      ECS_CLUSTER_NAME: ${{ vars.ECS_CLUSTER_NAME }}
      ECS_DEV_DEPLOY: false
```

#### Required Variables

- `AWS_DEFAULT_REGION`: AWS region (available in all /gsoftcolombia projects).
- `AWS_ROLE_TO_ASSUME`: ARN of the role for aws-actions to assume.
- `ECR_REPOSITORY`: ECR Repository Name.
- `NAME_PREFIX`: Prefix of the task definition in AWS.

#### Optional Inputs

- `DEPLOY_SCHEDULED_TASK`: Set to true to deploy scheduled tasks.
- `EXECUTION_NAME`: Suffix for scheduled task definitions (can be a list separated by ';').
- `DEPLOY_ECS_SERVICE`: Set to true to deploy an ECS service.
- `SERVICE_NAME`: Name of the ECS service.
- `ECS_CLUSTER_NAME`: Name of the ECS cluster.
- `ECS_DEV_DEPLOY`: Set to true to deploy to dev environment.

For more details, see the workflow file at `.github/workflows/docker-build-upload.yml`.

