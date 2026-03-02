class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
}

// Predefined categories
class PredefinedCategories {
  static final List<Category> categories = [
    Category(
      id: '1',
      name: 'Food & Dining',
      icon: '🍽️',
      color: '#FF6B6B',
    ),
    Category(
      id: '2',
      name: 'Transportation',
      icon: '🚗',
      color: '#4ECDC4',
    ),
    Category(
      id: '3',
      name: 'Entertainment',
      icon: '🎬',
      color: '#95E1D3',
    ),
    Category(
      id: '4',
      name: 'Shopping',
      icon: '🛍️',
      color: '#FFE66D',
    ),
    Category(
      id: '5',
      name: 'Bills & Utilities',
      icon: '💡',
      color: '#A8E6CF',
    ),
    Category(
      id: '6',
      name: 'Health & Fitness',
      icon: '💪',
      color: '#FF8B94',
    ),
  ];
}