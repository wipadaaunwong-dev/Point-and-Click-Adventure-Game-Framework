import 'package:flutter/foundation.dart';

class InventoryManager extends ChangeNotifier {
  final List<String> _items = [];
  String? _selectedItem;

  List<String> get items => List.unmodifiable(_items);
  String? get selectedItem => _selectedItem;

  void addItem(String itemId) {
    if (!_items.contains(itemId)) {
      _items.add(itemId);
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    if (_selectedItem == itemId) {
      _selectedItem = null;
    }
    notifyListeners();
  }

  void selectItem(String? itemId) {
    if (_selectedItem == itemId) {
      _selectedItem = null;
    } else {
      _selectedItem = itemId;
    }
    notifyListeners();
  }

  bool hasItem(String itemId) => _items.contains(itemId);
}