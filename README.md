# github-actions

This is the main repo where our github actions and also general technical documentation are located.

## Reusable Workflows

### Docker Build & Push

This reusable workflow builds a Dockerfile located in the root of the project, pushes the new Docker image to an ECR Registry, and optionally updates ECS task definitions for services or scheduled tasks.

For scheduled tasks, the caller repository can define runtime overrides under `.config/`:

- Scheduled tasks must provide `.config/<execution-name>.json`.

The file is merged with the current active task definition before the image tag is updated, so the application repository owns the scheduled-task runtime fields without Terraform managing them.

### Deploying the same image to multiple ECS services

The Docker image is built and pushed to ECR only once, in the `build-push` job. `SERVICE_NAME` (like
`EXECUTION_NAME`) accepts a list separated by `;`, e.g. `lh-revslider;pc-epco-rvsl` — this is how
`revslider` deploys the same image to both the `lugo` and `pc-epco` ECS services. A separate
`deploy-ecs-service` job runs the render/appspec/deploy steps once per service name, in parallel,
via a matrix strategy sourced from the `build-push` job's outputs. This keeps the build/push effort
to a single run regardless of how many services consume that image.

Each matrix entry also injects an `APP_NAME` container environment variable set to that service's
name (in addition to the existing `ENVIRONMENT` var). Entrypoints that need per-service behavior
(e.g. a distinct SSM parameter path per deployed instance) should read `APP_NAME` from the
environment instead of hardcoding it, falling back to their historical static value for local/
docker-compose runs, e.g. `APP_NAME="${APP_NAME:-lh-revslider}"`. Single-service apps don't need to
change anything: `APP_NAME` will simply equal their existing `SERVICE_NAME`, matching what they
already hardcode.

### Schedule Tasks expect a .config/json file while not services

This is mainly created because there has been a requirement of some scheduled applications that use the approach of have secrets or ssm parameters mounted from the container definition. On the other hand it is expected that services don't have such requirements because all services use entrypoints that pulls the secrets before start. The only envvar sent is the ENVIRONMENT to identify which parameters to pull.

I think that ideally, we should remove the concept of mounting secrets and instead, use entrypoints.

### EFS-backed persistent volumes are safe across deploys

For ECS **services**, this workflow renders the new task definition with
`aws-actions/amazon-ecs-render-task-definition`, which only overwrites the container's `image` and
`environment` fields and leaves everything else (`mountPoints`, `portMappings`, `logConfiguration`,
etc.) untouched. So if the app's task definition has an EFS volume mounted via Terraform
(`module.ecs-service`'s `efs_volumes`, see `terraform-modules`), every PR/merge deploy from this
workflow keeps that mount intact automatically — no changes are needed here to support stateful
apps.

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
- `SERVICE_NAME`: Name of the ECS service (can be a list separated by ';' to deploy the same image to multiple services).
- `ECS_CLUSTER_NAME`: Name of the ECS cluster.
- `ECS_DEV_DEPLOY`: Set to true to deploy to dev environment.

For more details, see the workflow file at `.github/workflows/docker-build-upload.yml`.

