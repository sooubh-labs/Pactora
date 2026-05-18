# Pactora Offline AI Architecture Plan

## Vision
Build a fully offline, privacy-first AI assistant inside Pactora that understands promises, money records, borrow/lend items, reminders, and people context.

## Core Architecture Decisions

### Runtime
Use llama.cpp via native mobile integration.

Why:
- fully offline
- production-proven local inference
- quantized model support
- strong Android compatibility
- avoids cloud dependency

### Model Strategy
Phase 1:
- 1.5B instruct model

Phase 2 optional:
- 3B premium-quality model for higher-end devices

Do not start with 7B models.

Reasons:
- RAM pressure
- battery drain
- slow response time
- large download size

### Memory Strategy
Two-layer context system:

1. Structured live context
- overdue promises
- upcoming reminders
- unpaid debts
- overdue borrowed items
- person histories
- current screen context

2. Semantic memory
Store embeddings for searchable memory retrieval.

### Safety Model
AI must never directly mutate the database.

Use tool execution layer:
- listPromises()
- getOverduePromises()
- listDebts()
- listBorrowedItems()
- getPersonHistory()
- createReminder()
- draftReminderMessage()

## Proposed Folder Structure

lib/core/ai/
  ai_service.dart
  ai_model_runtime.dart
  ai_context_builder.dart
  ai_tool_registry.dart
  ai_memory_service.dart
  ai_embedding_service.dart
  ai_prompt_templates.dart
  ai_result_parser.dart
  ai_chat_session.dart

lib/features/ai/
  presentation/
  widgets/
  providers/
  models/

## Implementation Phases

### Phase 1 — AI MVP
Deliver:
- AI chat screen
- local model loader
- prompt input
- streaming response UI
- structured context access only

Use cases:
- What am I forgetting?
- Who owes me money?
- What promises are overdue?

### Phase 2 — Tool Calling
Implement:
- tool schema
- tool execution engine
- structured responses
- intent routing

### Phase 3 — Semantic Memory
Implement embeddings for:
- promises
- notes
- people summaries
- money remarks
- borrow records

Flow:
create/update record -> embedding generation -> Isar storage -> retrieval on query

### Phase 4 — Deep Integration
Embed AI into:
- dashboard
- person detail screens
- promise detail screens
- money screens
- search

### Phase 5 — Proactive Insights
Examples:
- overdue warnings
- forgotten commitment suggestions
- reminder recommendations

## Technical Constraints

### Model Delivery
Do not bundle model in APK.

Use first-run model download with:
- checksum validation
- resumable download
- version management

### Performance
Requirements:
- lazy model loading
- streaming output
- background-safe inference
- token budget control

### Security
Never expose:
- secrets
- hidden flags
- internal credentials

## Testing Requirements
Add:
- AI tool tests
- context builder tests
- prompt assembly tests
- semantic retrieval tests
- integration tests
- performance benchmarks

## Production Readiness Checklist
- model manager
- download manager
- cancellation support
- timeout handling
- fallback UI states
- telemetry abstraction (local-safe)
- battery impact testing
- low-memory handling

## Recommended Rollout
Release 1:
AI assistant MVP

Release 2:
semantic memory

Release 3:
contextual AI actions

Release 4:
proactive intelligence
