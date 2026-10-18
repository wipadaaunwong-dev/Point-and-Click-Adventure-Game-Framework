import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/inventory.dart';

class InventoryBar extends StatelessWidget {
  const InventoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryManager>(
      builder: (context, inventory, child) {
        if (inventory.items.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 70,
          color: Colors.black.withOpacity(0.8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: inventory.items.length,
            itemBuilder: (context, index) {
              final item = inventory.items[index];
              final isSelected = inventory.selectedItem == item;

              return GestureDetector(
                onTap: () => inventory.selectItem(item),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.grey[800],
                    border: Border.all(
                      color: isSelected ? Colors.yellow : Colors.white24,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}