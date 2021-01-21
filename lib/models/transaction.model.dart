enum TransactionPriority { slow, standard, fast }

extension TransactionPriorityExt on TransactionPriority {
  int get value {
    switch (this) {
      case TransactionPriority.slow:
        return 1;
      case TransactionPriority.standard:
        return 2;
      case TransactionPriority.fast:
        return 3;
    }
  }
}
