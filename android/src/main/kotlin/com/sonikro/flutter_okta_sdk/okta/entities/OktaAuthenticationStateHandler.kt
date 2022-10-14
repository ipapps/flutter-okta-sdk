package com.sonikro.flutter_okta_sdk.okta.entities

import com.okta.authn.sdk.AuthenticationStateHandlerAdapter
import com.okta.authn.sdk.resource.AuthenticationResponse
import com.okta.commons.lang.Strings
import com.okta.oidc.RequestCallback
import com.okta.oidc.results.Result
import com.okta.oidc.util.AuthorizationException


class OktaAuthenticationStateHandler : AuthenticationStateHandlerAdapter() {
    override fun handleUnknown(unknownResponse: AuthenticationResponse) {
        PendingOperation.error(
            Errors.SIGN_IN_FAILED,
            unknownResponse.toString()
        )
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
}