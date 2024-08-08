library(testthat)
library(assertthat)

test_that(".ensure_single_slash adds a single trailing slash when absent", {
  expect_equal(.ensure_single_slash("https://example.com"), "https://example.com/")
  expect_equal(.ensure_single_slash("https://example.com/path/to/resource"),
               "https://example.com/path/to/resource/")
})

test_that(".ensure_single_slash removes >1 trailing slash", {
  expect_equal(.ensure_single_slash("https://example.com///"), "https://example.com/")
})

test_that(".ensure_single_slash returns input when there is single trailing slash", {
  expect_equal(.ensure_single_slash("https://example.com/"), "https://example.com/")
  expect_equal(.ensure_single_slash("https://example.com/path/to/resource/"),
               "https://example.com/path/to/resource/")
})

test_that(".check_inputs correctly validates input types", {
  expect_silent(.check_inputs(list(device = "device_value"), "client_id_value"))
})

test_that(".check_inputs returns error when input types incorrect", {

  expect_error(
    .check_inputs(list(device = "device_value"), 12345),
    "client_id is not a character vector",
    fixed = TRUE
    )

  expect_error(
    .check_inputs(list(device = 67890), "client_id_value"),
    "endpoint$device is not a character vector",
    fixed = TRUE
    )

  expect_error(
    .check_inputs(list(), "client_id_value"),
    "endpoint$device is not a character vector",
    fixed = TRUE
    )

  expect_error(
    .check_inputs(list(device = 67890), 12345),
    "client_id is not a character vector",
    fixed = TRUE
    )
})

test_that(".build_auth_request correctly builds the request",

          endpoint <- list(
            request = NULL,
            authorize = "https://example.org/oauth2/authorize",
            access = "https://example.org/oauth2/token",
            user = "https://example.org/oauth2/userinfo",
            device = "https://example.org/oauth2/device-authorize",
            logout = "https://example.org/oauth2/logout"
          )

          client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
          scopes = c("openid", "offline_access")

          expected <- list(
            url = "https://auth.molgenis.org/oauth2/device_authorize",
            method = NULL,
            headers = list(),
            body = list(
              data = list(
                client_id = structure("b396233b-cdb2-449e-ac5c-a0d28b38f791", class = "AsIs"),
                scope = structure("openid%20offline_access", class = "AsIs")
              ),
              type = "form",
              content_type = "application/x-www-form-urlencoded",
              params = list()
            ),
            fields = list(),
            options = list(),
            policies = list()
          )

          attr(expected, "class") <- "httr2_request"

          expect_equal(
            .build_auth_request(endpoint, client_id, scopes),
            expected
          )

})

test_that(".make_browser_message constructs the correct message with different inputs", {

  auth_res <- list(user_code = "ABC123")
  expected_message <- "We're opening a browser so you can log in with code ABC123"
  expect_equal(.make_browser_message(auth_res), expected_message)

  auth_res <- list(user_code = 123456)
  expected_message <- "We're opening a browser so you can log in with code 123456"
  expect_equal(.make_browser_message(auth_res), expected_message)

  auth_res <- list(user_code = "XYZ-789")
  expected_message <- "We're opening a browser so you can log in with code XYZ-789"
  expect_equal(.make_browser_message(auth_res), expected_message)

})

test_that(".make_browser_message returns message without code when code is absent", {

  auth_res <- list(user_code = "")
  expected_message <- "We're opening a browser so you can log in with code "
  expect_equal(.make_browser_message(auth_res), expected_message)

  auth_res <- list(user_code = NULL)
  expect_equal(.make_browser_message(auth_res), expected_message)
})

test_that(".make_verification_url constructs the correct verification URL", {

  auth_res <- list(verification_uri_complete = "https://example.com/verify")
  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
  expected_url <- "https://example.com/verify?client_id=b396233b-cdb2-449e-ac5c-a0d28b38f791"
  expect_equal(.make_verification_url(auth_res, client_id), expected_url)

  auth_res <- list(verification_uri_complete = "https://example.com/verify?existing_param=value")
  expected_url <- "https://example.com/verify?existing_param=value&client_id=b396233b-cdb2-449e-ac5c-a0d28b38f791"
  expect_equal(.make_verification_url(auth_res, client_id), expected_url)

})

test_that(".make_verification_url throws error if client ID not provided", {

  auth_res <- list(verification_uri_complete = "https://example.com/verify")
  client_id <- NULL
  expect_error(
    .make_verification_url(device, client_id), "Not compatible with STRSXP: [type=NULL].",
    fixed = TRUE)

})

test_that(".browse_url tries to open page with correct URL", {

  test_url <- "https://example.com"

  expected <- with_mocked_bindings(
    .browse_url(test_url),
    browseURL = function(url) return(url),
    .package = "utils"
  )

  expect_equal(expected, test_url)

})

test_that(".add_credential_body correctly adds the body", {

req <- request("https://example.org/oauth2/token")

scopes <- c("openid", "offline_access")
client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
grant_type <- "urn:ietf:params:oauth:grant-type:device_code"
auth_res <- list(
  device_code = "0AS2fIeoOiga1W-QYmU1-oW2JnpM9U_lcap6oJlvcXw",
  expires_in = 1800,
  interval = 5,
  user_code = "7ZNG6Q",
  verification_uri = "https://auth.molgenis.org/oauth2/device",
  verification_uri_complete = "https://auth.molgenis.org/oauth2/device?user_code=7ZNG6Q"
)

expected <- list(
    url = "https://example.org/oauth2/token",
    method = NULL,
    headers = list(),
    body = list(
      data = list(
        scope = structure("openid%20offline_access", class = "AsIs"),
        client_id = structure("b396233b-cdb2-449e-ac5c-a0d28b38f791", class = "AsIs"),
        grant_type = structure("urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code", class = "AsIs"),
        device_code = structure("ncEfhoD8wx085imJCBMPGWnCYtdLZeHWl3hGen4cS0Q", class = "AsIs")
      ),
      type = "form",
      content_type = "application/x-www-form-urlencoded",
      params = list()
    ),
    fields = list(),
    options = list(),
    policies = list()
  )

attr(expected, "class") <- "httr2_request"

observed <- .add_credential_body(req, client_id, scopes, auth_res)

expect_equal(expected, observed)

})

test_that(".add_credential_retry correctly adds the retry options", {

scopes <- c("openid", "offline_access")
client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
grant_type <- "urn:ietf:params:oauth:grant-type:device_code"

auth_res <- list(
  device_code = "0AS2fIeoOiga1W-QYmU1-oW2JnpM9U_lcap6oJlvcXw",
  expires_in = 1800,
  interval = 5,
  user_code = "7ZNG6Q",
  verification_uri = "https://auth.molgenis.org/oauth2/device",
  verification_uri_complete = "https://auth.molgenis.org/oauth2/device?user_code=7ZNG6Q"
)

req <- request("https://example.org/oauth2/token") |>
  .add_credential_body(client_id, scope, auth_res)

retry_is_transient <- function(resp) {
  resp_status(resp) == 400
}

observed <- .add_credential_retry(req, auth_res)

expect_equal(
  names(observed),
  c("url", "method", "headers", "body", "fields", "options", "policies")
)

expect_equal(
  dimnames(summary(observed$policies))[[1]],
  c("retry_max_tries", "retry_is_transient")
)

expect_equal(
  class(observed),
  "httr2_request"
  )

})

test_that("discover copies endpoint info", {
  response <- structure(list(status_code = 200), class = "response")
  content <- list(
    authorization_endpoint = "https://example.org/oauth2/authorize",
    token_endpoint = "https://example.org/oauth2/token",
    userinfo_endpoint = "https://example.org/oauth2/userinfo",
    device_authorization_endpoint =
      "https://example.org/oauth2/device-authorize",
    end_session_endpoint = "https://example.org/oauth2/logout"
  )

  endpoint <- with_mocked_bindings(
    discover("https://example.org"),
    "request" = function(base_url) "test",
    "req_perform" = function(req) response,
    "resp_body_json" = function(response) content,
    .package = "httr2"
  )

  expected <- list(
    request = NULL,
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  expect_equal(endpoint, expected)

  # expect_args(
  #   response,
  #   1,
  #   "https://example.org/.well-known/openid-configuration"
  # ) Don't quite understand this - Mariska let's chat.
})






#
#
#
#
# expected <- list(
#   url = "https://example.org/oauth2/token",
#   method = NULL,
#   headers = list(),
#   body = list(
#     data = list(
#       scope = structure("openid%20offline_access", class = "AsIs"),
#       client_id = structure("b396233b-cdb2-449e-ac5c-a0d28b38f791", class = "AsIs"),
#       grant_type = structure("urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code", class = "AsIs"),
#       device_code = structure("ncEfhoD8wx085imJCBMPGWnCYtdLZeHWl3hGen4cS0Q", class = "AsIs")
#     ),
#     type = "form",
#     content_type = "application/x-www-form-urlencoded",
#     params = list()
#   ),
#   fields = list(),
#   options = list(),
#   policies = list()
# )
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# test_that("", {
#
#
#   library(testthat)
#   library(mockr)
#   library(httr2)
#
#
#
#   # Define the unit test
#   test_that("device flow retrieves token", {
#
#     mock_endpoint <- list(
#       device = "https://example.org/oauth2/device-authorize",
#       access = "https://example.org/oauth2/token"
#     )
#
#     mock_client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
#
#     mock_auth_res <- list(
#       user_code = "123456",
#       verification_uri_complete = "https://example.org/verify",
#       device_code = "abc123",
#       expires_in = 1800,
#       interval = 5
#     )
#
#     mock_token_res <- list(
#       access_token = "mock_access_token",
#       refresh_token = "mock_refresh_token"
#     )
#
#     mock_browse_url <- function(url) {
#       print(paste("Mock browser opened at", url))
#     }
#
#     with_mocked_bindings(
#       {
#         # Call the function with mocked dependencies
#         result <- device_flow_auth(
#           endpoint = mock_endpoint,
#           client_id = mock_client_id
#         )
#       },
#       # Mocking httr2::request to avoid actual HTTP requests
#       request = function(url) {
#         structure(
#           list(
#             url = url,
#             method = NULL,
#             headers = list(),
#             body = NULL,
#             fields = list(),
#             options = list(),
#             policies = list()
#           ),
#           class = "httr2_request"
#         )
#       },
#
#       # Mocking httr2::req_body_form to return the request object
#       req_body_form = function(req, ...) {
#         req$body <- list(...)
#         return(req)
#       },
#
#       # Mocking httr2::req_perform to return a mock response
#       req_perform = function(req) {
#         if (req$url == mock_endpoint$device) {
#           return(structure(list(
#             status_code = 200,
#             content = mock_auth_res
#           ), class = "httr2_response"))
#         } else if (req$url == mock_endpoint$access) {
#           return(structure(list(
#             status_code = 200,
#             content = mock_token_res
#           ), class = "httr2_response"))
#         }
#       },
#
#       # Mocking httr2::resp_body_json to extract mock response content
#       resp_body_json = function(resp) {
#         return(resp$content)
#       },
#
#       # Mocking .browse_url to prevent actual browser interaction
#       .browse_url = mock_browse_url,
#       .package = "httr2"
#     )
#
#     # Assertions to ensure the function returns the expected output
#     expect_equal(result$access_token, "mock_access_token")
#     expect_equal(result$refresh_token, "mock_refresh_token")
#   })
#
#
#
#
#
#
#   test_that("device flow retrieves token", {
#
#   endpoint <- list(
#     request = NULL,
#     authorize = "https://example.org/oauth2/authorize",
#     access = "https://example.org/oauth2/token",
#     user = "https://example.org/oauth2/userinfo",
#     device = "https://example.org/oauth2/device-authorize",
#     logout = "https://example.org/oauth2/logout"
#   )
#
#
#   response <- structure(list(status_code = 200), class = "response")
#
#   content <- list(
#     device_code = "D4S5CVQ",
#     expires_in = 60
#     interval = 5,
#     user_code = "D4S5CVQ",
#     verification_uri = "https://example.org/oauth2/device",
#     verification_uri_complete =
#       "https://example.org/oauth2/device?code=D4S5CVQ"
#     )
#
#   request = function(base_url) {
#     if(base_url == endpoint$device){
#       list(
#         url = "https://example.org/oauth2/device_authorize",
#         method = NULL,
#         headers = list(),
#         body = NULL,
#         fields = list(),
#         options = list(),
#         policies = list())
#     } else if(base_url = endpoint$access) {
#       list(
#         url = "https://example.org/oauth2/token",
#         method = NULL,
#         headers = list(),
#         body = NULL,
#         fields = list(),
#         options = list(),
#         policies = list()
#         )
#     }
#   }
#
#
#
#
#       }
#   }
#
#   req_perform = function(req) {
#     if (req$url == mock_endpoint$device) {
#       return(structure(list(
#         status_code = 200,
#         content = mock_auth_res
#       ), class = "httr2_response"))
#     } else if (req$url == mock_endpoint$access) {
#       return(structure(list(
#         status_code = 200,
#         content = mock_token_res
#       ), class = "httr2_response"))
#     }
#   }
#
#   observed <- with_mocked_bindings(
#     device_flow_auth(endpoint, "6fca9d08-c514-11ea-87d0-0242ac130003"),
#     request = function(device) request_list,
#     req_perform = function(req) req_perform,
#     resp_body_json = function(response) content,
#     .browse_url = function() "",
#     .package = "httr2")
#
#
#   endpoint <- discover("https://auth.molgenis.org")
#   device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
#
#
#   response <- structure(list(status_code = 200), class = "response")
#   httr_retry <- mock(response)
#   httr_post <- mock(response)
#   browse <- mock()
#   content <- list(
#     user_code = "D4S5CVQ",
#     verification_uri_complete =
#       "https://example.org/oauth2/device?code=D4S5CVQ",
#     verification_uri = "https://example.org/oauth2/device",
#     device_code = "D4S5CVQ",
#     interval = 5,
#     expires_in = 60
#   )
#   credentials <- list(
#     id_token <- "abcde"
#   )
#   httr_content <- mock(content, credentials)
#
#   endpoint <- httr::oauth_endpoint(
#     authorize = "https://example.org/oauth2/authorize",
#     access = "https://example.org/oauth2/token",
#     device = "https://example.org/oauth2/device-authorize",
#   )
#   client_id <- "6fca9d08-c514-11ea-87d0-0242ac130003"
#   with_mock(
#     result <- device_flow_auth(endpoint, client_id),
#     "MolgenisAuth:::.browse_url" = browse,
#     "httr::RETRY" = httr_retry,
#     "httr::POST" = httr_post,
#     "httr::content" = httr_content
#   )
#
#   expect_equal(credentials, result)
#
#   expect_args(httr_post,
#     1,
#     "https://example.org/oauth2/device-authorize",
#     body = list(
#       client_id = "6fca9d08-c514-11ea-87d0-0242ac130003",
#       scope = "openid offline_access"
#     )
#   )
#
#   expect_args(httr_retry,
#     1,
#     url = "https://example.org/oauth2/token",
#     verb = "POST",
#     pause_base = 5,
#     pause_cap = 5,
#     pause_min = 5,
#     times = 12,
#     quiet = TRUE,
#     body = list(
#       "client_id" = "6fca9d08-c514-11ea-87d0-0242ac130003",
#       "grant_type" = "urn:ietf:params:oauth:grant-type:device_code",
#       "device_code" = "D4S5CVQ"
#     )
#   )
#
#   expect_args(
#     browse,
#     1,
#     paste0(
#       "https://example.org/oauth2/device",
#       "?code=D4S5CVQ&client_id=6fca9d08-c514-11ea-87d0-0242ac130003"
#     )
#   )
# })
#
# endpoint <- discover("https://auth.molgenis.org")
# expected <- device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
#
# auth_server <- "https://auth.molgenis.org"
