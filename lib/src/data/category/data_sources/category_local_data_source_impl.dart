import 'package:collection/collection.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:injectable/injectable.dart';

import '../model/category_model.dart';
import 'category_local_data_source.dart';

@Singleton(as: CategoryLocalDataManager)
class LocalCategoryManagerDataSourceImpl implements CategoryLocalDataManager {
  LocalCategoryManagerDataSourceImpl(this.categoryBox);

  final Box<CategoryModel> categoryBox;

  @override
  Future<void> add(CategoryModel category) async {
    final int id = await categoryBox.add(category);
    category.superId = id;
    return category.save();
  }

  @override
  Future<List<CategoryModel>> categories() async {
    return categoryBox.values.where((element) => !element.isDefault).toList();
  }

  @override
  Future<void> clear() => categoryBox.clear();

  @override
  List<CategoryModel> defaultCategories() {
    return categoryBox.values.where((element) => element.isDefault).toList();
  }

  @override
  Future<void> delete(int key) async {
    await categoryBox.delete(key);
  }

  @override
  Iterable<CategoryModel> export() => categoryBox.values;

  @override
  CategoryModel? findById(int categoryId) =>
      categoryBox.values.firstWhereOrNull(
        (element) => element.superId == categoryId,
      );

  @override
  Future<void> update(CategoryModel categoryModel) {
    return categoryBox.put(categoryModel.superId!, categoryModel);
  }
}
