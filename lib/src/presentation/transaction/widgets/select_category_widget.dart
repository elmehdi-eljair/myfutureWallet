import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../domain/category/entities/category.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../main.dart';
import '../../../app/routes.dart';
import '../../../core/common.dart';
import '../../../data/category/model/category_model.dart';
import '../bloc/transaction_bloc.dart';

class SelectCategoryIcon extends StatelessWidget {
  const SelectCategoryIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<CategoryModel>>(
      valueListenable: getIt.get<Box<CategoryModel>>().listenable(),
      builder: (context, value, child) {
        final List<Category> categories = value.values.toEntities();

        if (categories.isEmpty) {
          return ListTile(
            onTap: () => context.pushNamed(addCategoryPath),
            title: Text(context.loc.addCategoryEmptyTitle),
            subtitle: Text(context.loc.addCategoryEmptySubTitle),
            trailing: const Icon(Icons.keyboard_arrow_right),
          );
        }

        return ScreenTypeLayout(
          tablet: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.loc.selectCategory,
                  style: context.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SelectedItem(categories: categories)
            ],
          ),
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.loc.selectCategory,
                  style: context.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SelectedItem(categories: categories)
            ],
          ),
        );
      },
    );
  }
}

class SelectedItem extends StatelessWidget {
  const SelectedItem({
    super.key,
    required this.categories,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final expenseBloc = BlocProvider.of<TransactionBloc>(context);
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: List.generate(
              categories.length + 1,
              (index) {
                if (index == 0) {
                  return CategoryChip(
                    selected: false,
                    onSelected: (p0) => context.pushNamed(addCategoryPath),
                    icon: MdiIcons.plus.codePoint,
                    title: context.loc.addNew,
                    iconColor: context.primary,
                    titleColor: context.primary,
                  );
                } else {
                  final Category category = categories[index - 1];
                  final bool selected =
                      category.superId == expenseBloc.selectedCategoryId;
                  return CategoryChip(
                    selected: selected,
                    onSelected: (value) =>
                        expenseBloc.add(ChangeCategoryEvent(category)),
                    icon: category.icon,
                    title: category.name,
                    titleColor: Color(category.color ?? context.primary.value),
                    iconColor: Color(category.color ?? context.primary.value),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.titleColor,
  });

  final int icon;
  final Function(bool) onSelected;
  final bool selected;
  final String title;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      selectedColor: selected ? titleColor.withOpacity(0.2) : null,
      avatar: Icon(
        color: iconColor,
        IconData(
          icon,
          fontFamily: fontFamilyName,
          fontPackage: fontFamilyPackageName,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          width: 1,
          color: context.primary,
        ),
      ),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(title),
      labelStyle:
          Theme.of(context).textTheme.titleMedium?.copyWith(color: titleColor),
      padding: const EdgeInsets.all(12),
    );
  }
}
