#' Discover OpenID Connect Endpoints
#'
#' Performs OpenID Connect discovery on an ID Provider.
#'
#' @param auth_server the server
#'
#' @return An \code{\link{oauth_endpoint}} with the discovered endpoints.
#'
#' @importFrom urltools path
#' @importFrom httr GET stop_for_status content oauth_endpoint
#'
#' @examples
#' \dontrun{
#' discover("https://auth.molgenis.org")
#' discover("https://accounts.google.com")
#' }
#' @export
discover <- function(auth_server) {
  auth_server <- .ensure_single_slash(auth_server)
  openid_config_url <- paste0(auth_server, ".well-known/openid-configuration")
  req <- request(openid_config_url)
  response <- req_perform(req)
  configuration <- resp_body_json(response)

  return(list(
    request = NULL,
    authorize = configuration$authorization_endpoint,
    access = configuration$token_endpoint,
    user = configuration$userinfo_endpoint,
    device = configuration$device_authorization_endpoint,
    logout = configuration$end_session_endpoint
  ))
}


#' Authenticate using device flow
#'
#' Get an ID token using the
#' \href{https://www.rfc-editor.org/rfc/rfc8628}{OpenIDConnect Device Flow}.
#'
#' @param endpoint An \code{\link{oauth_endpoint}} with a device endpoint
#' specified in it
#' @param client_id The client ID for which the token should be obtained
#' @param scopes the requested scopes, default to
#' \code{c("openid", "offline_access")}
#' @return The credentials retrieved from the token endpoint
#' @importFrom httr2 req_perform resp_body_json
#' @examples
#' \dontrun{
#' endpoint <- discover("https://auth.molgenis.org")
#' device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
#' }
#'
#' @export
device_flow_auth <- function(endpoint, client_id, scopes = c("openid", "offline_access")) {
  .check_inputs(endpoint, client_id)
  auth_req <- .build_auth_request(endpoint, client_id, scopes)
  auth_res <- req_perform(auth_req) |> resp_body_json()
  .request_token_via_browser(auth_res, client_id)
  cred_req <- .build_credential_request(endpoint, client_id, scopes, auth_res)
  return(req_perform(cred_req))
}

#' Ensure a Single Trailing Slash in a URL
#'
#' This function takes a URL or server address as input and ensures that it ends
#' with exactly one trailing slash.
#'
#' @param auth_server A character string representing a URL or server address.
#'
#' @return A character string representing the URL or server address with exactly
#' one trailing slash.
#'
#' @noRd
.ensure_single_slash <- function(auth_server) {
  auth_server_no_slash <- gsub("/+$", "", auth_server)
  return(paste0(auth_server_no_slash, "/"))
}

#' Check Inputs
#'
#' Validates that the provided client ID and endpoint are of the correct types.
#'
#' @param client_id A character string representing the client ID.
#' @param endpoint An \code{\link{oauth_endpoint}} object containing the endpoint details.
#' @importFrom assertthat assert_that
#' @return Throws an error if the inputs are not of the correct types.
#' @noRd
.check_inputs <- function(endpoint, client_id) {
  assert_that(
    is.character(client_id),
    is.character(endpoint$device)
  )
}

#' Build authorisation Request
#'
#' Builds an authorisation request with the specified client ID and scopes.
#'
#' @param endpoint An \code{\link{oauth_endpoint}} object containing the endpoint details.
#' @param client_id A character string representing the client ID.
#' @param scopes A character vector specifying the scopes requested for the token.
#' @importFrom httr2 request req_body_form
#' @return A request object ready to be sent to the authorisation endpoint.
#' @noRd
.build_auth_request <- function(endpoint, client_id, scopes) {
  return(
    request(endpoint$device) |>
      req_body_form(
        client_id = client_id,
        scope = paste(scopes, collapse = " ")
      )
  )
}


#' Request Token via Browser
#'
#' Opens a browser to allow the user to log in and obtain an ID token.
#'
#' @param device A list containing device authorisation details, including the user code.
#' @param client_id A character string representing the client ID.
#'
#' @return Opens a browser window for the user to complete authentication.
#' @noRd
.request_token_via_browser <- function(auth_res, client_id) {
  if (interactive()) {
    print(.make_browser_message(auth_res))
  }
  verification_url <- .make_verification_url(auth_res, client_id)
  .browse_url(verification_url)
}

#' Make Browser Message
#'
#' Constructs a message to be displayed to the user when opening a browser for login.
#'
#' @param device A list containing device authorisation details, including the user code.
#'
#' @return A character string containing the message to be displayed.
#' @noRd
.make_browser_message <- function(auth_res) {
  return(
    paste0(
      "We're opening a browser so you can log in with code ",
      auth_res$user_code
    )
  )
}

#' Make Verification URL
#'
#' Constructs the full verification URL by appending the client ID as a parameter.
#'
#' @param device A list containing device authorisation details, including the
#' verification URI.
#' @param client_id A character string representing the client ID.
#' @return A character string containing the full verification URL.
#' @importFrom urltools param_set
#' @noRd
.make_verification_url <- function(auth_res, client_id) {
  return(
    param_set(
      auth_res$verification_uri_complete,
      "client_id",
      client_id
    )
  )
}

#' Browse URL
#'
#' Opens the specified URL in the user's default web browser.
#'
#' @param url A character string representing the URL to be opened.
#'
#' @return Opens a browser window pointing to the specified URL.
#' @importFrom utils browseURL
#' @noRd
.browse_url <- function(url) {
  utils::browseURL(url)
}

#' Build Credential Request
#'
#' This function builds a credential request by adding the necessary request body
#' and retry logic to the request object.
#'
#' @param endpoint An \code{\link{oauth_endpoint}} object containing the endpoint details.
#' @param client_id A character string representing the client ID.
#' @param scopes A character vector specifying the scopes requested for the token.
#' @param auth_res A list containing the authorisation response details, including
#' `expires_in` and `interval` fields.
#' @importFrom httr2 request
#' @return A modified request object with the credential body and retry logic added.
#' @noRd
.build_credential_request <- function(endpoint, client_id, scopes, auth_res) {
  return(
    request(endpoint$access) |>
      .add_credential_body(client_id, scopes, auth_res) |>
      .add_credential_retry(auth_res)
  )
}

#' Add Credential Body to Request
#'
#' Adds the necessary credential parameters to the request body for obtaining
#' an access token.
#'
#' @param req The request object to which the body will be added.
#' @param client_id A character string representing the client ID.
#' @param scopes A character vector specifying the scopes requested for the token.
#' @param auth_res A list containing the authorisation response details, including
#' the device code.
#' @return A modified request object with the credential body added.
#' @noRd
.add_credential_body <- function(req, client_id, scopes, auth_res) {
  req |> req_body_form(
    scope = paste(scopes, collapse = " "),
    client_id = client_id,
    grant_type = "urn:ietf:params:oauth:grant-type:device_code",
    device_code = auth_res$device_code
  )
}

#' Add Credential Retry Logic
#'
#' Adds retry logic to a request, with retry attempts based on the expiration
#' and interval specified in the authorisation response.
#'
#' @param req The request object to which retry logic will be added.
#' @param auth_res A list containing the authorisation response details, including
#' `expires_in` and `interval` fields.
#' @importFrom httr2 req_retry resp_status
#' @return A modified request object with retry logic added.
#' @noRd
.add_credential_retry <- function(req, auth_res) {
  req |> req_retry(
    max_tries = auth_res$expires_in / auth_res$interval,
    is_transient = function(resp) {
      resp_status(resp) == 400
    }
  )
}
