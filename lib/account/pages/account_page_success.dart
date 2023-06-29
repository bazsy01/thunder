import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

const List<Widget> userOptionTypes = <Widget>[
  Padding(padding: EdgeInsets.all(8.0), child: Text('Posts')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Comments')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Saved')),
];

class AccountPageSuccess extends StatefulWidget {
  final AccountState accountState;

  const AccountPageSuccess({super.key, required this.accountState});

  @override
  State<AccountPageSuccess> createState() => _AccountPageSuccessState();
}

class _AccountPageSuccessState extends State<AccountPageSuccess> {
  int selectedUserOption = 0;
  final List<bool> _selectedUserOption = <bool>[true, false, false];
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<AccountBloc>().add(const GetAccountContent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CommunityBloc(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: theme.primaryColor,
            foregroundImage: widget.accountState.personView?.person.avatar != null ? ExtendedNetworkImageProvider(widget.accountState.personView!.person.avatar!) : null,
            maxRadius: 60,
          ),
          const SizedBox(height: 24),
          Text(
            widget.accountState.personView?.person.displayName ?? widget.accountState.personView!.person.name,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${formatNumberToK(widget.accountState.personView!.counts.postScore)} · ${formatNumberToK(widget.accountState.personView!.counts.commentScore)} · ${formatTimeToString(dateTime: widget.accountState.personView!.person.published.toIso8601String())}',
            style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.labelMedium?.color?.withAlpha(200)),
          ),
          const SizedBox(height: 8),
          ToggleButtons(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                // The button that is tapped is set to true, and the others to false.
                for (int i = 0; i < _selectedUserOption.length; i++) {
                  _selectedUserOption[i] = i == index;
                }
                selectedUserOption = index;
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / userOptionTypes.length) - 12.0),
            isSelected: _selectedUserOption,
            children: userOptionTypes,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedUserOption == 0
                ? PostCardList(
                    postViews: widget.accountState.posts,
                    hasReachedEnd: widget.accountState.personView?.counts.postCount == widget.accountState.posts.length,
                  )
                : selectedUserOption == 1
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        child: CommentSubview(comments: widget.accountState.comments ?? []),
                      )
                    : Container(),
          ),
        ],
      ),
    );
  }
}