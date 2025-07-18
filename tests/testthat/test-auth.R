library(testthat)
library(httr2)
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

test_that(".build_auth_request correctly builds the request", {
  endpoint <- list(
    request = NULL,
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
  scopes <- c("openid", "offline_access")

  req <- .build_auth_request(endpoint, client_id, scopes)

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "https://example.org/oauth2/device-authorize")
  expect_null(req$method)
  expect_equal(req$headers, list())
  expect_equal(req$body$type, "form")
  expect_identical(as.character(req$body$data$client_id), client_id)
  expect_identical(as.character(req$body$data$scope), "openid%20offline_access")
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
    .make_verification_url(auth_res, client_id), "Not compatible with STRSXP: [type=NULL].",
    fixed = TRUE)

})

test_that(".browse_url tries to open page with correct URL", {

  test_url <- "https://example.com"

  expected <- testthat::with_mocked_bindings(
    .browse_url(test_url),
    browseURL = function(url) return(url),
    .package = "utils"
  )

  expect_equal(expected, test_url)

})

test_that(".request_token_via_browser works", {
  auth_res <- list(verification_uri_complete = "https://example.com/verify")
  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"

  returned <- with_mocked_bindings(
    .request_token_via_browser(auth_res, client_id),
    ".browse_url" = function(verification_url) "browsing")
  expect_equal(returned, "browsing")
}) # I think code cov will complain about not testing for interactive = F

test_that(".add_credential_body correctly adds the body", {
  req <- request("https://example.org/oauth2/token")

  scopes <- c("openid", "offline_access")
  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"
  grant_type <- "urn:ietf:params:oauth:grant-type:device_code"
  auth_res <- list(
    device_code = "ncEfhoD8wx085imJCBMPGWnCYtdLZeHWl3hGen4cS0Q",
    expires_in = 1800,
    interval = 5,
    user_code = "7ZNG6Q",
    verification_uri = "https://example.org/oauth2/device",
    verification_uri_complete = "https://example.org/oauth2/device?user_code=7ZNG6Q"
  )

  observed <- .add_credential_body(req, client_id, scopes, auth_res)

  expect_s3_class(observed, "httr2_request")
  expect_equal(observed$url, "https://example.org/oauth2/token")

  body <- observed$body
  data <- body$data

  expect_equal(body$type, "form")
  expect_identical(as.character(data$scope), "openid%20offline_access")
  expect_identical(as.character(data$client_id), client_id)
  expect_identical(as.character(data$grant_type), "urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code")
  expect_identical(as.character(data$device_code), auth_res$device_code)
})


test_that(".add_credential_retry correctly adds the retry options", {
  scopes <- c("openid", "offline_access")
  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"

  auth_res <- list(
    device_code = "0AS2fIeoOiga1W-QYmU1-oW2JnpM9U_lcap6oJlvcXw",
    expires_in = 1800,
    interval = 5,
    user_code = "7ZNG6Q",
    verification_uri = "https://auth.molgenis.org/oauth2/device",
    verification_uri_complete = "https://auth.molgenis.org/oauth2/device?user_code=7ZNG6Q"
  )

  req <- request("https://example.org/oauth2/token") |>
    .add_credential_body(client_id, scopes, auth_res)

  observed <- .add_credential_retry(req, auth_res)

  expect_s3_class(observed, "httr2_request")

  # Check individual retry-related policies (flat structure)
  policies <- observed$policies

  expect_true("retry_max_tries" %in% names(policies))
  expect_true("retry_is_transient" %in% names(policies))

  expect_equal(policies$retry_max_tries, auth_res$expires_in / auth_res$interval)
  expect_true(is.function(policies$retry_is_transient))
})

test_that("discover copies endpoint info", {
  perform_args <- NULL
  request_args <- NULL

  req_perform_mock <- function(req) {
    perform_args <<- req
    structure(list(status_code = 200), class = "response")
  }

  resp_body_json_mock <- function(resp) {
    request_args <<- resp
    list(
      request = NULL,
      authorization_endpoint = "https://example.org/oauth2/authorize",
      token_endpoint = "https://example.org/oauth2/token",
      userinfo_endpoint = "https://example.org/oauth2/userinfo",
      device_authorization_endpoint = "https://example.org/oauth2/device-authorize",
      end_session_endpoint = "https://example.org/oauth2/logout"
    )
  }

  endpoint <- testthat::with_mocked_bindings(
    discover("https://example.org"),
    "req_perform" = req_perform_mock,
    "resp_body_json" = resp_body_json_mock
  )

  # Check relevant request fields
  expect_s3_class(perform_args, "httr2_request")
  expect_equal(perform_args$url, "https://example.org/.well-known/openid-configuration")
  expect_equal(perform_args$method, NULL)

  # Check structure of response passed to resp_body_json
  expect_type(request_args, "list")
  expect_s3_class(request_args, "response")
  expect_equal(request_args$status_code, 200)

  # Check final result from discover()
  expected <- list(
    request = NULL,
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  expect_equal(endpoint, expected)
})


test_that("device_flow_auth correctly returns token info", {
  endpoint <- list(
    request = NULL,
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  scopes <- c("openid", "offline_access")
  client_id <- "b396233b-cdb2-449e-ac5c-a0d28b38f791"

  build_auth_request_args <- NULL
  req_perform_args <- NULL
  resp_body_json_args <- NULL
  request_token_via_browser_args <- NULL

  .build_auth_request_mock <- function(endpoint, client_id, scopes) {
    build_auth_request_args <<- list(endpoint, client_id, scopes)
    return(request("https://mock-auth"))
  }

  req_perform_mock <- function(req) {
    req_perform_args <<- req
    return("req_performed")
  }

  resp_body_json_mock <- function(req) {
    resp_body_json_args <<- req
    return(list(
      status = 200,
      expires_in = 1800,
      interval = 5,
      device_code = "mock-code",
      user_code = "1234",
      verification_uri = "https://example.org/oauth2/device",
      verification_uri_complete = "https://example.org/oauth2/device?user_code=1234"
    ))
  }

  .request_token_via_browser_mock <- function(auth_res, client_id) {
    request_token_via_browser_args <<- list(auth_res, client_id)
    return("got token")
  }

  observed <- testthat::with_mocked_bindings(
    device_flow_auth(endpoint, client_id, scopes),
    ".build_auth_request" = .build_auth_request_mock,
    "req_perform" = req_perform_mock,
    "resp_body_json" = resp_body_json_mock,
    ".request_token_via_browser" = .request_token_via_browser_mock
  )

  # Check that the final response contains expected fields
  expect_equal(observed$status, 200)
  expect_equal(observed$expires_in, 1800)
  expect_equal(observed$interval, 5)

  # Check that .build_auth_request was called with expected args
  expect_equal(
    build_auth_request_args,
    list(endpoint, client_id, scopes)
  )

  # Check that req_perform received an httr2_request
  expect_s3_class(req_perform_args, "httr2_request")

  expect_true(all(
    c("url", "method", "headers", "body", "fields", "options", "policies") %in% names(req_perform_args)
  ))

  # Check that resp_body_json got the correct input
  expect_equal(resp_body_json_args, "req_performed")

  # Check .request_token_via_browser received expected args
  expect_equal(request_token_via_browser_args[[2]], client_id)
  expect_equal(request_token_via_browser_args[[1]]$status, 200)
})

