package com.sonikro.flutter_okta_sdk

import android.content.Context
import androidx.annotation.NonNull
import com.sonikro.flutter_okta_sdk.okta.entities.AvailableMethods
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation
import com.sonikro.flutter_okta_sdk.okta.operations.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterOktaSdkPlugin */
class FlutterOktaSdkPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private var applicationContext: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.onAttachedToEngine(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val arguments = call.arguments<Map<String, Any>?>()
        PendingOperation.init(call.method, result)

        if (applicationContext == null)
            PendingOperation.error(Errors.NO_CONTEXT)
        try {
            when (call.method) {
                AvailableMethods.CREATE_CONFIG.methodName -> {
                    createConfig(arguments, applicationContext!!)
                }
                AvailableMethods.SIGN_IN.methodName -> {
                    val username = arguments?.get("username") as? String ?: ""
                    val password = arguments?.get("password") as? String ?: ""
                    signIn(username, password)
                }
                AvailableMethods.SIGN_OUT.methodName -> {
                    signOut()
                }
                AvailableMethods.GET_USER.methodName -> {
                    getUser()
                }
                AvailableMethods.IS_AUTHENTICATED.methodName -> {
                    isAuthenticated()
                }
                AvailableMethods.GET_ACCESS_TOKEN.methodName -> {
                    getAccessToken()
                }
                AvailableMethods.GET_REFRESH_TOKEN.methodName -> {
                    getRefreshToken()
                }
                AvailableMethods.GET_ACCESS_TOKEN_EXPIRATION.methodName -> {
                    getAccessTokenExpiration()
                }
                AvailableMethods.GET_ID_TOKEN.methodName -> {
                    getIdToken()
                }
                AvailableMethods.REVOKE_ACCESS_TOKEN.methodName -> {
                    revokeAccessToken()
                }
                AvailableMethods.REVOKE_ID_TOKEN.methodName -> {
                    revokeIdToken()
                }
                AvailableMethods.REVOKE_REFRESH_TOKEN.methodName -> {
                    revokeRefreshToken()
                }
                AvailableMethods.CLEAR_TOKENS.methodName -> {
                    clearTokens()
                }
                AvailableMethods.INTROSPECT_ACCESS_TOKEN.methodName -> {
                    introspectAccessToken()
                }
                AvailableMethods.INTROSPECT_ID_TOKEN.methodName -> {
                    introspectIdToken()
                }
                AvailableMethods.INTROSPECT_REFRESH_TOKEN.methodName -> {
                    introspectRefreshToken()
                }
                AvailableMethods.REFRESH_TOKENS.methodName -> {
                    refreshTokens()
                }
                else -> {
                    PendingOperation.error(
                        Errors.METHOD_NOT_IMPLEMENTED,
                        "Method called: $call.method"
                    )
                }
            }
        } catch (ex: java.lang.Exception) {
            PendingOperation.error(Errors.GENERIC_ERROR, ex.localizedMessage)
        }
    }

    private fun onAttachedToEngine(context: Context, binaryMessenger: BinaryMessenger) {
        applicationContext = context
        channel = MethodChannel(binaryMessenger, "com.sonikro.flutter_okta_sdk")
        channel.setMethodCallHandler(this)
    }
}
