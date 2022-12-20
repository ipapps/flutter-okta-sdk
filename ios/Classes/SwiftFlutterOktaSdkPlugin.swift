import Flutter
import UIKit

import OktaOidc
import OktaJWT
import OktaAuthSdk

let CHANNEL_NAME: String! = "com.sonikro.flutter_okta_sdk";

enum ErrorCode: String {
    case NOT_CONFIGURED = "-100"
    case NO_VIEW = "-200"
    case NO_ID_TOKEN = "-500"
    case OKTA_OIDC_ERROR = "-600"
    case ERROR_TOKEN_TYPE = "-700"
    case NO_ACCESS_TOKEN = "-900"
    case SIGN_IN_FAILED = "-1000"
    case GENERIC_ERROR = "-1100"
    case METHOD_NOT_IMPLEMENTED = "-1200"
    case NO_CONTEXT = "-1300"
    case CANCELLED_ERROR = "-1400"
    case SIGN_OUT_FAILED = "-1500"
}

struct FlutterOktaError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
}

extension FlutterOktaError: LocalizedError {
    var errorDescription: String? { return message }
}

public class SwiftFlutterOktaSdkPlugin: NSObject, FlutterPlugin {
    
    var _channel: FlutterMethodChannel
    var oktaOidc: OktaOidc?
    var stateManager: OktaOidcStateManager? {
        if let oktaOidc = self.oktaOidc {
            return OktaOidcStateManager.readFromSecureStorage(for: oktaOidc.configuration)
        } else {
            return nil
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterOktaSdkPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel) {
        _channel = channel;
        super.init();
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createConfig":
            guard let oktaInfo: Dictionary = call.arguments as? [String: Any?] else {
                result(-1);
                return;
            }
            let clientId: String? = oktaInfo["clientId"] as? String;
            let issuer: String? = oktaInfo["issuer"] as? String;
            let endSessionRedirectUri: String? = oktaInfo["endSessionRedirectUri"] as? String;
            let redirectUrl: String? = oktaInfo["redirectUrl"] as? String;
            let scopeArray: [String]? = oktaInfo["scopes"] as? [String];
            
            let scopes = scopeArray?.joined(separator: " ");
            
            let oktaConfigMap: [String: String] = [
                "clientId": clientId!,
                "issuer": issuer!,
                "logoutRedirectUri": endSessionRedirectUri!,
                "scopes": scopes!,
                "redirectUri": redirectUrl!,
            ] as [String: String];
            
            createConfig(configuration: oktaConfigMap, callback: { error in
                if(error != nil) {
                    result(error);
                    return
                }
                result(true);
            });
            break;
            
        case "signIn":
            signIn(callback: { error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: ErrorCode.SIGN_IN_FAILED.rawValue, message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError);
                    return
                }
                result(true);
            });
            break;
            
        case "signInCustom":
            guard let args: Dictionary = call.arguments as? [String: String] else {
                result(-1);
                return;
            }
            guard let username: String = args["username"] else {
                result(-1);
                return;
            }
            guard let password: String = args["password"] else {
                result(-1);
                return;
            }
            signInCustom(username: username, password: password, callback: { error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: ErrorCode.SIGN_IN_FAILED.rawValue, message: "\(ErrorCode.SIGN_IN_FAILED)", details: "\(error)");
                    result(flutterError);
                    return
                }
                result(nil);
            });
            break;
            
        case "signOut":
            print("sign out")
            signOut(callback: { error in
                print("finito")
                if(error != nil) {
                    print("error")
                    let flutterError: FlutterError = FlutterError(code: "SignOut_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                    return
                }
                result(nil);
            });
            break;
            
        case "getUser":
            getUser(callback: { user, error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: "GetUser_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                    return
                }
                result(user);
            })
            break;
            
        case "isAuthenticated":
            isAuthenticated(callback: { status in
                result(status);
            })
            break;
            
        case "getAccessToken":
            getAccessToken(callback: { token in
                result(token);
            })
            break;

        case "getRefreshToken":
            getRefreshToken(callback: { token in
                result(token);
            })
            break;

        case "getAccessTokenExpiration":
            getAccessTokenExpiration(callback: { tokenExpiration in
                result(tokenExpiration);
            })
            break;
            
        case "getIdToken":
            getIdToken(callback: { token in
                result(token);
            })
            break;
            
        case "revokeAccessToken":
            revokeAccessToken(callback: { isRevoked in
                result (isRevoked)
            })
            break;
            
        case "revokeIdToken":
            revokeIdToken(callback: { isRevoked in
                result (isRevoked)
            })
            break;
            
        case "revokeRefreshToken":
            revokeRefreshToken(callback: { isRevoked in
                result (isRevoked)
            })
            break;
            
        case "clearTokens":
            clearTokens(callback: {
                result(true);
            });
            break;
            
        case "introspectAccessToken":
            introspectAccessToken(callback: { message, error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: "IntrospectAccessToken_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                } else {
                    result(message)
                }
            })
            break;
            
        case "introspectIdToken":
            introspectIdToken(callback: { message, error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: "IntrospectIdToken_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                } else {
                    result(message)
                }
            })
            break;
            
        case "introspectRefreshToken":
            introspectRefreshToken(callback: { message, error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: "IntrospectRefreshToken_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                } else {
                    result(message)
                }
            })
            break;
            
        case "refreshTokens":
            refreshTokens(callback: { message, error in
                if(error != nil) {
                    let flutterError: FlutterError = FlutterError(code: "RefreshToken_Error", message: error?.localizedDescription, details: error.debugDescription);
                    result(flutterError)
                } else {
                    result(message)
                }
            })
            break;
            
        default:
            NSLog("\(call.method)");
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    func createConfig(configuration: [String:String], callback: ((Error?) -> (Void))) {
        do {
            let oktaConfiguration: OktaOidcConfig = try OktaOidcConfig(with: configuration);
            if #available(iOS 13, *) {
                oktaConfiguration.noSSO = true
            }
            self.oktaOidc = try OktaOidc(configuration: oktaConfiguration);
        } catch let error {
            print("okta object creation error \(error)");
            callback(error);
        }
        callback(nil)
    }
    
    func signIn(callback: @escaping ((Error?) -> Void)) {
        if let oktaOidc = self.oktaOidc,
           let _ = stateManager?.accessToken {
            let options = ["iss": oktaOidc.configuration.issuer, "exp": "true"]
            let idTokenValidator = OktaJWTValidator(options)
            do {
                _ = try idTokenValidator.isValid(self.stateManager!.idToken!)
            } catch {
                signInWithBrowser(callback: callback);
            }
            callback(nil);
        } else {
            signInWithBrowser(callback: callback);
        }
    }
    
    func signInCustom(username: String, password: String, callback: @escaping ((Error?) -> Void)) {
        if let oktaOidc = self.oktaOidc,
           let _ = stateManager?.accessToken {
            let options = ["iss": self.oktaOidc!.configuration.issuer, "exp": "true"]
            let idTokenValidator = OktaJWTValidator(options)
            do {
                _ = try idTokenValidator.isValid(self.stateManager!.idToken!)
                _ = stateManager!.accessToken
                callback(nil)
            } catch {
                signInWithUsernamePassword(username: username, password: password, callback: callback)
            }
        } else {
            signInWithUsernamePassword(username: username, password: password, callback: callback)
        }
    }
    
    func signInWithUsernamePassword(username: String, password: String, callback: @escaping ((Error?) -> Void)) {
        OktaAuthSdk.authenticate(with: URL(string: "https://login.stg.naomi.fr")!,
                                 username: username,
                                 password: password,
                                 onStatusChange: { [weak self] authStatus in
            if let token = (authStatus as? OktaAuthStatusSuccess)?.sessionToken {
                self?.oktaOidc?.authenticate(withSessionToken: token) { authStateManager, error in
                    authStateManager?.writeToSecureStorage()
                    if let accessToken = authStateManager?.accessToken {
                        callback(nil)
                    } else {
                        callback(FlutterOktaError(message: "A problem occurred. Access Token could not be retrieved after login."))
                    }
                }
            } else {
                callback(FlutterOktaError(message: "A problem occurred. \(authStatus)"))
            }
        },
                                 onError: { error in
            callback(error)
        })
    }
    
    func signInWithBrowser(callback: @escaping ((Error?) -> Void)) {
        let viewController: UIViewController =
        (UIApplication.shared.delegate?.window??.rootViewController)!;
        
        oktaOidc?.signInWithBrowser(from: viewController, callback: { stateManager, error in
            if let error = error {
                print("Signin Error: \(error)");
                callback(error)
                return
            }
            stateManager?.writeToSecureStorage()
            callback(nil)
        })
    }
    
    func signOut(callback: @escaping ((Error?) -> (Void))) {
        let viewController: UIViewController =
        (UIApplication.shared.delegate?.window??.rootViewController)!;
        
        guard let oktaOidc = self.oktaOidc,
              let stateManager = self.stateManager else {
            callback(FlutterOktaError(message: "Invalid stateManager"))
            return
        }
        
        oktaOidc.signOut(authStateManager: stateManager,
                         from: viewController,
                         progressHandler: {progress in },
                         completionHandler: {success, progress in
            if(!success) {
                callback(FlutterOktaError(message: "Could not sign out"))
            } else {
                callback(nil)
            }
        })
    }
    
    func getUser(callback: @escaping ((String?, Error?)-> (Void))) {
        guard let oktaOidc = self.oktaOidc else {
            callback(nil, FlutterOktaError(message: "OKTA OIDC is not configured"))
            return
        }
        stateManager?.getUser { response, error in
            guard let response = response else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                callback(nil, error)
                return
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) {
                let jsonString = String(data: jsonData, encoding: .ascii)
                callback(jsonString, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    func isAuthenticated(callback: ((Bool) -> (Void))?) {
        if let _ = stateManager?.accessToken {
            callback?(true)
            return
        }
        callback?(false)
    }
    
    func getAccessToken(callback: ((String?) -> (Void))? ) {
        if let accessToken = stateManager?.accessToken {
            callback?(accessToken)
        }
        else { callback?(nil) }
    }

    func getRefreshToken(callback: ((String?) -> (Void))? ) {
        if let refreshToken = stateManager?.refreshToken {
            callback?(refreshToken)
        }
        else { callback?(nil) }
    }

    func getAccessTokenExpiration(callback: ((Int) -> (Void))? ) {
        callback?(Int(stateManager?.authState.lastTokenResponse?.accessTokenExpirationDate?.timeIntervalSince1970 ?? 0.0))
    }
    
    func getIdToken(callback: ((String?) -> (Void))? ) {
        if let idToken = stateManager?.idToken {
            callback?(idToken)
        }
        else { callback?(nil) }
    }
    
    func revokeAccessToken(callback: ((Bool) ->(Void))?) {
        if let accessToken = stateManager?.accessToken {
            return _revokeToken(token: accessToken, callback: callback);
        }
        else {
            callback?(true);
        }
    }
    
    func revokeIdToken(callback: ((Bool) ->(Void))?) {
        if let idToken = stateManager?.idToken{
            return _revokeToken(token: idToken, callback: callback);
        } else {
            callback?(true);
        }
    }
    
    func revokeRefreshToken(callback: ((Bool) ->(Void))?) {
        if let refreshToken = stateManager?.refreshToken{
            return _revokeToken(token: refreshToken, callback: callback);
        } else {
            callback?(true);
        }
    }
    
    
    func _revokeToken(token: String?, callback: ((Bool) ->(Void))?) {
        stateManager?.revoke(token, callback: { isRevoked, error in
            guard isRevoked else {
                callback?(false)
                return
            }
            callback?(true)
        })
    }
    
    func clearTokens (callback: (() -> (Void))?) {
        stateManager?.clear();
        callback?();
    }
    
    func introspectAccessToken(callback: ((String?, Error?)->(Void))?) {
        if let accessToken = stateManager?.accessToken {
            return introspectToken(token: accessToken, callback: callback);
        } else {
            callback?(nil, FlutterOktaError(message: "Access Token is nil"));
        }
    }
    
    func introspectIdToken(callback: ((String?, Error?)->(Void))?) {
        if let idToken = stateManager?.idToken {
            return introspectToken(token: idToken, callback: callback);
        } else {
            callback?(nil, FlutterOktaError(message: "ID Token is nil"));
        }
    }
    
    func introspectRefreshToken(callback: ((String?, Error?)->(Void))?) {
        if let refreshToken = stateManager?.refreshToken {
            return introspectToken(token: refreshToken, callback: callback);
        } else {
            callback?(nil, FlutterOktaError(message: "Refresh Token is nil"));
        }
    }
    
    func introspectToken(token: String?, callback: ((String?, Error?)->(Void))?) {
        stateManager?.introspect(token: token, callback: { payload, error in
            guard let isValid = payload?["active"] as? Bool else {
                callback?(nil, error);
                return
            }
            callback?("Token is \(isValid ? "valid" : "invalid")!", nil);
        })
    }
    
    func refreshTokens(callback: ((String?, Error?) -> (Void))?) {
        if  let stateManager = self.stateManager {
            stateManager.renew { newStateManager, error in
                if let error = error {
                    callback?(nil, error)
                    return
                }
                newStateManager?.writeToSecureStorage()
                callback?("Token refreshed!", nil);
            }
        } else {
            callback?(nil, FlutterOktaError(message: "User not logged in, cannot refresh"));
        }
    }
}
