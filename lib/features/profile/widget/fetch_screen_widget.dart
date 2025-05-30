//-------------------Favorites user-----------------------
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class FavoritesListTile extends StatelessWidget {
  const FavoritesListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: Icon(CupertinoIcons.forward),
      leading: Icon(HugeIcons.strokeRoundedFavouriteSquare),
      title: Text(
        EnumLocale.favorites.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//-------------------Archive user-----------------------
class ArchiveListTile extends StatelessWidget {
  const ArchiveListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: Icon(CupertinoIcons.forward),
      leading: Icon(HugeIcons.strokeRoundedArchive),
      title: Text(
        EnumLocale.archive.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//-------------------Blocked user-----------------------
class BlockedListTile extends StatelessWidget {
  const BlockedListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: Icon(CupertinoIcons.forward),
      leading: Icon(HugeIcons.strokeRoundedBlocked),
      title: Text(
        EnumLocale.blocked.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
