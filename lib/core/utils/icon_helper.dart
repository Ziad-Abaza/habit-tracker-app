import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(int codePoint) {
    // Map icon code points to constant IconData references for tree shaking
    switch (codePoint) {
      case 0xe889: // Icons.work
        return Icons.work;
      case 0xe8bc: // Icons.school
        return Icons.school;
      case 0xeb43: // Icons.fitness_center
        return Icons.fitness_center;
      case 0xe561: // Icons.restaurant
        return Icons.restaurant;
      case 0xe88a: // Icons.home
        return Icons.home;
      case 0xe8cc: // Icons.shopping_cart
        return Icons.shopping_cart;
      case 0xe539: // Icons.local_hospital
        return Icons.local_hospital;
      case 0xe052: // Icons.flight
        return Icons.flight;
      case 0xe405: // Icons.music_note
        return Icons.music_note;
      case 0xe865: // Icons.book
        return Icons.book;
      case 0xe3af: // Icons.folder
        return Icons.folder;
      case 0xe8b6: // Icons.sports
        return Icons.sports;
      case 0xe55a: // Icons.business
        return Icons.business;
      case 0xe7f1: // Icons.person
        return Icons.person;
      case 0xe7fd: // Icons.pets
        return Icons.pets;
      case 0xe5d2: // Icons.directions_car
        return Icons.directions_car;
      case 0xe85d: // Icons.favorite
        return Icons.favorite;
      case 0xe8b8: // Icons.star
        return Icons.star;
      case 0xe25b: // Icons.settings
        return Icons.settings;
      case 0xe0af: // Icons.access_time
        return Icons.access_time;
      case 0xe55b: // Icons.event
        return Icons.event;
      case 0xe7c5: // Icons.delete_outline
        return Icons.delete_outline;
      case 0xe145: // Icons.add
        return Icons.add;
      case 0xe8b7: // Icons.category
        return Icons.category;
      default:
        // For unknown icons, use a default icon instead of dynamic creation
        return Icons.help_outline;
    }
  }
}
