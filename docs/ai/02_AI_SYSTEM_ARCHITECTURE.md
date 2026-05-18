# AI System Architecture

## Architecture Overview
Pactora AI follows a layered offline architecture.

UI Layer -> Riverpod State -> AI Orchestrator -> Tool Execution -> Context Builder -> Memory Retrieval -> Runtime Layer -> Isar

## Core Components

### AI Orchestrator
Responsibilities:
- classify intent
- choose tools
- request context
- enforce token budgets
- stream responses
- request confirmations for mutations

### Context Builder
Builds grounded context from:
- current screen
- selected entity
- overdue items
- recent interactions
- active reminders

### Tool Layer
Only approved operations.
No unrestricted model access.

### Memory Layer
Hybrid retrieval:
- deterministic structured fetches
- semantic vector search
- summary cache lookups

### Runtime Layer
llama.cpp wrapper for inference.

## Query Flow
1. user asks question
2. intent classification
3. tool selection
4. context retrieval
5. semantic retrieval
6. prompt assembly
7. inference
8. response parsing
9. UI streaming

## Mutation Safety
Any action like reminder creation requires explicit user confirmation.
