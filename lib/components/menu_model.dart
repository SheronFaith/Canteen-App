// lib/components/menu_model.dart
class MenuItem {
  final String id;
  final String name;
  String description;
  final double price;
  final String quantity; // e.g., "1", "250 grm", "400 grm"
  final String category; // "breakfast", "lunch"
  final bool isVeg;
  bool isAvailable;
  bool isActive;
  String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.isVeg,
    this.isAvailable = true,
    this.isActive = true,
    this.imageUrl,
  });

  // Factory method to create menu items from your data
  factory MenuItem.fromData({
    required String name,
    required double price,
    required String quantity,
    required String category,
    bool? isVeg,
    String? description,
    String? imageUrl,
  }) {
    // Generate ID from name
    String id = name.toLowerCase().replaceAll(' ', '_');

    // Determine if item is veg based on name/category
    bool vegStatus = isVeg ?? true;
    if (name.toLowerCase().contains('chicken') ||
        name.toLowerCase().contains('egg') ||
        name.toLowerCase().contains('nandu')) {
      vegStatus = false;
    }

    // Generate description if not provided
    String desc = description ?? _generateDescription(name, category);

    return MenuItem(
      id: id,
      name: name,
      description: desc,
      price: price,
      quantity: quantity,
      category: category,
      isVeg: vegStatus,
      isAvailable: true,
      isActive: true,
      imageUrl: imageUrl ?? _getDefaultImage(name),
    );
  }

  static String _generateDescription(String name, String category) {
    if (category == 'breakfast') {
      return 'South Indian Breakfast';
    } else if (category == 'lunch') {
      if (name.toLowerCase().contains('dosa')) {
        return 'South Indian Breakfast';
      } else if (name.toLowerCase().contains('briyani') ||
          name.toLowerCase().contains('fried rice')) {
        return 'Rice Dish';
      } else if (name.toLowerCase().contains('chicken')) {
        return 'Non-Veg Dish';
      } else if (name.toLowerCase().contains('paratha')) {
        return 'North Indian';
      }
      return 'Main Course';
    }
    return 'Delicious Food Item';
  }

  static String _getDefaultImage(String name) {
    if (name.toLowerCase().contains('dosa')) {
      return 'https://images.unsplash.com/photo-1741392076269-471898558663';
    } else if (name.toLowerCase().contains('idly')) {
      return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38';
    } else if (name.toLowerCase().contains('vada')) {
      return 'https://images.unsplash.com/photo-1589302168068-964664d93dc0';
    } else if (name.toLowerCase().contains('briyani')) {
      return 'https://images.unsplash.com/photo-1605843891101-4a60adc0fcfa';
    } else if (name.toLowerCase().contains('chicken')) {
      return 'https://images.unsplash.com/photo-1747518596416-2da5e5218d83';
    } else if (name.toLowerCase().contains('paratha')) {
      return 'https://images.unsplash.com/photo-1645112411341-6c9f6e04e822';
    } else if (name.toLowerCase().contains('rice')) {
      return 'https://images.unsplash.com/photo-1512058564366-18510be2db19';
    } else if (name.toLowerCase().contains('omelet')) {
      return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af';
    }
    return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38';
  }
}
