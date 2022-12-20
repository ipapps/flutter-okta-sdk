package com.sonikro.flutter_okta_sdk.okta.operations

import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation

fun getAccessTokenExpiration() {
    OktaClient.getAuthClient().sessionClient?.tokens?.expiresIn?.let {
        PendingOperation.success(it)
    } ?: PendingOperation.error(Errors.NO_ACCESS_TOKEN)
}
