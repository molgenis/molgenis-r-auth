test_that("discover copies endpoint info", {
  response <- structure(list(status_code = 200), class = "response")
  httr_get <- mock(response)
  content <- list(
    authorization_endpoint = "https://example.org/oauth2/authorize",
    token_endpoint = "https://example.org/oauth2/token",
    userinfo_endpoint = "https://example.org/oauth2/userinfo",
    device_authorization_endpoint =
      "https://example.org/oauth2/device-authorize",
    end_session_endpoint = "https://example.org/oauth2/logout"
  )
  httr_content <- mock(content)

  with_mock(
    endpoint <- discover("https://example.org"),
    "httr::GET" = httr_get,
    "httr::content" = httr_content
  )

  expected <- httr::oauth_endpoint(
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  expect_equal(endpoint, expected)
  expect_args(
    httr_get,
    1,
    "https://example.org/.well-known/openid-configuration"
  )
})

test_that("device flow retrieves token", {
  response <- structure(list(status_code = 200), class = "response")
  httr_retry <- mock(response)
  httr_post <- mock(response)
  browse <- mock()
  content <- list(
    user_code = "D4S5CVQ",
    verification_uri_complete =
      "https://example.org/oauth2/device?code=D4S5CVQ",
    verification_uri = "https://example.org/oauth2/device",
    device_code = "D4S5CVQ",
    interval = 5,
    expires_in = 60
  )
  credentials <- list(
    id_token <- "abcde"
  )
  httr_content <- mock(content, credentials)

  endpoint <- httr::oauth_endpoint(
    authorize = "https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    device = "https://example.org/oauth2/device-authorize",
  )
  client_id <- "6fca9d08-c514-11ea-87d0-0242ac130003"
  with_mock(
    result <- device_flow_auth(endpoint, client_id),
    "MolgenisAuth:::.browse_url" = browse,
    "httr::RETRY" = httr_retry,
    "httr::POST" = httr_post,
    "httr::content" = httr_content
  )

  expect_equal(credentials, result)

  expect_args(httr_post,
    1,
    "https://example.org/oauth2/device-authorize",
    body = list(
      client_id = "6fca9d08-c514-11ea-87d0-0242ac130003",
      scope = "openid offline_access"
    )
  )

  expect_args(httr_retry,
    1,
    url = "https://example.org/oauth2/token",
    verb = "POST",
    pause_base = 5,
    pause_cap = 5,
    pause_min = 5,
    times = 12,
    quiet = TRUE,
    body = list(
      "client_id" = "6fca9d08-c514-11ea-87d0-0242ac130003",
      "grant_type" = "urn:ietf:params:oauth:grant-type:device_code",
      "device_code" = "D4S5CVQ"
    )
  )

  expect_args(
    browse,
    1,
    paste0(
      "https://example.org/oauth2/device",
      "?code=D4S5CVQ&client_id=6fca9d08-c514-11ea-87d0-0242ac130003"
    )
  )
})
