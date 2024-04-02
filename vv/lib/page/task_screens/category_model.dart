

import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor = Color.fromARGB(255, 226, 226, 226);

  bool isSelected;

  CategoryModel({
    required this.name,
    required this.iconPath,
    this.isSelected = false,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: 'Capsule',
        iconPath: 'lib/page/task_screens/assets/icons/tablet.gif',
      ),
    );

    categories.add(CategoryModel(
      name: 'Tablet',
      iconPath: 'lib/page/task_screens/assets/icons/pills.gif',
    ));

    categories.add(CategoryModel(
      name: 'Liquid',
      iconPath: 'lib/page/task_screens/assets/icons/liquid.gif',
    ));

    categories.add(CategoryModel(
      name: 'Topical',
      iconPath: 'lib/page/task_screens/assets/icons/tube.gif',
    ));

    categories.add(CategoryModel(
      name: 'Cream',
      iconPath: 'lib/page/task_screens/assets/icons/cream.gif',
    ));

    categories.add(CategoryModel(
      name: 'Drops',
      iconPath: 'lib/page/task_screens/assets/icons/drops.gif',
    ));

    categories.add(CategoryModel(
      name: 'Foam',
      iconPath: 'lib/page/task_screens/assets/icons/foam.gif',
    ));

    categories.add(CategoryModel(
      name: 'Gel',
      iconPath: 'lib/page/task_screens/assets/icons/tube.gif',
    ));

    categories.add(CategoryModel(
      name: 'Herbal',
      iconPath: 'lib/page/task_screens/assets/icons/herbal.gif',
    ));

    categories.add(CategoryModel(
      name: 'Inhaler',
      iconPath: 'lib/page/task_screens/assets/icons/inhalator.gif',
    ));

    categories.add(CategoryModel(
      name: 'Injection',
      iconPath: 'lib/page/task_screens/assets/icons/syringe.gif',
    ));

    categories.add(CategoryModel(
      name: 'Lotion',
      iconPath: 'lib/page/task_screens/assets/icons/lotion.gif',
    ));

    categories.add(CategoryModel(
      name: 'Nasal Spray',
      iconPath: 'lib/page/task_screens/assets/icons/nasalspray.gif',
    ));

    categories.add(CategoryModel(
      name: 'Ointment',
      iconPath: 'lib/page/task_screens/assets/icons/tube.gif',
    ));

    categories.add(CategoryModel(
      name: 'Patch',
      iconPath: 'lib/page/task_screens/assets/icons/patch.gif',
    ));

    categories.add(CategoryModel(
      name: 'Powder',
      iconPath: 'lib/page/task_screens/assets/icons/powder.gif',
    ));

    categories.add(CategoryModel(
      name: 'Spray',
      iconPath: 'lib/page/task_screens/assets/icons/spray.gif',
    ));

    categories.add(CategoryModel(
      name: 'Suppository',
      iconPath: 'lib/page/task_screens/assets/icons/suppository.gif',
    ));

    return categories;
  }
}

