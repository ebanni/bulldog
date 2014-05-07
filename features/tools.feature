@tools
Feature: The tools menu provides access to a number of set up 
  and management utilities

  Background:
    Given I am a user with an account
    And I have a settings entry
    And I sign in

  Scenario: Document Settings
    Given I visit the home page
    And I click on Tools
    And I click on Invoice Setup
    Then I should be on the Invoice Setup page
    And I should see "Your Address Details"

  Scenario: VAT registration number on settings page
    Given VAT is enabled
    And I visit the settings page
    Then I should see "VAT Registration Number"
    When I click on Edit
    And I enter "12345678" in the setting_vat_reg_no field
    And I click button Save
    Then I should be on the Invoice Setup page
    And I should see "12345678"

  Scenario: No VAT fields when VAT not enabled
    Given I visit the settings page
    Then I should not see "Your VAT Details"
    And I should not see "VAT Registration Number"
    When I click on Edit
    Then I should not see "Your VAT Details"