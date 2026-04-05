require "application_system_test_case"

class EmployeesSystemTest < ApplicationSystemTestCase
  def setup
    @employee = employees(:john_doe)
  end

  test "visiting the employees index" do
    visit employees_url
    
    # Check that the page loads without major errors
    assert_selector "body"
    assert_no_text "Error"
    assert_no_text "500"
    assert_no_text "Internal Server Error"
  end

  test "visiting insights page" do
    visit insights_employees_url
    
    # Check that the page loads
    assert_selector "body" 
    assert_no_text "Error"
    assert_no_text "500"
    assert_no_text "Internal Server Error"
  end

  test "basic navigation works" do
    # Start at employees page
    visit employees_url
    assert_selector "body"
    
    # Try to visit insights
    visit insights_employees_url 
    assert_selector "body"
    
    # Navigate back to employees
    visit employees_url
    assert_selector "body"
  end

  test "pages load without server errors" do
    # Test main employee pages don't return server errors
    visit employees_url
    assert_no_text "Internal Server Error"
    assert_no_text "Application Error"
    assert_no_text "500"
    
    visit insights_employees_url  
    assert_no_text "Internal Server Error"
    assert_no_text "Application Error"
    assert_no_text "500"
  end

  test "basic html structure is present" do
    visit employees_url
    
    # Check basic HTML structure exists
    assert_selector "html"
    assert_selector "body"
    
    # Check that page loaded completely
    assert_no_text "Loading..."
    assert_no_text "undefined"
  end
end
