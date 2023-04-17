import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_page/articlelist.dart';
import 'package:login_page/homepage.dart';
import 'package:login_page/katalog.dart';
import 'package:login_page/login.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    this.initial = 0,
    this.kategori = '',
    Key? key
  }):super(key: key);
  
  final String kategori;
  final int initial;

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const Katalog(),
      ArticleList(sKategori: kategori,),
      const Login(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: 'Beranda',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.book),
        title: 'Katalog',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray
      ),
      
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.news),
        title: 'Artikel',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray
      ),
      
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person),
        title: 'Akun',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray
      ),
    ];
  }



  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context, 
      controller: PersistentTabController(initialIndex: initial),
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200)
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }
}