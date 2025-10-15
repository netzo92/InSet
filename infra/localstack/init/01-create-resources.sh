#!/usr/bin/env bash
set -euo pipefail

awslocal s3 mb s3://inset-transcripts >/dev/null 2>&1 || echo "Bucket inset-transcripts already exists"
awslocal s3 mb s3://inset-evaluation-artifacts >/dev/null 2>&1 || echo "Bucket inset-evaluation-artifacts already exists"

awslocal sqs create-queue --queue-name inset-evaluations >/dev/null 2>&1 || echo "Queue inset-evaluations already exists"
awslocal sqs create-queue --queue-name inset-runtime-events >/dev/null 2>&1 || echo "Queue inset-runtime-events already exists"

awslocal events create-event-bus --name inset-livekit-events >/dev/null 2>&1 || echo "Event bus inset-livekit-events already exists"

awslocal secretsmanager create-secret --name inset/runtime/api --secret-string '{"apiKey":"local-demo-key"}' >/dev/null 2>&1 || echo "Secret inset/runtime/api already exists"
awslocal secretsmanager create-secret --name inset/livekit/api --secret-string '{"apiKey":"local-livekit-key","apiSecret":"local-livekit-secret"}' >/dev/null 2>&1 || echo "Secret inset/livekit/api already exists"

runtime_config=$(cat <<'JSON'
{
  "transcriptBucket": "inset-transcripts",
  "artifactBucket": "inset-evaluation-artifacts",
  "evaluationQueueUrl": "http://localhost:4566/000000000000/inset-evaluations",
  "runtimeEventQueueUrl": "http://localhost:4566/000000000000/inset-runtime-events",
  "livekitEventBusArn": "arn:aws:events:us-east-1:000000000000:event-bus/inset-livekit-events"
}
JSON
)

awslocal ssm put-parameter \
  --name "/inset/runtime/config" \
  --type "String" \
  --value "${runtime_config}" \
  --overwrite >/dev/null 2>&1 || true

cat <<'EOFMSG'
LocalStack bootstrap completed:
- S3 buckets: inset-transcripts, inset-evaluation-artifacts
- SQS queues: inset-evaluations, inset-runtime-events
- EventBridge bus: inset-livekit-events
- Secrets: inset/runtime/api, inset/livekit/api
- SSM parameter: /inset/runtime/config
EOFMSG
