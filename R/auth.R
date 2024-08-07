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
  req <- httr2::request(openid_config_url)
  response <- httr2::req_perform(req)
  configuration <- httr2::resp_body_json(response)

  return(list(
    request = NULL,
    authorize = configuration$authorization_endpoint,
    access = configuration$token_endpoint,
    user = configuration$userinfo_endpoint,
    device = configuration$device_authorization_endpoint,
    logout = configuration$end_session_endpoint
  ))
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
  auth_server_no_slash <- gsub("/$", "", auth_server)
  return(paste0(auth_server_no_slash, "/"))
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
#'
#' @return The credentials retrieved from the token endpoint
#'
#' @importFrom utils browseURL
#' @importFrom httr GET RETRY POST stop_for_status content
#'
#' @examples
#' \dontrun{
#' endpoint <- discover("https://auth.molgenis.org")
#' device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
#' }
#'
#' @export
device_flow_auth <-
  function(endpoint, client_id, scopes = c("openid", "offline_access")) {

  .check_inputs(client_id, endpoint)
  device <- .get_device(endpoint$device)

  if (interactive()) {
    print(.make_browser_message(device))
  }

  verification_url <- .make_verification_url(device, client_id)
  .browse_url(verification_url)

    req <- httr2::request(endpoint$access) |>
      httr2::req_body_form( scope = paste(scopes, collapse = " "),
                     client_id = client_id,
                     grant_type = "urn:ietf:params:oauth:grant-type:device_code",
                     device_code = auth_res$device_code) |>
      httr2::req_retry(
        max_tries =  auth_res$expires_in / auth_res$interval,
        is_transient = function(resp) {
          httr2::resp_status(resp) == 400
        }
      )
    response <- httr2::req_perform(req)

    return(httr2::resp_body_json(response))
  }




.check_inputs <- function(client_id, endpoint) {
  assert_that(
    is.character(client_id),
    is.character(endpoint$device)
  )
}

.get_device <- function(device) {
  req <- httr2::request(device) |>
    httr2::req_body_form(
      client_id = client_id,
      scope = paste(scopes, collapse = " ")
    )
  response <- httr2::req_perform(req)
  auth_res <- httr2::resp_body_json(response)
  return(auth_res)
}

.make_browser_message <- function(device) {
  return(
    paste0(
      "We're opening a browser so you can log in with code ",
      device$user_code
    )
  )
}

.make_verification_url <- function(device, client_id) {
  return(
    param_set(
      device$verification_uri_complete,
      "client_id",
      client_id
    )
  )
}

.browse_url <- function(url) {
  utils::browseURL(url)
}
