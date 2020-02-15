import Flutter
import UIKit
import VK_ios_sdk

private struct ChannelName {
    static let method = "me.stmol.flutter_vk_sdk_plugin/method"
    static let event = "me.stmol.flutter_vk_sdk_plugin/event"
}

private enum MethodName: String {
    case setupVKSdk
    case isLoggedIn
    case authorize
    case wakeUpSession
    case accessToken
    case forceLogout
    case initialized
    case vkAppMayExists
    case apiVersion
    case currentAppId
    case setSchedulerEnabled
}

private enum EventName: String {
    case vkSdkAccessAuthorizationFinished
    case vkSdkAuthorizationStateUpdated
    case vkSdkUserAuthorizationFailed
    case vkSdkAccessTokenUpdated
    case vkSdkTokenHasExpired
    case vkSdkWillDismiss
    case vkSdkDidDismiss
    case vkSdkShouldPresent
    case vkSdkNeedCaptchaEnter
}

private enum Result {
    case success(Any?)
    case failure(String)
}

public class SwiftVkSdkPlugin: NSObject, FlutterPlugin {
    private typealias VKWakeUpCompletion = (VKAuthorizationState, Error?) -> Void

    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: ChannelName.method, binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: ChannelName.event, binaryMessenger: registrar.messenger())

        let instance = SwiftVkSdkPlugin()

        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        eventChannel.setStreamHandler(instance)
    }

    // iOS 8 and lower
    public func application(_: UIApplication, open url: URL, sourceApplication: String, annotation _: Any) -> Bool {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
        return true
    }

    // iOS 9 workflow
    public func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if #available(iOS 9.0, *) {
            VKSdk.processOpen(url, fromApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
            return true
        }

        return false
    }

    public func handle(_ input: FlutterMethodCall, result output: @escaping FlutterResult) {
        guard let methodName = MethodName(rawValue: input.method) else {
            output(FlutterMethodNotImplemented)
            return
        }

        switch methodName {
        case .setupVKSdk:
            guard
                let appId: String = getArgument("appId", from: input.arguments)
            else {
                feedback(.failure("Invalid arguments"), to: output)
                return
            }

            let apiVersion: String? = getArgument("apiVersion", from: input.arguments)

            setupVKSdk(appId, apiVersion)
            feedback(.success(nil), to: output)

        case .authorize:
            guard let permissions: [String] = getArgument("permissions", from: input.arguments) else {
                feedback(.failure("Invalid arguments"), to: output)
                return
            }

            let isSafariDisabled: Bool = getArgument("isSafariDisabled", from: input.arguments) ?? false

            authorize(permissions, isSafariDisabled)
            feedback(.success(nil), to: output)

        case .wakeUpSession:
            guard let permissions: [String] = getArgument("permissions", from: input.arguments) else {
                feedback(.failure("Invalid arguments"), to: output)
                return
            }

            wakeUpSession(permissions) { [weak self] state, error in
                let payload: [String: Any?] = [
                    "state": state.rawValue,
                    "error": error?.localizedDescription ?? nil,
                ]

                self?.feedback(.success(payload), to: output)
            }

        case .setSchedulerEnabled:
            guard let enabled: Bool = getArgument("enabled", from: input.arguments) else {
                feedback(.failure("Invalid arguments"), to: output)
                return
            }

            VKSdk.setSchedulerEnabled(enabled)
            feedback(.success(nil), to: output)

        case .accessToken:
            let accessToken = transformToMap(VKSdk.accessToken())
            feedback(.success(accessToken), to: output)

        case .isLoggedIn:
            feedback(.success(VKSdk.isLoggedIn()), to: output)

        case .forceLogout:
            VKSdk.forceLogout()
            feedback(.success(nil), to: output)

        case .initialized:
            feedback(.success(VKSdk.initialized()), to: output)

        case .vkAppMayExists:
            feedback(.success(VKSdk.vkAppMayExists()), to: output)

        case .apiVersion:
            if let instance = VKSdk.instance() {
                feedback(.success(instance.apiVersion), to: output)
                break
            }
            feedback(.failure("Instance of VKSdk not initialized"), to: output)

        case .currentAppId:
            if let instance = VKSdk.instance() {
                feedback(.success(instance.currentAppId), to: output)
                break
            }
            feedback(.failure("Instance of VKSdk not initialized"), to: output)
        }
    }

    ///
    /// Initialize SDK
    ///
    private func setupVKSdk(_ appId: String, _ apiVersion: String?) {
        if apiVersion == nil {
            VKSdk.initialize(withAppId: appId)
        } else {
            VKSdk.initialize(withAppId: appId, apiVersion: apiVersion)
        }

        VKSdk.instance().uiDelegate = self
        VKSdk.instance().register(self)
    }

    ///
    /// authorize method handler
    ///
    private func authorize(_ permissions: [String], _ isSafariDisabled: Bool) {
        if isSafariDisabled {
            VKSdk.authorize(permissions, with: .disableSafariController)
        } else {
            VKSdk.authorize(permissions)
        }
    }

    ///
    /// wakeUpSession method handler
    ///
    private func wakeUpSession(_ permissions: [String], completion: @escaping VKWakeUpCompletion) {
        VKSdk.wakeUpSession(permissions) { (state: VKAuthorizationState, error: Error?) in
            completion(state, error)
        }
    }

    ///
    /// Helper for getting argument from Flutter channel
    ///
    private func getArgument<T>(_ name: String, from arguments: Any?) -> T? {
        guard let arguments = arguments as? [String: Any] else { return nil }
        return arguments[name] as? T
    }

    ///
    /// Build response to flutter channel output
    ///
    private func feedback(_ result: Result, to output: FlutterResult) {
        var response = [String: Any]()

        switch result {
        case let .success(payload):
            response["status"] = "success"
            response["payload"] = payload
        case let .failure(cause):
            response["status"] = "failure"
            response["payload"] = cause
        }

        output(response)
    }

    ///
    /// Transform VKAccessToken object to map for response
    ///
    private func transformToMap(_ accessToken: VKAccessToken?) -> [String: Any?] {
        return [
            "accessToken": accessToken?.accessToken,
            "userId": accessToken?.userId,
            "secret": accessToken?.secret,
            "permissions": accessToken?.permissions as? [String],
            "httpsRequired": accessToken?.httpsRequired,
            "expiresIn": accessToken?.expiresIn,
            "email": accessToken?.email,
            "isExpired": accessToken?.isExpired(),
            "localUser": transformToMap(accessToken?.localUser),
        ]
    }

    ///
    /// Transofrm VKUser object to map for response
    ///
    private func transformToMap(_ user: VKUser?) -> [String: Any?] {
        return [
            "id": user?.id,
            "firstName": user?.first_name,
            "lastName": user?.last_name,
            "sex": user?.sex,
            "online": user?.online,
            "bdate": user?.bdate,
            "photoMax": user?.photo_max,
            "photo50": user?.photo_50,
            "photo100": user?.photo_100,
            "photo200": user?.photo_200,
            "photo200orig": user?.photo_200_orig,
            "photo400orig": user?.photo_400_orig,
            "photoMaxOrig": user?.photo_max_orig,
        ]
    }

    ///
    /// Dispatch Flutter event
    ///
    private func dispatch(_ eventName: EventName, payload: Any? = nil) {
        eventSink?([
            "eventName": eventName.rawValue,
            "payload": payload,
        ])
    }
}

extension SwiftVkSdkPlugin: FlutterStreamHandler {
    public func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

extension SwiftVkSdkPlugin: VKSdkUIDelegate, VKSdkDelegate {
    public func vkSdkShouldPresent(_ controller: UIViewController!) {
        dispatch(.vkSdkShouldPresent)
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            // TODO: Should dispatch error
            return
        }
        rootController.present(controller, animated: true)
    }

    public func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        dispatch(.vkSdkNeedCaptchaEnter, payload: [
            "error": captchaError.errorMessage,
        ])

        guard
            let rootController = UIApplication.shared.keyWindow?.rootViewController,
            let controller = VKCaptchaViewController.captchaControllerWithError(captchaError) else {
            // TODO: Should dispatch error
            return
        }

        rootController.present(controller, animated: true)
    }

    public func vkSdkWillDismiss(_: UIViewController!) {
        dispatch(.vkSdkWillDismiss)
    }

    public func vkSdkDidDismiss(_: UIViewController!) {
        dispatch(.vkSdkDidDismiss)
    }

    public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        let payload: [String: Any?] = [
            "error": result.error?.localizedDescription,
            "state": result.state.rawValue,
            "token": transformToMap(result.token),
            "user": transformToMap(result.user),
        ]

        dispatch(.vkSdkAccessAuthorizationFinished, payload: payload)
    }

    public func vkSdkUserAuthorizationFailed() {
        dispatch(.vkSdkUserAuthorizationFailed)
    }

    public func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        let payload: [String: Any?] = [
            "error": result.error?.localizedDescription,
            "state": result.state.rawValue,
            "token": transformToMap(result.token),
            "user": transformToMap(result.user),
        ]

        dispatch(.vkSdkAuthorizationStateUpdated, payload: payload)
    }

    public func vkSdkAccessTokenUpdated(_ newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        dispatch(.vkSdkAccessTokenUpdated, payload: [
            "newToken": transformToMap(newToken),
            "oldToken": transformToMap(oldToken),
        ])
    }

    public func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        dispatch(.vkSdkTokenHasExpired, payload: [
            "token": transformToMap(expiredToken),
        ])
    }
}
