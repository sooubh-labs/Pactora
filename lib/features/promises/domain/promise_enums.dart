enum PromiseStatus { pending, completed, overdue, delayed, cancelled, ignored }

enum PromiseCategory {
  money,
  task,
  meeting,
  callback,
  delivery,
  document,
  errand,
  study,
  personal,
  other
}

enum Priority { low, medium, high }

enum PromiseType { iPromised, theyPromised }

enum ItemStatus { active, returned, overdue, lost }

enum MoneyStatus { pending, paid, partial, cancelled }

enum RecurrenceType { none, daily, weekly, monthly, yearly }
