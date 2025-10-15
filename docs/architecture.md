# InSet Architecture Overview

This document outlines the initial system architecture for InSet, an open-source platform for designing, evaluating, and deploying AI assistants.

## Architectural Principles

1. **Modularity** – Each core capability (authoring, runtime, evaluation, analytics) is implemented as a separate service with a clear API boundary.
2. **Observability by default** – All services emit structured logs, traces, and metrics to facilitate debugging and compliance.
3. **Model agnostic** – The system supports multiple foundation models and model providers via adapters.
4. **Security & governance** – Role-based access control, audit logs, and policy enforcement are first-class features.

## Component Diagram

```
+--------------------+        +-------------------+        +-------------------+
|    Web Studio      | <----> | Workflow API      | <----> | PostgreSQL        |
| (Next.js frontend) |  REST  | (FastAPI service) |  ORM   | Project metadata  |
+--------------------+        +-------------------+        +-------------------+
           |                             |                           |
           | GraphQL (future)            |                           |
           v                             v                           v
+--------------------+        +-------------------+        +-------------------+
| Conversation       |  gRPC  | Evaluation Engine |  Redis | Task queue        |
| Runtime Gateway    | <----> | (Celery workers)  | <----> | Job dispatch      |
| (FastAPI + Async)  |        |                   |        | Rate limiting     |
+--------------------+        +-------------------+        +-------------------+
           |                             |                           |
           v                             v                           v
+--------------------+        +-------------------+        +-------------------+
| LLM Providers      |  HTTPS | Judge Models      |  S3    | Transcript storage|
| (OpenAI, etc.)     |        | (LLM / heuristics) |       | & evaluation data |
+--------------------+        +-------------------+        +-------------------+
```

## Service Responsibilities

### Web Studio (Next.js + TypeScript)
- Provides UI for project management, agent configuration, prompt editing, dataset curation, and Live Com interview sessions.
- Implements real-time collaboration using WebSockets (Ably/Supabase Realtime) or CRDTs.
- Integrates with the Workflow API for CRUD operations and evaluation dashboards via REST/GraphQL.

### Workflow API (FastAPI + SQLModel)
- Authenticates users (OAuth/OpenID Connect) and enforces RBAC policies.
- Manages projects, agent versions, datasets, evaluation specs, and release workflows.
- Publishes evaluation jobs to Redis and stores results in PostgreSQL and ClickHouse.
- Emits structured logs via OpenTelemetry and ships traces/metrics to the observability stack.

### Conversation Runtime Gateway
- Handles real-time chat sessions with user clients (web widgets, API consumers) and Live Com facilitators.
- Orchestrates tool calls, retrieval augmentation, and response post-processing.
- Logs transcripts to S3 and analytics events to ClickHouse via Kafka.
- Applies safety guardrails (moderation filters, output classifiers) before responding to end-users.
- Supports moderator controls (mute, inject prompts, mark incidents) required for interview workflows.

### Evaluation Engine (Celery Workers)
- Consumes evaluation jobs, executes scripted conversations, and collects metrics.
- Supports plug-ins for different evaluation methodologies: deterministic checks, LLM judges, human review tasks.
- Generates regression summaries and pushes alerts to Slack/Teams when thresholds are breached.

### Data & Analytics Layer
- **PostgreSQL** – Authoritative store for configuration data, user accounts, audit logs.
- **ClickHouse** – High-volume analytics database for conversation events, evaluation metrics, and dashboards.
- **Redis** – Job queue broker and caching layer for ephemeral data.
- **Object Storage (S3-compatible)** – Stores conversation transcripts, attachments, evaluation artifacts.

### Observability Stack
- **OpenTelemetry Collector** – Aggregates traces/metrics/logs from services.
- **Prometheus** – Scrapes metrics and provides alerting rules.
- **Grafana** – Visualization for metrics and logs.

## Data Flow Overview

1. A user configures an agent in the Web Studio; changes are persisted via the Workflow API to PostgreSQL.
2. The user triggers an evaluation run. The Workflow API enqueues a job on Redis.
3. Celery workers pick up the job, execute scripted conversations against the Conversation Runtime.
4. Runtime interacts with the selected LLM provider, logs transcripts to S3, and publishes analytics to ClickHouse.
5. Evaluation results are stored back into PostgreSQL and ClickHouse. Web Studio queries these stores to render dashboards.

## Security Considerations

- Enforce OAuth/OIDC authentication with JWT access tokens.
- Use per-project API keys for runtime access; rotate automatically.
- Encrypt secrets using HashiCorp Vault or AWS KMS.
- Implement audit logging on all configuration changes and evaluation runs.
- Provide tooling for redacting PII in transcripts before storage.

## Future Enhancements

- Introduce fine-tuning workflows for custom models.
- Add feature flags for controlled rollouts of agent configurations.
- Support on-premise deployments via Helm charts.
- Provide Terraform modules for cloud infrastructure provisioning.

