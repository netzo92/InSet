# InSet

InSet is an open-source platform inspired by OutSet.ai for building, testing, and deploying high-quality generative AI chat experiences with safety, analytics, and collaboration features baked in.

## Why InSet?

OutSet.ai pioneered a workflow-centric approach to creating AI agents that combine conversational design, evaluation, and governance. InSet replicates these core capabilities in a community-driven project that prioritizes transparency and extensibility.

Key goals include:

- **Unified workspace** for conversation design, prompt engineering, and evaluation.
- **Human-in-the-loop review** flows to ensure responsible AI behavior.
- **Test harnesses and analytics** to track quality across releases.
- **Extensible plugin system** for custom tools, models, and integrations.

## High-Level Architecture

InSet is planned as a modular platform with the following components:

| Component | Description |
| --- | --- |
| **Web Studio** | React/Next.js front-end for authoring conversations, configuring agents, and reviewing analytics. |
| **Workflow Orchestrator** | FastAPI (Python) service that manages projects, agent configurations, evaluation jobs, and dataset storage. |
| **Evaluation Engine** | Background worker (Celery) that runs automated test suites, regression benchmarks, and red-teaming scenarios using LLM-based judges. |
| **Conversation Runtime** | Gateway that handles live chat sessions, tool invocation, and conversation logging. |
| **Data & Storage** | PostgreSQL for structured metadata, ClickHouse for analytics, and S3-compatible storage for transcripts & artifacts. |
| **Observability** | OpenTelemetry tracing + Prometheus metrics + Grafana dashboards. |

A more detailed component breakdown is available in [`docs/architecture.md`](docs/architecture.md).

## Roadmap

1. **Project scaffolding**
   - [ ] Bootstrap Next.js web studio with design system and authentication.
   - [ ] Create FastAPI backend with PostgreSQL persistence and Prisma/SQLModel models.
   - [ ] Establish Celery/Redis worker for async evaluations.
2. **Agent authoring**
   - [ ] Prompt & tool configuration UI with version history.
   - [ ] Dataset management for test conversations, red-team prompts, and live interview scripts.
   - [ ] Integration with OpenAI, Anthropic, and open-source models (via LiteLLM or OpenAI-compatible API).
3. **Evaluation & analytics**
   - [ ] Define evaluation spec format (YAML) and runbook DSL.
   - [ ] Implement automatic regression testing with dashboards & alerting.
   - [ ] Add qualitative review workflows with annotation tooling.
4. **Collaboration & governance**
   - [ ] Role-based access control and audit trails.
   - [ ] Live collaboration and interview review mode (“Live Com”) with shared transcripts and moderator controls.
   - [ ] Policy enforcement (guardrails, banned outputs, compliance checks).
   - [ ] Release management with approvals and rollbacks.

See [`docs/product_vision.md`](docs/product_vision.md) for additional product planning details.

## Getting Started

> ⚠️ **Note:** Implementation is in progress. The instructions below outline the intended setup once services are scaffolded.

1. Clone the repository and install dependencies:
   ```bash
   git clone https://github.com/your-org/InSet.git
   cd InSet
   make install
   ```
2. Start the development stack:
   ```bash
   docker compose up
   ```
3. Access the web studio at `http://localhost:3000`.
4. Run the integration test suite:
   ```bash
   make test
   ```

## Contributing

We welcome community contributions! Please review our contribution guidelines (coming soon) and open an issue to discuss ideas, bug reports, or feature requests. Major contributions should align with the architectural direction described in the docs.

## License

InSet will be released under the Apache 2.0 License (pending).
