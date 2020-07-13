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

  expected = httr::oauth_endpoint(
    authorize="https://example.org/oauth2/authorize",
    access = "https://example.org/oauth2/token",
    user = "https://example.org/oauth2/userinfo",
    device = "https://example.org/oauth2/device-authorize",
    logout = "https://example.org/oauth2/logout"
  )

  expect_equal(endpoint, expected)
  expect_args(httr_get,
              1,
              "https://example.org/.well-known/openid-configuration")
})
