# LocalStack Environment for InSet

This directory contains a Docker Compose configuration and bootstrap scripts for emulating the AWS dependencies that InSet's ser
vices rely on during development. The goal is to provide local equivalents of the storage, messaging, and secret-management reso
urces used by the Conversation Runtime and evaluation workflows without requiring access to a real AWS account.

## What's Included?

The `docker-compose.yml` file starts a [LocalStack](https://www.localstack.cloud/) container with the following services enabled:

- **S3** – stores chat transcripts and evaluation artifacts.
- **SQS** – queues used for dispatching evaluation jobs and runtime events.
- **EventBridge** – receives LiveKit webhook notifications for synchronization.
- **Secrets Manager & SSM Parameter Store** – manage API keys and runtime configuration.
- **CloudWatch Logs/Metrics** – capture structured logs and metrics emitted by the services.

During container start-up, the `init/01-create-resources.sh` script seeds LocalStack with opinionated defaults so that the applic
ation code can assume the resources exist:

- S3 buckets: `inset-transcripts`, `inset-evaluation-artifacts`
- SQS queues: `inset-evaluations`, `inset-runtime-events`
- EventBridge bus: `inset-livekit-events`
- Secrets Manager entries for runtime API keys and LiveKit credentials
- SSM parameter `/inset/runtime/config` that aggregates core resource identifiers

> ℹ️ Feel free to customize these names or add additional resources as the implementation matures.

## Prerequisites

- Docker Desktop or another Docker runtime
- [`awscli-local`](https://github.com/localstack/awscli-local) (installed inside the container automatically)

## Usage

From the repository root:

```bash
docker compose -f infra/localstack/docker-compose.yml up
```

LocalStack exposes AWS-compatible endpoints on `http://localhost:4566`. The default credentials are `AWS_ACCESS_KEY_ID=test`, `
AWS_SECRET_ACCESS_KEY=test`, and `AWS_REGION=us-east-1`.

When the container is ready you should see the bootstrap summary:

```
LocalStack bootstrap completed:
- S3 buckets: inset-transcripts, inset-evaluation-artifacts
- SQS queues: inset-evaluations, inset-runtime-events
- EventBridge bus: inset-livekit-events
- Secrets: inset/runtime/api, inset/livekit/api
- SSM parameter: /inset/runtime/config
```

## Interacting with Resources

Use the AWS CLI (pointed at LocalStack) or `awslocal` helper to inspect the seeded infrastructure. Examples:

```bash
awslocal s3 ls
awslocal sqs list-queues
awslocal events list-event-buses
awslocal secretsmanager get-secret-value --secret-id inset/livekit/api
awslocal ssm get-parameter --name /inset/runtime/config
```

## Next Steps

- Wire the FastAPI services and workers to read configuration from the SSM parameter.
- Forward LocalStack's CloudWatch logs into the local observability stack for unified debugging.
- Extend the bootstrap script as new AWS dependencies (e.g., Lambda, Step Functions) are introduced.
