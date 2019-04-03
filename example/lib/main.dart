import 'package:flutter/material.dart';
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';
import 'package:http/http.dart' as http;

const String APP_ID = 'INSERT_HERE_YOUR_APP_ID';
const String API_VERSION = '5.90';

final List<String> scopes = [
  VKPermission.FRIENDS,
  VKPermission.PHOTOS,
  VKPermission.OFFLINE,
];

void main() async {
  try {
    final vkSdk = await VKSdk.initialize(appId: APP_ID, apiVersion: API_VERSION);

    runApp(MyApp(vkSdk: vkSdk));
  } on VKSdkException catch (error) {
    print(error.message);
  }
}

class MyApp extends StatelessWidget {
  final VKSdk vkSdk;

  const MyApp({Key key, @required this.vkSdk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VK SDK | iOS Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen(vkSdk: vkSdk),
    );
  }
}

enum AuthState {
  IN_PROGRESS,
  LOGGED_IN,
  LOGGED_OUT,
}

class AuthScreen extends StatefulWidget {
  final VKSdk vkSdk;

  const AuthScreen({Key key, this.vkSdk}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  AuthState _authState = AuthState.IN_PROGRESS;
  VKUser _vkUser;

  @override
  void initState() {
    super.initState();

    widget.vkSdk.authorizationStateUpdated.listen((result) {
      setState(() {
        _vkUser = result.user;
        _authState = result.state == VKAuthorizationState.Authorized
            ? AuthState.LOGGED_IN
            : AuthState.LOGGED_OUT;
      });
    });

    widget.vkSdk.wakeUpSession(scopes).then((result) async {
      final accessToken = await widget.vkSdk.accessToken();

      setState(() {
        _vkUser = accessToken.localUser;
        _authState =
            result.state == VKAuthorizationState.Authorized && accessToken.localUser != null
                ? AuthState.LOGGED_IN
                : AuthState.LOGGED_OUT;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VK SDK | iOS Example')),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMessageText(),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageText() {
    if (_vkUser != null && _vkUser.firstName != null) {
      return Text('Hello, ${_vkUser.firstName}');
    }

    return Text('Press button to login');
  }

  Widget _buildButton() {
    switch (_authState) {
      case AuthState.IN_PROGRESS:
        return CircularProgressIndicator();

      case AuthState.LOGGED_IN:
        return Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.red,
              child: Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: _onLogoutButtoPressed,
            ),
            SizedBox(height: 10),
            RaisedButton(
              color: Colors.blue,
              child: Text('Test API Call', style: TextStyle(color: Colors.white)),
              onPressed: _onTestApiButtonPressed,
            ),
          ],
        );

      case AuthState.LOGGED_OUT:
      default:
        return RaisedButton(
          color: Colors.blue,
          child: Text('Login with VK', style: TextStyle(color: Colors.white)),
          onPressed: _onLoginButtonPressed,
        );
    }
  }

  void _onLogoutButtoPressed() async {
    setState(() => _authState = AuthState.IN_PROGRESS);

    await widget.vkSdk.forceLogout();
    final isLoggedIn = await widget.vkSdk.isLoggedIn();
    setState(() {
      _vkUser = null;
      _authState = isLoggedIn ? AuthState.LOGGED_IN : AuthState.LOGGED_OUT;
    });
  }

  void _onLoginButtonPressed() async {
    final isLoggedIn = await widget.vkSdk.isLoggedIn();
    if (isLoggedIn) {
      setState(() => _authState = AuthState.LOGGED_IN);
      return;
    }

    try {
      await widget.vkSdk.authorize(scopes, isSafariDisabled: false);
    } on VKSdkException catch (error) {
      print(error.message);
    }
  }

  void _onTestApiButtonPressed() async {
    final accessToken = await widget.vkSdk.accessToken();
    if (accessToken == null || accessToken.accessToken == null) {
      throw 'Access token is empty';
    }

    if (accessToken == null || accessToken.localUser?.id == null) {
      throw 'User ID not defined';
    }

    final apiUrl =
        'https://api.vk.com/method/users.get?user_ids=${accessToken.localUser.id}&fields=bdate&access_token=${accessToken.accessToken}&v=$API_VERSION';

    final response = await http.get(apiUrl);
    print(response.statusCode);
    print(response.body);
  }
}
