Feature: Query API
  As an external service
  I want to get existing/allowed field values via REST API
  So reports can be partially validated before uploading

  Background:
    Given I am a user with a REST authentication token

  Scenario: Listing existing releases
    When I request API "/api/query/releases"
    Then I should get all releases existing in database
