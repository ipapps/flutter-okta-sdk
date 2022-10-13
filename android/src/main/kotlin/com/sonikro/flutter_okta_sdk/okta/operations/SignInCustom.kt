package com.sonikro.flutter_okta_sdk.okta.operations

import android.app.Activity
import android.util.Log
import com.okta.authn.sdk.AuthenticationStateHandlerAdapter
import com.okta.authn.sdk.client.AuthenticationClients
import com.okta.authn.sdk.resource.AuthenticationResponse
import com.okta.commons.lang.Strings
import com.okta.oidc.RequestCallback
import com.okta.oidc.results.Result
import com.okta.oidc.util.AuthorizationException
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation
import kotlinx.coroutines.*


fun signInCustom() {
    try {
        val client = AuthenticationClients.builder()
            .setOrgUrl("https://login.stg.naomi.fr")
            .build()
        CoroutineScope(Dispatchers.IO).launch {
            client.authenticate(
                "",
                "".toCharArray(),
                "/",
                object : AuthenticationStateHandlerAdapter() {
                    override fun handleUnknown(unknownResponse: AuthenticationResponse) {
                        PendingOperation.error(Errors.SIGN_IN_FAILED, unknownResponse.toString())
                    }

                    override fun handleSuccess(successResponse: AuthenticationResponse) {
                        // a user is ONLY considered authenticated if a sessionToken exists
                        if (Strings.hasLength(successResponse.sessionToken)) {
                            OktaClient.getAuthClient().signIn(
                                successResponse.sessionToken,
                                null,
                                object : RequestCallback<Result, AuthorizationException> {
                                    override fun onSuccess(result: Result) {
                                        PendingOperation.success(true)
                                    }

                                    override fun onError(
                                        error: String?,
                                        exception: AuthorizationException?
                                    ) {
                                        PendingOperation.error(Errors.SIGN_IN_FAILED, error)
                                    }
                                })
                        }
                    }

                    override fun handlePasswordExpired(passwordExpired: AuthenticationResponse) {

                    }
                })
        }
    } catch (e: Exception) {
        PendingOperation.error(Errors.SIGN_IN_FAILED, e.stackTraceToString())
    }
}

