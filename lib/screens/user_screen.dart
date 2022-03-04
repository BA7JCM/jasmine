import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/login.dart';
import 'package:jasmine/configs/versions.dart';
import 'package:jasmine/screens/components/avatar.dart';
import 'package:jasmine/screens/components/badge.dart';
import 'package:jasmine/screens/view_log_screen.dart';

import 'downloads_screen.dart';
import 'favorites_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loginEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    loginEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("个人中心"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildCard(),
            const Divider(),
            _buildFavorites(),
            const Divider(),
            _buildViewLog(),
            const Divider(),
            _buildDownloads(),
            const Divider(),
            Container(height: 30),
            _buildVersion(),
            Container(height: 30),
            _buildVersionText(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    late Widget child;
    switch (loginStatus) {
      case LoginStatus.notSet:
        child = _buildLoginButton("登录 / 注册");
        break;
      case LoginStatus.logging:
        child = _buildLoginLoading();
        break;
      case LoginStatus.loginSuccess:
        child = _buildSelfInfoCard();
        break;
      case LoginStatus.loginField:
        child = _buildLoginButton("登录失败/点击重试");
        break;
    }
    return Container(
      height: 200,
      color: Color.alphaBlend(
        Colors.grey.withOpacity(.1),
        Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
      ),
      child: Center(
        child: child,
      ),
    );
  }

  Widget _buildLoginButton(String title) {
    return MaterialButton(
      onPressed: () async {
        await loginDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: .5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLoading() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Icon(Icons.refresh,
            size: size * .5, color: Colors.white.withOpacity(.5));
      },
    );
  }

  Widget _buildSelfInfoCard() {
    return Column(
      children: [
        Expanded(child: Container()),
        Center(
          child: Avatar(selfInfo.photo),
        ),
        Container(height: 10),
        Center(
          child: Text(
            selfInfo.username,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildFavorites() {
    return ListTile(
      onTap: () async {
        if (LoginStatus.loginSuccess == loginStatus) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return const FavoritesScreen();
            },
          ));
        } else {
          defaultToast(context, "登录之后才能使用收藏夹喔");
        }
      },
      title: const Text("收藏夹"),
    );
  }

  Widget _buildViewLog() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const ViewLogScreen();
          },
        ));
      },
      title: const Text("浏览记录"),
    );
  }

  Widget _buildDownloads() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const DownloadsScreen();
          },
        ));
      },
      title: const Text("下载列表"),
    );
  }

  Widget _buildVersion() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: VersionBadged(
            child: MaterialButton(
              color: Colors.grey.shade200,
              onPressed: () {
                openUrl("https://github.com/niuhuan/jasmine/releases/");
              },
              child: SizedBox(
                width: constraints.maxWidth - 30,
                height: 80,
                child: Center(
                  child: Text(
                    (latestVersion == null
                        ? "没有检测到新版本"
                        : "检测到新版本 : $latestVersion") +
                        "\n(点击这里去下载页面)",
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildVersionText() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: SizedBox(
            width: constraints.maxWidth - 30,
            child: Center(
              child: SelectableText(latestVersionInfo() ?? ""),
            ),
          ),
        );
      },
    );
  }
}
