// lib/components/menu_manager.dart
import 'menu_model.dart';
import 'menu_data.dart';
import 'package:flutter/foundation.dart';

class MenuManager {
  static final MenuManager _instance = MenuManager._internal();

  factory MenuManager() {
    return _instance;
  }

  MenuManager._internal() {
    _initializeMenuItems();
  }

  final List<MenuItem> _allMenuItems = [];
  final List<VoidCallback> _listeners = [];

  List<MenuItem> get allMenuItems => List.unmodifiable(_allMenuItems);

  List<MenuItem> get activeMenuItems =>
      _allMenuItems.where((item) => item.isActive && item.isAvailable).toList();

  List<MenuItem> get breakfastItems =>
      activeMenuItems.where((item) => item.category == 'breakfast').toList();

  List<MenuItem> get lunchItems =>
      activeMenuItems.where((item) => item.category == 'lunch').toList();

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void toggleItemAvailability(String itemId, bool isActive) {
    final itemIndex = _allMenuItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      _allMenuItems[itemIndex].isActive = isActive;
      notifyListeners();
    }
  }

  void toggleItemStock(String itemId, bool isAvailable) {
    final itemIndex = _allMenuItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      _allMenuItems[itemIndex].isAvailable = isAvailable;
      notifyListeners();
    }
  }

  void _initializeMenuItems() {
    // Clear existing items
    _allMenuItems.clear();

    _allMenuItems.addAll(
      abiruchiFoodWorksMenu.map((data) {
        final item = MenuItem.fromData(
          name: data.name,
          price: data.price,
          quantity: data.quantity,
          category: data.category,
          isVeg: data.isVeg,
          description: data.description,
          imageUrl: data.imageUrl,
        );
        // Respect static availability defaults.
        item.isAvailable = data.isAvailable;
        return item;
      }),
    );
  }
}
