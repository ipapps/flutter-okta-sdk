package com.sonikro.flutter_okta_sdk.okta.operations

import com.okta.authn.sdk.client.AuthenticationClients
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaAuthenticationStateHandler
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

fun signIn(username: String, password: String) {
    try {
        val client = AuthenticationClients.builder()
            .setOrgUrl("https://login.stg.naomi.fr")
            .build()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                client.authenticate(
                    username,
                    password.toCharArray(),
                    "/",
                    OktaAuthenticationStateHandler())
            } catch (e: Exception) {
                PendingOperation.error(Errors.SIGN_IN_FAILED, e.message)
            }
        }
    } catch (e: Exception) {
        PendingOperation.error(Errors.SIGN_IN_FAILED, e.stackTraceToString())
    }
}

