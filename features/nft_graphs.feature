Feature: Check NFT graphs from the web page
  As a user
  I want to see graphical representation of NFT data
  So I can see how things have progressed over time

  Background:
    Given I am logged in
    And I upload two NFT test reports

  Scenario: Should see JSON data in view mode
    When I view the report "1.2/Handset/NFT/N900"
    And  I should see "bps" within the first hidden ".nft_trend_graph_data"

  Scenario: Should see serial measurement JSON data in view mode
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "Max Data rate" within the first hidden ".nft_serial_trend_graph_data"
    Then I should see "Min Data rate" within the first hidden ".nft_serial_trend_graph_data"
    Then I should see "Med Data rate" within the first hidden ".nft_serial_trend_graph_data"
    Then I should see "Avg Data rate" within the first hidden ".nft_serial_trend_graph_data"

  Scenario: Should see "See history" link
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "See history"

  #TODO: Instead of verifying that DOM contains the data, the actual view should be verified with Selenium
  Scenario: Viewing NFT history
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "2011/08/08" within the first hidden ".nft_trend_graph_data"
    And I should see "2011/08/09" within the first hidden ".nft_trend_graph_data"
    And I should see "150" within the first hidden ".nft_trend_graph_data"

  # Note: the Selenium cases below are based on the JavaScript code updating
  # the title of the hidden modal windows - if we click an item and it works
  # at least to some extent, the title is changed. When these tests pass it
  # does not mean that the graph functionality works since the actual graph
  # may be broken.
  @javascript
  Scenario: Open and close NFT trend window
   When I view the report "1.2/Handset/NFT/N900"

   And I click on the first NFT trend button
   Then I should see "NFT Case 1: Throughput" within "#nft_trend_dialog"

   And I close the trend dialog

  @javascript
  Scenario: Open and close NFT trend window in history view
    When I view the report "1.2/Handset/NFT/N900"

    And I follow the first "See history"

    And I click on the first NFT trend graph
    Then I should see "NFT Case 1: Throughput" within "#nft_trend_dialog"

    And I close the trend dialog

  @javascript
  Scenario: Open and close NFT serial trend window in history view
    When I view the report "1.2/Handset/NFT/N900"

    And I follow the first "See history"

    And I click on the first NFT serial measurement trend graph
    Then I should see "Serial Case: Data rate" within "#nft_series_history_dialog"

    And I close the trend dialog
