import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCollectionScreenProvider with ChangeNotifier {
  int selectedIndex = 0;
  void setIndex(int i) {
    selectedIndex = i;
    notifyListeners();
  }

  int getIndex() => selectedIndex;

  List<String> images = [];

  void saveImage(String base64) {
    images[selectedIndex] = base64;

    notifyListeners();
  }

  void addImage(String base64) {
    images.add(base64);
    notifyListeners();
  }
}
