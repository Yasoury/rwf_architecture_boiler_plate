import 'package:article_list/src/l10n/article_list_localizations.dart';
import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:article_list/article_list.dart';
import 'package:article_list/src/article_list_bloc.dart';

const _itemSpacing = Spacing.xSmall;

class FilterHorizontalList extends StatelessWidget {
  const FilterHorizontalList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          ...Tag.values.map(
            (tag) => _TagChip(tag: tag),
          ),
        ]),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
  });

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final isLastTag = Tag.values.last == tag;
    return Padding(
      padding: EdgeInsets.only(
        right: isLastTag ? 0 : _itemSpacing,
      ),
      child: BlocSelector<ArticleListBloc, ArticleListState, Tag?>(
        selector: (state) {
          final filter = state.filter;
          final selectedTag =
              filter is ArticleListFilterByTag ? filter.tag : null;
          return selectedTag;
        },
        builder: (context, selectedTag) {
          final isSelected = selectedTag == tag;
          return RoundedChoiceChip(
            label: tag.toLocalizedString(context),
            isSelected: isSelected,
            onSelected: (isSelected) {
              _releaseFocus(context);
              final bloc = context.read<ArticleListBloc>();
              bloc.add(
                ArticleListTagChanged(
                  isSelected ? tag : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _releaseFocus(BuildContext context) {
  FocusScope.of(context).unfocus();
}

extension on Tag {
  String toLocalizedString(BuildContext context) {
    final l10n = ArticleListLocalizations.of(context);
    switch (this) {
      case Tag.technology:
        return l10n.technologyTagLabel;
      case Tag.business:
        return l10n.businessTagLabel;
      case Tag.startups:
        return l10n.startupsTagLabel;
      case Tag.science:
        return l10n.scienceTagLabel;
      case Tag.health:
        return l10n.healthTagLabel;
      case Tag.politics:
        return l10n.politicsTagLabel;
      case Tag.sports:
        return l10n.sportsTagLabel;
      case Tag.entertainment:
        return l10n.entertainmentTagLabel;
      case Tag.world:
        return l10n.worldTagLabel;
      case Tag.finance:
        return l10n.financeTagLabel;
      case Tag.cybersecurity:
        return l10n.cybersecurityTagLabel;
      case Tag.ai:
        return l10n.aiTagLabel;
      case Tag.climate:
        return l10n.climateTagLabel;
      case Tag.automotive:
        return l10n.automotiveTagLabel;
      case Tag.gaming:
        return l10n.gamingTagLabel;
    }
  }
}
