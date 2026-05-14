# 05. Database Schema — Pactora (Isar)

## 1. Collection: `Person`
The core entity for all relational commitments.
- `Id id`: Auto-increment.
- `String name`: **Indexed**. Primary display name.
- `String? phone`: Optional contact number.
- `String? avatarPath`: Local path to a profile image.
- `DateTime createdAt`: Timestamp of creation.

## 2. Collection: `Promise`
- `Id id`: Auto-increment.
- `String title`: **Indexed**.
- `int personId`: Link to `Person.id`.
- `bool iMadeThisPromise`: Direction flag.
- `PromiseStatus status`: Enum (Pending, Completed, Overdue, Cancelled).
- `PromiseCategory category`: Enum (Task, Payment, Meeting, etc.).
- `Priority priority`: Enum (Low, Medium, High).
- `DateTime? dueDate`: The deadline.
- `List<String> attachmentPaths`: Local file paths.

## 3. Collection: `BorrowItem`
- `Id id`: Auto-increment.
- `String name`: **Indexed**.
- `int personId`: Link to `Person.id`.
- `bool iLent`: Direction flag.
- `ItemStatus status`: Enum (Active, Overdue, Returned, Lost).
- `String? photoPath`: Primary item photo.
- `double? estimatedValue`: Valuation in local currency.
- `DateTime? expectedReturn`: Deadline for return.

## 4. Collection: `MoneyRecord`
- `Id id`: Auto-increment.
- `int personId`: Link to `Person.id`.
- `double amount`: The total amount.
- `double paidAmount`: Amount repaid so far (for progress tracking).
- `bool iOwe`: Direction flag.
- `MoneyStatus status`: Enum (Pending, Partial, Settled).
- `String currency`: 3-letter currency code.

## Enum Definitions
- **PromiseStatus:** `pending`, `completed`, `overdue`, `cancelled`.
- **ItemStatus:** `active`, `overdue`, `returned`, `lost`.
- **MoneyStatus:** `pending`, `partial`, `settled`.
- **Priority:** `low`, `medium`, `high`.
