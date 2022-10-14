package com.sonikro.flutter_okta_sdk.okta.operations

import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation

fun getAccessToken() {
    OktaClient.getAuthClient().sessionClient.tokens.accessToken?.let {
        PendingOperation.success(it)
    } ?: PendingOperation.error(Errors.NO_ACCESS_TOKEN)
}
