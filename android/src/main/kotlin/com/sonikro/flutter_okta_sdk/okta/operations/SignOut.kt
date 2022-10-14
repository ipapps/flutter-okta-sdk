package com.sonikro.flutter_okta_sdk.okta.operations

import com.okta.oidc.ResultCallback
import com.okta.oidc.util.AuthorizationException
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation

fun signOut() {
    OktaClient.getAuthClient().signOut(object : ResultCallback<Int, AuthorizationException> {
        override fun onSuccess(result: Int) {
            PendingOperation.success(true)
        }

        override fun onCancel() {
            PendingOperation.error(Errors.SIGN_OUT_FAILED, "Cancelled")
        }

        override fun onError(msg: String?, exception: AuthorizationException?) {
            PendingOperation.error(Errors.SIGN_OUT_FAILED, exception?.message)
        }
    })
}