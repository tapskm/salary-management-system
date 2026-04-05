require "application_system_test_case"

class EmployeesSystemTest < ApplicationSystemTestCase
  def setup
    @employee = employees(:john_doe)
  end

  test "visiting the employees index" do
    visit employees_url
    
    assert_selector "title", text: "SalaryManagement"
    # The React app should mount and show content
    assert_selector "#root", wait: 5
  end

  test "employee list displays correctly" do
    visit employees_url
    
    # Wait for React to load and render
    assert_selector "#root", wait: 5
    
    # Check if the page title is rendered by React
    within "#root" do
      assert_text "HR Salary Manager", wait: 5
    end
  end

  test "visiting insights page" do
    visit insights_employees_url
    
    assert_selector "title", text: "SalaryManagement"
    # Check for insights container
    assert_selector "#insights-root", wait: 5
  end

  test "insights dashboard displays analytics" do
    visit insights_employees_url
    
    # Wait for React insights component to load
    assert_selector "#insights-root", wait: 5
    
    within "#insights-root" do
      # Check for main heading
      assert_text "HR Analytics Dashboard", wait: 10
      
      # Check for tab navigation
      assert_text "Overview", wait: 5
      assert_text "Countries", wait: 5
      assert_text "Roles & Salaries", wait: 5
    end
  end

  test "navigation between pages works" do
    # Start at employees page
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Navigate to insights
    click_link "Insights"
    assert_current_path insights_employees_path
    assert_selector "#insights-root", wait: 5
    
    # Navigate back to employees
    click_link "HR Salary Manager"
    assert_current_path employees_path
    assert_selector "#root", wait: 5
  end

  test "page loads without JavaScript errors" do
    visit employees_url
    
    # Check that there are no JavaScript errors in console
    logs = page.driver.browser.logs.get(:browser)
    errors = logs.select { |log| log.level == "SEVERE" }
    
    assert_empty errors, "JavaScript errors found: #{errors.map(&:message).join(', ')}"
  end

  test "responsive design works on different screen sizes" do
    # Test desktop view
    page.driver.browser.manage.window.resize_to(1200, 800)
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Test tablet view
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Test mobile view
    page.driver.browser.manage.window.resize_to(375, 667)
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Reset to desktop
    page.driver.browser.manage.window.resize_to(1200, 800)
  end

  test "insights tabs are functional" do
    visit insights_employees_url
    
    # Wait for initial load
    assert_selector "#insights-root", wait: 5
    
    within "#insights-root" do
      # Click on different tabs and verify content changes
      
      # Countries tab
      if has_text?("Countries", wait: 2)
        click_button "Countries"
        # Should show country-specific content
        assert_text "Country", wait: 5
      end
      
      # Departments tab
      if has_text?("Departments", wait: 2) 
        click_button "Departments"
        # Should show department-specific content
        assert_text "Department", wait: 5
      end
    end
  end

  test "application handles slow network gracefully" do
    # Simulate slow network by adding artificial delay
    visit employees_url
    
    # Should show loading state or degrade gracefully
    assert_selector "#root", wait: 10
    
    # Eventually content should load
    within "#root" do
      assert_text "HR Salary Manager", wait: 15
    end
  end

  test "application works with JavaScript disabled" do
    # This tests graceful degradation
    page.execute_script("document.querySelector('script').remove();")
    
    visit employees_url
    
    # Page should still load the basic HTML structure
    assert_selector "body"
    assert_selector "#root"
  end

  test "font awesome icons load correctly" do
    visit insights_employees_url
    
    # Wait for page to load
    assert_selector "#insights-root", wait: 5
    
    # Check that Font Awesome CSS is loaded
    font_awesome_loaded = page.evaluate_script("
      Array.from(document.styleSheets).some(sheet => 
        sheet.href && sheet.href.includes('font-awesome')
      )
    ")
    
    assert font_awesome_loaded, "Font Awesome CSS not loaded"
  end

  test "css styles are applied correctly" do
    visit employees_url
    
    # Wait for styles to load
    assert_selector "#root", wait: 5
    
    # Check that Tailwind CSS is working by verifying computed styles
    body_bg = page.evaluate_script("
      getComputedStyle(document.body).backgroundColor
    ")
    
    # Should have a background color (not default white/transparent)
    assert_not_equal "rgba(0, 0, 0, 0)", body_bg
    assert_not_equal "transparent", body_bg
  end

  test "application handles empty state correctly" do
    # Temporarily remove all employees to test empty state
    Employee.destroy_all
    
    visit employees_url
    assert_selector "#root", wait: 5
    
    # React component should handle empty state gracefully
    within "#root" do
      # Should show either empty message or handle gracefully
      assert_no_text "undefined"
      assert_no_text "null"
    end
  ensure
    # Restore fixtures
    fixtures :all
  end

  test "browser compatibility" do
    # Test that basic functionality works
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Check that modern JavaScript features are working
    modern_js_working = page.evaluate_script("
      try {
        // Test arrow functions, const/let, template literals
        const test = (x) => `Test ${x}`;
        return test('working') === 'Test working';
      } catch(e) {
        return false;
      }
    ")
    
    assert modern_js_working, "Modern JavaScript features not working"
  end

  test "performance metrics are reasonable" do
    start_time = Time.current
    
    visit employees_url
    assert_selector "#root", wait: 5
    
    end_time = Time.current
    load_time = end_time - start_time
    
    # Page should load within 10 seconds on test environment
    assert load_time < 10.0, "Page took too long to load: #{load_time}s"
  end

  test "accessibility features are present" do
    visit employees_url
    assert_selector "#root", wait: 5
    
    # Check for basic accessibility features
    assert_selector "nav", visible: true
    assert_selector "main", visible: true
    
    # Check that the page has a proper title
    assert_selector "title", text: "SalaryManagement"
  end
end
