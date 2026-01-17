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
      return 'https://images.unsplash.com/photo-1743517894265-c86ab035adef?q=80&w=1982&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('idli')) {
      return 'https://images.unsplash.com/photo-1632104667384-06f58cb7ad44?q=80&w=860&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('vada')) {
      return 'https://images.unsplash.com/photo-1730191843435-073792ba22bc?q=80&w=627&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('biriyani')) {
      return 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?q=80&w=1188&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('chicken')) {
      return 'https://images.unsplash.com/photo-1747518596416-2da5e5218d83';
    } else if (name.toLowerCase().contains('parotta')) {
      return 'https://images.unsplash.com/photo-1683533743190-89c9b19f9ea6?q=80&w=1169&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('rice')) {
      return 'https://images.unsplash.com/photo-1512058564366-18510be2db19';
    } else if (name.toLowerCase().contains('omelette')) {
      return 'https://images.unsplash.com/photo-1646579933415-92109f9805df?q=80&w=1057&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('meals')) {
      return 'https://images.unsplash.com/photo-1666251214795-a1296307d29c?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('poori')) {
      return 'https://images.unsplash.com/photo-1643892467625-65df6a500524?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('pongal')) {
      return 'https://images.unsplash.com/photo-1716801551616-c458ec2a9b92?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('chappathi')) {
      return 'https://images.unsplash.com/photo-1600935926387-12d9b03066f0?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (name.toLowerCase().contains('noodles')) {
      return 'https://images.unsplash.com/photo-1553621043-f607bfbf6640?q=80&w=1026&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    }
    return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38';
  }
}
