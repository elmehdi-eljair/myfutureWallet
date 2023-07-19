import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/common.dart';
import '../../../core/enum/card_type.dart';
import '../../../domain/account/entities/account.dart';
import '../../widgets/lava/lava_clock.dart';
import '../../widgets/paisa_bottom_sheet.dart';
import '../bloc/accounts_bloc.dart';
import 'account_card.dart';

class AccountPageViewWidget extends StatefulWidget {
  const AccountPageViewWidget({
    Key? key,
    required this.accounts,
  }) : super(key: key);

  final List<Account> accounts;

  @override
  State<AccountPageViewWidget> createState() => _AccountPageViewWidgetState();
}

class _AccountPageViewWidgetState extends State<AccountPageViewWidget>
    with AutomaticKeepAliveClientMixin {
  final PageController _controller = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LavaAnimation(
          child: SizedBox(
            height: 246,
            child: PageView.builder(
              padEnds: true,
              pageSnapping: true,
              key: const Key('accounts_page_view'),
              controller: _controller,
              itemCount: widget.accounts.length,
              onPageChanged: (index) {
                BlocProvider.of<AccountsBloc>(context)
                    .add(AccountSelectedEvent(widget.accounts[index]));
              },
              itemBuilder: (_, index) {
                return BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                    if (state is AccountSelectedState) {
                      final Account account = widget.accounts[index];
                      final String expense = state.expenses.totalExpense
                          .toFormateCurrency(context);
                      final String income =
                          state.expenses.totalIncome.toFormateCurrency(context);
                      final String totalBalance =
                          (state.expenses.fullTotal + account.initialAmount)
                              .toFormateCurrency(context);
                      return AccountCard(
                        key: ValueKey(account.hashCode),
                        expense: expense,
                        income: income,
                        totalBalance: totalBalance,
                        cardHolder: account.name,
                        bankName: account.bankName,
                        cardType: account.cardType ?? CardType.bank,
                        onDelete: () {
                          paisaAlertDialog(
                            context,
                            title: Text(
                              context.loc.dialogDeleteTitle,
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: context.loc.deleteAccount,
                                style: context.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: account.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmationButton: TextButton(
                              onPressed: () {
                                BlocProvider.of<AccountsBloc>(context).add(
                                    DeleteAccountEvent(
                                        account.superId!.toString()));
                                Navigator.pop(context);
                              },
                              child: Text(context.loc.delete),
                            ),
                          );
                        },
                        onTap: () {
                          context.pushNamed(
                            editAccountName,
                            pathParameters: <String, String>{
                              'aid': account.superId.toString()
                            },
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ),
        AccountPageViewDotsIndicator(
          pageController: _controller,
          accounts: widget.accounts,
        ),
      ],
    );
  }
}

class AccountPageViewDotsIndicator extends StatelessWidget {
  const AccountPageViewDotsIndicator({
    super.key,
    required this.pageController,
    required this.accounts,
  });

  final List<Account> accounts;
  final PageController pageController;

  Widget _indicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? context.primary : Theme.of(context).disabledColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.length == 1) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountSelectedState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(accounts.length, (index) {
                return GestureDetector(
                  onTap: () {
                    pageController.jumpToPage(index);
                  },
                  child: _indicator(
                    context,
                    accounts[index] == state.account,
                  ),
                );
              }),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
