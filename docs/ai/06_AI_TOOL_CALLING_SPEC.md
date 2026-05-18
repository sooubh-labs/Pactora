# AI Tool Calling Specification

AI never directly mutates data.

Rules:
- deterministic tools only
- user confirmation for writes
- structured outputs only

Tools:
- listPromises
- getOverduePromises
- listDebts
- listBorrowedItems
- searchPeople
- getPersonHistory
- createReminderDraft
- createReminder
