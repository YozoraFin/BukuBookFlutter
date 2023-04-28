import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/articlelist.dart';
import 'package:login_page/cart.dart';
import 'package:login_page/dashboard.dart';
import 'package:login_page/homepage.dart';
import 'package:login_page/katalog.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({
    this.initial = 0,
    this.kategori = '',
    Key? key
  }):super(key: key);
  
  final String kategori;
  final int initial;

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  GlobalKey<CartState> cartKey = GlobalKey<CartState>();

  PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  final box = GetStorage();

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const Katalog(),
      const Dashboard(),
      ArticleList(sKategori: widget.kategori,),
      Cart(key: cartKey,),
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
        icon: const Icon(CupertinoIcons.person),
        title: 'Akun',
        activeColorPrimary: CupertinoColors.activeBlue,
        activeColorSecondary: CupertinoColors.white,
        inactiveColorPrimary: CupertinoColors.inactiveGray,
      ),
      
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.news),
        title: 'Artikel',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.cart),
        title: 'Keranjang',
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.inactiveGray,
        onPressed: (context) {
          cartKey.currentState?.getCart();
          _controller.jumpToTab(4);
        }
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = PersistentTabController(initialIndex: widget.initial);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context, 
      controller: _controller,
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
      navBarStyle: NavBarStyle.style15,
    );
  }
}