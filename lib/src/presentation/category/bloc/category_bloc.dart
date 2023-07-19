import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/category/model/category_model.dart';
import '../../../domain/category/entities/category.dart';
import '../../../domain/category/use_case/category_use_case.dart';
import '../../../domain/expense/use_case/expense_use_case.dart';

part 'category_event.dart';
part 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required this.getCategoryUseCase,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.deleteExpensesFromCategoryIdUseCase,
    required this.updateCategoryUseCase,
  }) : super(AddCategoryInitial()) {
    on<CategoryEvent>((event, emit) {});
    on<FetchCategoryFromIdEvent>(_fetchCategoryFromId);
    on<AddOrUpdateCategoryEvent>(_addOrUpdateCategory);
    on<CategoryDeleteEvent>(_deleteCategory);
    on<CategoryIconSelectedEvent>(_categoryIcon);
    on<UpdateCategoryBudgetEvent>(_updateCategoryBudget);
    on<CategoryColorSelectedEvent>(_updateCategoryColor);
  }

  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final DeleteExpensesFromCategoryIdUseCase deleteExpensesFromCategoryIdUseCase;
  final GetCategoryUseCase getCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;

  double? categoryBudget;
  String? categoryDesc;
  String? categoryTitle;
  Category? currentCategory;
  bool isBudgetSet = false;
  bool isDefault = false;
  int? selectedColor;
  int? selectedIcon;

  Future<void> _fetchCategoryFromId(
    FetchCategoryFromIdEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final int? categoryId = int.tryParse(event.categoryId ?? '');
    if (categoryId == null) return;

    final Category? category = getCategoryUseCase(categoryId);
    if (category != null) {
      categoryTitle = category.name;
      categoryDesc = category.description;
      categoryBudget = category.budget;
      selectedIcon = category.icon;
      currentCategory = category;
      isBudgetSet = category.isBudget;
      selectedColor = category.color ?? Colors.red.shade100.value;
      emit(CategorySuccessState(category));
    }
  }

  FutureOr<void> _addOrUpdateCategory(
    AddOrUpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final String? title = categoryTitle;
    final String? description = categoryDesc;
    final int? icon = selectedIcon;
    final double? budget = categoryBudget;
    final bool setBudget = isBudgetSet;
    final int? color = selectedColor;
    if (icon == null) {
      return emit(const CategoryErrorState('Select category icon'));
    }
    if (title == null) {
      return emit(const CategoryErrorState('Add category title'));
    }

    if (color == null) {
      return emit(const CategoryErrorState('Select category color'));
    }
    if (event.isAddOrUpdate) {
      await addCategoryUseCase(
        icon: icon,
        desc: description,
        name: title,
        budget: budget ?? 0,
        isBudget: setBudget,
        color: color,
        isDefault: isDefault,
      );
    } else {
      if (currentCategory == null) return;

      currentCategory!
        ..budget = budget ?? 0
        ..description = description ?? ''
        ..icon = icon
        ..isBudget = setBudget
        ..color = color
        ..isDefault = isDefault
        ..name = title;

      await updateCategoryUseCase(currentCategory!);
    }
    emit(CategoryAddedState(isCategoryAddedOrUpdate: event.isAddOrUpdate));
  }

  Future<void> _deleteCategory(
    CategoryDeleteEvent event,
    Emitter<CategoryState> emit,
  ) async {
    await deleteCategoryUseCase(int.parse(event.categoryId));
    await deleteExpensesFromCategoryIdUseCase(int.parse(event.categoryId));
    emit(CategoryDeletedState());
  }

  FutureOr<void> _categoryIcon(
    CategoryIconSelectedEvent event,
    Emitter<CategoryState> emit,
  ) {
    selectedIcon = event.categoryIcon;
    emit(CategoryIconSelectedState(event.categoryIcon));
  }

  FutureOr<void> _updateCategoryBudget(
    UpdateCategoryBudgetEvent event,
    Emitter<CategoryState> emit,
  ) {
    isBudgetSet = event.isBudget;
    emit(UpdateCategoryBudgetState(event.isBudget));
  }

  FutureOr<void> _updateCategoryColor(
    CategoryColorSelectedEvent event,
    Emitter<CategoryState> emit,
  ) {
    selectedColor = event.categoryColor;
    emit(CategoryColorSelectedState(event.categoryColor));
  }
}
