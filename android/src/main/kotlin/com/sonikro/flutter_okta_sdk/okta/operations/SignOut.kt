package com.sonikro.flutter_okta_sdk.okta.operations

import android.app.Activity
import com.okta.oidc.AuthorizationStatus
import com.okta.oidc.RequestCallback
import com.okta.oidc.ResultCallback
import com.okta.oidc.clients.web.WebAuthClient
import com.okta.oidc.util.AuthorizationException
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation

fun signOut(activity: Activity) {
    registerCallback(activity)
    OktaClient.getWebClient().signOut(activity, object: RequestCallback<Int, AuthorizationException> {
        override fun onSuccess(result: Int) {
            PendingOperation.success(true)
        }

        override fun onError(error: String?, exception: AuthorizationException?) {
            PendingOperation.error(Errors.SIGN_OUT_FAILED, error)
        }
    })
}