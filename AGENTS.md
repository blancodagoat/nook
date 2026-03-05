# AGENTS.md - Nook Expense Tracker

## Project Overview

Nook is a premium Flutter expense and income tracking app with a dark theme and glass-morphism UI design.

- **Flutter**: >=3.22.0
- **Dart SDK**: >=3.4.0 <4.0.0

## Build/Lint/Test Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Run on specific device
flutter run -d windows
flutter run -d chrome

# Build for production
flutter build windows
flutter build web
flutter build apk
flutter build ios

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Run a single test by name
flutter test --name "testName" test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Run linter (static analysis)
flutter analyze

# Fix lint issues automatically where possible
dart fix --apply

# Generate code (Isar models, JSON serializers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean build artifacts
flutter clean
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # GoRouter config, MaterialApp
├── core/
│   ├── constants/            # AppColors, AppTextStyles, AppSpacing, CategoryMeta
│   ├── theme/                # AppTheme
│   ├── utils/                # Utility functions (gradient_utils.dart)
│   └── extensions/           # Extension methods (date_extensions, double_extensions)
├── data/
│   ├── models/               # Data models (transaction.dart, transaction.g.dart)
│   └── repositories/         # Repository interfaces and implementations
├── features/
│   ├── dashboard/            # Dashboard screen + providers
│   ├── history/              # Transaction history screen
│   ├── summary/              # Summary/statistics screen
│   └── add_transaction/      # Add transaction bottom sheet
└── shared/
    └── widgets/              # Reusable UI components
test/
└── widget_test.dart          # Test files
```

## Code Style Guidelines

### Imports

```dart
// 1. Package imports (alphabetical)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 2. Absolute project imports (alphabetical)
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/data/models/transaction.dart';

// 3. Relative imports (alphabetical)
import '../models/transaction.dart';
import 'transaction_repository_interface.dart';
```

### Naming Conventions

- **Files**: snake_case.dart (e.g., `transaction_repository.dart`, `add_transaction_sheet.dart`)
- **Classes**: PascalCase (e.g., `TransactionRepository`, `AddTransactionSheet`)
- **Variables/Functions**: camelCase (e.g., `selectedMonth`, `getTotalByType`)
- **Private members**: Prefix with underscore (e.g., `_isExpense`, `_selectedCategory`)
- **Constants**: camelCase for const values, PascalCase for const classes (e.g., `AppColors`, `CategoryData`)
- **Providers**: Suffix with `Provider` (e.g., `dashboardStatsProvider`, `transactionRepositoryProvider`)

### Widget Patterns

```dart
class NookCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NookCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ...
      ),
    );
  }
}
```

- Always use `const` constructors where possible
- Use `super.key` for key parameter
- Required parameters use `required` keyword
- Optional parameters come after required ones
- Default values provided inline for optional parameters

### State Management (Riverpod)

```dart
// Simple state
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Async data
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return DashboardStats(/* ... */);
});

// Notifier for mutations
class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  TransactionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  final TransactionRepository _repository;
  final Ref _ref;

  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      await _repository.insert(transaction);
      state = const AsyncValue.data(null);
      _ref.invalidate(dashboardStatsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

### Repository Pattern

```dart
// Interface (abstract class)
abstract class TransactionRepository {
  Future<int> insert(Transaction transaction);
  Future<List<Transaction>> getAll();
  Future<void> clearAll();
}

// Implementation
class TransactionRepositoryIsar implements TransactionRepository {
  Isar? _isar;

  Future<Isar> get _db async {
    // Lazy initialization
  }

  @override
  Future<int> insert(Transaction transaction) async {
    final isar = await _db;
    return await isar.writeTxn(() async {
      return await isar.transactions.put(transaction);
    });
  }
}
```

### Models

```dart
@collection
class Transaction {
  Id? id;
  
  String title;
  double amount;
  String type;
  String category;
  DateTime date;
  String? note;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  // Computed properties
  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  // copyWith for immutability
  Transaction copyWith({/* ... */}) {
    return Transaction(/* ... */);
  }
}
```

### Error Handling

- Use `AsyncValue` for async state with built-in error handling
- Show user-friendly error dialogs:
```dart
void _showError(String message) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
```

### UI/Styling

- Use `AppColors` constants instead of hardcoded colors
- Use `AppTextStyles` for consistent typography
- Use `AppSpacing` for consistent spacing values
- Dark theme only (no light theme support)
- Glass-morphism effects with `frost` colors and transparency
- Animations use `flutter_animate` package

### Testing

- Tests use `flutter_test` and `mocktail` for mocking
- Test files mirror lib structure in test/ directory
- Use `group()` and `test()`/`testWidgets()` for organization

### Linting

Project uses `very_good_analysis` 6.0.0 with:
- `public_member_api_docs: false`
- `lines_longer_than_80_chars: false`

Run `flutter analyze` before committing to catch issues.

## Key Dependencies

| Purpose | Package |
|---------|---------|
| State | flutter_riverpod |
| Navigation | go_router |
| Database | isar, isar_flutter_libs |
| Charts | fl_chart |
| Animations | flutter_animate |
| Forms | intl, currency_text_input_formatter |
| Testing | mocktail |
| Linting | very_good_analysis |
| Code Gen | build_runner, isar_generator, json_serializable |

## Notes for Agents

- After modifying Isar models, run: `flutter pub run build_runner build --delete-conflicting-outputs`
- All UI follows dark theme conventions using `AppColors.bg` as background
- Categories are defined in `CategoryData` class with emojis and colors
- Date formatting uses custom extensions in `core/extensions/date_extensions.dart`
