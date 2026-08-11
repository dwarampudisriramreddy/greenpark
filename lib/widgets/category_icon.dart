import 'package:flutter/material.dart';

/// Maps the icon name stored in the CMS to a Material icon.
IconData categoryIcon(String? icon) {
  switch (icon) {
    case 'tapas':
      return Icons.tapas_rounded;
    case 'soup':
      return Icons.soup_kitchen_rounded;
    case 'rice':
      return Icons.rice_bowl_rounded;
    case 'ramen':
      return Icons.ramen_dining_rounded;
    case 'curry':
      return Icons.dinner_dining_rounded;
    case 'grill':
      return Icons.outdoor_grill_rounded;
    case 'chinese':
      return Icons.takeout_dining_rounded;
    case 'veg':
      return Icons.eco_rounded;
    case 'nonveg':
      return Icons.egg_alt_rounded;
    case 'dessert':
      return Icons.icecream_rounded;
    case 'cafe':
      return Icons.local_cafe_rounded;
    default:
      return Icons.restaurant_menu_rounded;
  }
}
