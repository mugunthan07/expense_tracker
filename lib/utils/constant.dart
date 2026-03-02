class AppConstants {
  // App Info
  static const String appName = 'MG Expense Tracker';
  static const String appVersion = '1.0.0';

  // Payment Types
  static const List<String> paymentTypes = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Online Transfer',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Visa',
    'Mastercard',
    'Amex',
    'Rupay',
    'UPI',
  ];

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String expensesSubCollection = 'expenses';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String invalidEmail = 'Please enter a valid email';
  static const String amountRequired = 'Amount is required';
  static const String invalidAmount = 'Please enter a valid amount';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';

  // Success Messages
  static const String expenseAddedSuccess = 'Expense added successfully';
  static const String expenseUpdatedSuccess = 'Expense updated successfully';
  static const String expenseDeletedSuccess = 'Expense deleted successfully';
  static const String logoutSuccess = 'Logged out successfully';
}