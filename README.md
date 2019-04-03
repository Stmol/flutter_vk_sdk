# Port of [vk-ios-sdk](https://github.com/VKCOM/vk-ios-sdk) for Flutter

A Flutter plugin for using the native iOS [VK SDK](https://github.com/VKCOM/vk-ios-sdk).

**This is not an official repository!** [Here](https://github.com/VKCOM) you can find platform native implemetations.

## Platform support

- **only for iOS >= 8.0**
- if you need Android support, use [flutter_vk_login](https://github.com/ObjReponse/flutter_vk_login)

## Installation

Add this to your package's pubspec.yaml file:
```
dependencies:
  flutter_vk_sdk:
    git: git@github.com:Stmol/flutter_vk_sdk.git
```

And then install it:
```
flutter packages get
```

Import lib in your Dart code:
```
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';
```

After that, you need to [create VK App](https://vk.com/dev) and configure schema of your application. Read how-to in official vk-ios-sdk [documentation](https://github.com/VKCOM/vk-ios-sdk#setup-url-schema-of-your-application).

## Simple example

First, you should try to initialize SDK:
```
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';

const String APP_ID = '12345';
const String API_VERSION = '5.90';

void main() async {
  try {
    final vkSdk = await VKSdk.initialize(appId: APP_ID, apiVersion: API_VERSION);

    runApp(MyApp());
  } on VKSdkException catch (error) {
    print(error.message);
  }
}
```

Second, try to check if user is logged in alredy:
```
final List<String> scopes = [
  VKPermission.FRIENDS,
  VKPermission.PHOTOS,
  VKPermission.OFFLINE,
];

vkSdk.wakeUpSession(scopes).then((result) async {
  if (result.state == VKAuthorizationState.Authorized) {
    final accessToken = await widget.vkSdk.accessToken();
    print(accessToken.localUser?.id);
  }
});
```

If they are not, handle any button tap and start an authorization flow:
```
void onLoginButtonPressed() async {
  final isLoggedIn = await vkSdk.isLoggedIn();
  if (isLoggedIn) {
    return;
  }

  try {
    await widget.vkSdk.authorize(scopes, isSafariDisabled: true);
  } on VKSdkException catch (error) {
    print(error.message);
  }
}
```

>_**tip: You probably should not using redirection to Safari. In that case your app may be rejected by Apple review team. To avoid redirection set argument `isSafariDisabled` to `true`**_

Next, subscribe to one of a stream and listen a result of authorization:
```
vkSdk.authorizationStateUpdated.listen((result) {
  if (result.state == VKAuthorizationState.Authorized) {
    print(result.token);
    print(result.user?.id);
  }
});
```

You also can use SDK's streams in the `StreamBuilder` widget.

Finally, you can use `http` Dart library to call VK API:
```
final token = await vkSdk.accessToken();
if (token == null || token.accessToken == null) {
  throw 'Access token is empty';
}

if (token == null || token.localUser?.id == null) {
  throw 'User ID not defined';
}

final apiUrl =
    'https://api.vk.com/method/users.get?user_ids=${token.localUser.id}&fields=bdate&access_token=${token.accessToken}&v=$API_VERSION';

final response = await http.get(apiUrl);
print(response.statusCode);
print(response.body);
```

The complete example you can find in `/example` folder. Before you run it, do the search `cmd+shift+f` with `INSERT_HERE_YOUR_APP_ID` query string.

## Goals and status

### Goals

 - [ ] implement full API of VK SDK
 - [ ] support Android
 - [ ] add tests

### Status

- Currently project is under development. But you can use it for user authorization flow (see `/example` folder).
- I will upload this plugin to `pub.dartlang.org` after I add the implementation of [VKRequest](https://github.com/VKCOM/vk-ios-sdk/blob/5504d80f2b546eacd1074e733ef749afefbc8aa0/library/Source/Core/VKRequest.h) class

## Author

Developed by **Yury Smidovich**

## License

See the [LICENSE](https://github.com/Stmol/flutter_vk_sdk/blob/master/LICENSE) file