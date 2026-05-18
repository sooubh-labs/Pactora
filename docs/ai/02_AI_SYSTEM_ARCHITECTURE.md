# AI System Architecture

## Layers
UI -> Riverpod State -> AI Orchestrator -> Tool Layer -> Context Builder -> Memory Retrieval -> llama runtime -> Isar

## Responsibilities
AI Orchestrator:
- intent routing
- prompt assembly
- tool selection
- response streaming

Tool Layer:
controlled read/write actions

Context Builder:
screen-aware context packaging

Memory Retrieval:
semantic search + recent activity
