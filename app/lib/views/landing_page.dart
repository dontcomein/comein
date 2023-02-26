import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/views/explore/explore_page.dart';
import 'package:comein/views/room/room_list.dart';
import 'package:comein/views/room/room_setup.dart';
import 'package:comein/views/user/user_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

enum Page { rooms, explore, profile }

class _LandingPageState extends State<LandingPage> {
  Page currentPage = Page.rooms;
  PlatformTabController tabController = PlatformTabController();
  @override
  Widget build(BuildContext context) => PlatformTabScaffold(
        tabController: tabController,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Rooms",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        itemChanged: (index) =>
            setState(() => currentPage = Page.values[index]),
        appBarBuilder: (context, index) => PlatformAppBar(
          title: Text(getTitle()),
          trailingActions: [
            if (currentPage == Page.rooms)
              PlatformIconButton(
                icon: Icon(PlatformIcons(context).add),
                onPressed: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => const RoomSetup(),
                  ),
                ),
              ),
          ],
        ),
        bodyBuilder: (_, __) => getBody(),
      );

  String getTitle() {
    switch (currentPage) {
      case Page.profile:
        return "Profile";
      case Page.rooms:
        return "Rooms";
      case Page.explore:
        return "Explore";
    }
  }

  Widget getBody() {
    switch (currentPage) {
      case Page.profile:
        return UserView(
            appUser: AppUser.fromFirebaseUser(firebaseAuth.currentUser));
      case Page.rooms:
        return RoomList(rooms: dataModel.rooms);
      case Page.explore:
        return const ExplorePage();
    }
  }
}
