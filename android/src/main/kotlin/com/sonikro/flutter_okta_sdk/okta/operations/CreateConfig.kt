package com.sonikro.flutter_okta_sdk.okta.operations

import android.content.Context
import com.okta.oidc.OIDCConfig
import com.okta.oidc.Okta
import com.okta.oidc.storage.SharedPreferenceStorage
import com.sonikro.flutter_okta_sdk.okta.entities.Errors
import com.sonikro.flutter_okta_sdk.okta.entities.OktaClient
import com.sonikro.flutter_okta_sdk.okta.entities.OktaRequestParameters
import com.sonikro.flutter_okta_sdk.okta.entities.PendingOperation

fun createConfig(arguments: Map<String, Any>?, context: Context) {
    try {
        val params = processOktaRequestArguments(arguments)
        val config = OIDCConfig.Builder()
                .clientId(params.clientId)
                .redirectUri(params.redirectUri)
                .endSessionRedirectUri(params.endSessionRedirectUri)
                .scopes(*params.scopes.toTypedArray())
                .discoveryUri(params.discoveryUri)
                .create()

        val webClient = Okta.WebAuthBuilder()
                .withConfig(config)
                .withContext(context)
                .withStorage(SharedPreferenceStorage(context))
                .setRequireHardwareBackedKeyStore(params.requireHardwareBackedKeyStore)
                .create()

        val authClient = Okta.AuthBuilder()
                .withConfig(config)
                .withContext(context)
                .withStorage(SharedPreferenceStorage(context))
                .setRequireHardwareBackedKeyStore(params.requireHardwareBackedKeyStore)
                .create()

        OktaClient.init(config, webClient, authClient)
        PendingOperation.success(true)
    } catch (ex: java.lang.Exception) {
        PendingOperation.error(Errors.OKTA_OIDC_ERROR)
    }
}

private fun processOktaRequestArguments(arguments: Map<String, Any>?): OktaRequestParameters {
    return OktaRequestParameters(
            clientId = (arguments?.get("clientId") as String?)!!,
            discoveryUri = (arguments?.get("discoveryUrl") as String?)!!,
            endSessionRedirectUri = (arguments?.get("endSessionRedirectUri") as String?)!!,
            redirectUri = (arguments?.get("redirectUrl") as String?)!!,
            requireHardwareBackedKeyStore = (arguments?.get("requireHardwareBackedKeyStore") as Boolean?)
                    ?: false,
            scopes = arguments?.get("scopes") as ArrayList<String>,
            userAgentTemplate = (arguments["userAgentTemplate"] as String?) ?: ""
    )
}
