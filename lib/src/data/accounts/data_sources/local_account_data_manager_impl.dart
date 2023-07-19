import 'package:collection/collection.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:injectable/injectable.dart';

import '../model/account_model.dart';
import 'local_account_data_manager.dart';

@Singleton(as: AccountLocalDataManager)
class LocalAccountDataManagerImpl implements AccountLocalDataManager {
  LocalAccountDataManagerImpl({
    required this.accountBox,
  });

  final Box<AccountModel> accountBox;

  @override
  List<AccountModel> accounts() => accountBox.values.toList();

  @override
  Future<void> add(AccountModel account) async {
    final int id = await accountBox.add(account);
    account.superId = id;
    return await account.save();
  }

  @override
  Future<void> clear() => accountBox.clear();

  @override
  Future<void> delete(int key) async => accountBox.delete(key);

  @override
  Iterable<AccountModel> export() => accountBox.values;

  @override
  AccountModel? findById(int accountId) {
    return accountBox.values
        .firstWhereOrNull((element) => element.superId == accountId);
  }

  @override
  Future<void> update(AccountModel accountModel) {
    return accountBox.put(accountModel.superId!, accountModel);
  }
}
