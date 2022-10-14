package com.sonikro.flutter_okta_sdk.okta.operations

import android.app.Activity
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient

fun signIn(activity: Activity) {
    registerCallback(activity)
    OktaClient.getWebClient().signIn(activity, null)
}

