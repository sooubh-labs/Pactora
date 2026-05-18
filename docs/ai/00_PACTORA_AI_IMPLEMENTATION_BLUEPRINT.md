# Pactora AI Implementation Blueprint

## Executive Decision (Final Architecture)

This blueprint defines the recommended implementation for Pactora AI based on the current Pactora architecture (Flutter + Riverpod + Isar + offline-first design).

## Product Positioning
Pactora AI is not a generic chatbot.
It is a context-aware commitment intelligence assistant.

Primary jobs:
- identify forgotten commitments
- summarize obligations
- relationship memory recall
- debt awareness
- reminder drafting
- commitment risk analysis

## Final Technical Stack

### Runtime
llama.cpp

Reason:
- mature mobile local inference
- GGUF quantized model support
- Android friendly
- privacy aligned

### Flutter Integration Strategy
Native Kotlin wrapper + Dart FFI bridge

Decision:
Do not use MethodChannel as primary inference path.
Use MethodChannel only for platform coordination if needed.

Reason:
streaming token inference requires lower overhead.

### Primary Model
Qwen2.5 1.5B Instruct GGUF Q4

Fallback strategy:
Tier 1 devices:
- 1.5B model

Tier 2 future premium:
- optional 3B model

Do not ship 7B initially.

### Embeddings
bge-small

### Storage
Isar remains source of truth.

AI additions:
- embeddings
- AI summaries cache
- conversation history
- model metadata

## New Folder Architecture

lib/core/ai/
  runtime/
    ai_runtime.dart
    llama_runtime.dart
    model_manager.dart
    model_download_manager.dart
    model_registry.dart

  orchestration/
    ai_orchestrator.dart
    ai_context_builder.dart
    ai_prompt_builder.dart
    ai_response_parser.dart
    ai_session_manager.dart

  tools/
    ai_tool.dart
    ai_tool_registry.dart
    promise_tools.dart
    money_tools.dart
    people_tools.dart
    reminder_tools.dart
    search_tools.dart

  memory/
    embedding_service.dart
    semantic_search_service.dart
    memory_indexer.dart
    summary_cache_service.dart

  models/
    ai_message.dart
    ai_tool_call.dart
    ai_context_snapshot.dart
    model_manifest.dart

lib/features/ai/
  presentation/
    ai_chat_screen.dart
    ai_model_download_screen.dart
  widgets/
    ai_entry_fab.dart
    ai_summary_card.dart
    ai_quick_actions.dart
  providers/
    ai_session_provider.dart
    ai_runtime_provider.dart
    ai_memory_provider.dart

## Existing Feature Integration Plan

### Dashboard
Add:
DashboardInsightEngine

Capabilities:
- overdue summary
- forgotten items detection
- suggested actions

### People
Add:
PeopleContextAdapter

Capabilities:
- relationship summaries
- interaction recall
- follow-up suggestions

### Money
Add:
MoneyContextAdapter

Capabilities:
- debt summaries
- overdue dues
- reminder drafting

### Promises
Add:
PromiseContextAdapter

Capabilities:
- commitment risk scoring
- overdue analysis
- completion trends

### Search
Add semantic search overlay.

## AI Tool Contract

Rules:
- no unrestricted DB writes
- tool mediated mutations only
- deterministic outputs

Tool list v1:
- listPromises
- getPromiseById
- getOverduePromises
- listDebts
- listBorrowedItems
- searchPeople
- getPersonHistory
- createReminderDraft
- createReminder
- semanticSearch

Tool response format:
strict JSON payloads only.

## Prompt Architecture

System prompt responsibilities:
- assistant identity
- no hallucination policy
- tool usage rules
- privacy boundaries
- concise answer policy

Prompt structure:
1. system prompt
2. current screen context
3. retrieved semantic memories
4. structured tool outputs
5. user query

## Memory Design

### Structured Context
Fast deterministic context:
- overdue promises
- due reminders
- unpaid debts
- recent interactions

### Semantic Memory
Index:
- promise text
- notes
- person notes
- debt notes
- borrow records

Storage strategy:
entity embedding references only.

Avoid duplicating entire records.

## Isar Schema Additions

Add new collections:

AIEmbeddingRecord
- id
- entityType
- entityId
- vector
- updatedAt

AISummaryCache
- id
- entityType
- entityId
- summary
- updatedAt

AIConversationMessage
- id
- sessionId
- role
- content
- timestamp

AIModelState
- installedVersion
- checksum
- path
- sizeBytes

## Model Delivery Strategy

Do NOT bundle model in APK.

Flow:
1. user enables AI
2. compatibility check
3. storage check
4. download manifest fetch (future)
5. model download
6. checksum verify
7. registration
8. lazy load

Need:
- pause/resume
- retry
- corruption detection
- cleanup

## Device Compatibility Rules

Minimum AI support tier:
mid-range Android only initially.

Check:
- RAM threshold
- storage threshold
- CPU architecture

Fallback:
unsupported device = AI disabled gracefully.

## UX Design

Primary entry:
floating AI assistant button.

Contextual entry:
AI buttons inside detail screens.

Quick actions:
- what am I forgetting
- summarize today
- draft reminder
- who owes me

Streaming response UI required.

Cancellation required.

## Performance Budget

Targets:
first response under 4 seconds on supported devices.

Optimization:
- lazy runtime init
- short prompt budgets
- top-k semantic retrieval only
- summary caching
- aggressive memory cleanup

## Safety Rules

Never expose:
- secrets
- internal config
- hidden flags
- unrestricted raw DB access

Model cannot self-authorize actions.

Mutations require explicit user confirmation.

## Testing Strategy

Unit:
- tool registry
- context builder
- prompt builder
- semantic search

Integration:
- AI query flow
- model loading
- cancellation
- fallback behavior

Performance:
- memory pressure
- startup time
- token streaming latency

Regression:
- schema migration
- corrupted model file recovery

## Roadmap

### Milestone 1 (MVP)
2–3 weeks

Deliver:
- runtime integration
- AI chat
- structured tools
- dashboard insights

### Milestone 2
2 weeks

Deliver:
- embeddings
- semantic search
- summaries

### Milestone 3
2 weeks

Deliver:
- contextual AI in people/money/promises

### Milestone 4
future

Deliver:
- proactive intelligence
- premium larger model tier

## Out of Scope (Now)
- voice AI
- image understanding
- cloud sync AI
- multi-agent workflows
- autonomous background actions

## Final Recommendation
Build focused commitment intelligence first.
Do not attempt a generic assistant.
