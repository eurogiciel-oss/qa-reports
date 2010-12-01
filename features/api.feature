Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Scenario: Uploading test report with HTTP POST
    Given I am an user with a REST authentication token
    And the client sends file "sim.xml" via REST API

    Then the REST result "ok" should be "1"
    And I should be able to view the created report


  Scenario: Sending REST import without valid report file
    Given I am an user with a REST authentication token
    And the client sends a request without file via REST API

    Then the REST result "ok" should be "0"

  Scenario: Sending REST import without valid parameters
    Given I am an user with a REST authentication token
    And the client sends an invalid request via REST API

    Then the REST result "ok" should be "0"
