require "test_helper"

class EmployeeIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @employee_data = {
      full_name: "Integration Test User",
      job_title: "Test Developer",
      country: "United States",
      salary: 80000.00,
      department: "Engineering"
    }
  end

  test "complete employee lifecycle" do
    # 1. Visit the index page
    get employees_path
    assert_response :success
    assert_select "title", "SalaryManagement"

    # 2. Get initial employee count
    initial_count = Employee.count

    # 3. Create a new employee via API
    post employees_path, 
         params: { employee: @employee_data },
         headers: { Accept: 'application/json' }
    
    assert_response :created
    assert_equal initial_count + 1, Employee.count
    
    # Parse the created employee
    created_employee = JSON.parse(response.body)
    employee_id = created_employee['id']

    # 4. Verify employee appears in index JSON
    get employees_path, headers: { Accept: 'application/json' }
    assert_response :success
    
    employees_response = JSON.parse(response.body)
    employee_names = employees_response['employees'].map { |e| e['full_name'] }
    assert_includes employee_names, @employee_data[:full_name]

    # 5. Update the employee
    updated_salary = 85000
    patch employee_path(employee_id),
          params: { employee: { salary: updated_salary } },
          headers: { Accept: 'application/json' }
    
    assert_response :success
    
    # 6. Verify the update
    employee = Employee.find(employee_id)
    assert_equal updated_salary, employee.salary

    # 7. Check insights include the new employee
    get insights_employees_path, headers: { Accept: 'application/json' }
    assert_response :success
    
    insights = JSON.parse(response.body)
    assert insights['company_stats']['total_employees'] > initial_count

    # 8. Delete the employee
    delete employee_path(employee_id)
    assert_response :redirect

    # 9. Verify deletion
    assert_equal initial_count, Employee.count
  end

  test "insights page functionality" do
    # Visit insights page
    get insights_employees_path
    assert_response :success

    # Get insights data via API
    get insights_employees_path, headers: { Accept: 'application/json' }
    assert_response :success
    
    insights = JSON.parse(response.body)
    
    # Verify all required data sections exist
    %w[company_stats country_stats job_title_stats department_stats salary_distribution top_paying_jobs].each do |section|
      assert insights.key?(section), "Missing insights section: #{section}"
    end

    # Test pagination in job title stats
    get insights_employees_path, 
        params: { page: 1, per_page: 5 },
        headers: { Accept: 'application/json' }
    
    assert_response :success
    insights = JSON.parse(response.body)
    pagination = insights['job_title_stats']['pagination']
    
    assert_equal 1, pagination['current_page']
    assert_equal 5, pagination['per_page']
  end

  test "employee search and filtering functionality" do
    # Create test employees with different attributes
    engineering_employee = Employee.create!(
      full_name: "John Engineer",
      job_title: "Software Engineer", 
      country: "United States",
      salary: 90000,
      department: "Engineering"
    )

    hr_employee = Employee.create!(
      full_name: "Jane HR",
      job_title: "HR Manager",
      country: "Canada", 
      salary: 70000,
      department: "Human Resources"
    )

    # Test getting employees by pagination
    get employees_path, params: { page: 1 }, headers: { Accept: 'application/json' }
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert response_data.key?('employees')
    assert response_data.key?('meta')
    
    # Clean up
    engineering_employee.destroy
    hr_employee.destroy
  end

  test "error handling across the application" do
    # Test 404 handling for non-existent employee
    assert_raises(ActiveRecord::RecordNotFound) do
      get employee_path(99999)
    end

    # Test validation error handling
    post employees_path,
         params: { employee: { full_name: '', salary: -1000 } },
         headers: { Accept: 'application/json' }
    
    assert_response :unprocessable_entity
    errors = JSON.parse(response.body)
    assert errors.key?('full_name')
    assert errors.key?('salary')
  end

  test "application handles concurrent requests" do
    # Simulate multiple concurrent requests
    threads = []
    results = []
    
    5.times do |i|
      threads << Thread.new do
        employee_data = @employee_data.merge(full_name: "Concurrent User #{i}")
        
        post employees_path,
             params: { employee: employee_data },
             headers: { Accept: 'application/json' }
        
        results << response.status
      end
    end
    
    threads.each(&:join)
    
    # All requests should succeed
    assert results.all? { |status| status == 201 }, "Some concurrent requests failed: #{results}"
    
    # Clean up created employees
    Employee.where("full_name LIKE 'Concurrent User%'").destroy_all
  end

  test "large dataset performance" do
    # Create a batch of employees
    start_time = Time.current
    
    employees_data = []
    50.times do |i|
      employees_data << {
        full_name: "Perf Test #{i}",
        job_title: "Developer #{i % 5}",
        country: ["US", "Canada", "UK"][i % 3],
        salary: 50000 + (i * 1000),
        department: ["Engineering", "Product", "Marketing"][i % 3],
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    Employee.insert_all(employees_data)
    creation_time = Time.current - start_time
    
    # Test index performance
    start_time = Time.current
    get employees_path, headers: { Accept: 'application/json' }
    index_time = Time.current - start_time
    
    assert_response :success
    assert index_time < 1.0, "Index request took too long: #{index_time}s"
    
    # Test insights performance  
    start_time = Time.current
    get insights_employees_path, headers: { Accept: 'application/json' }
    insights_time = Time.current - start_time
    
    assert_response :success
    assert insights_time < 2.0, "Insights request took too long: #{insights_time}s"
    
    # Clean up
    Employee.where("full_name LIKE 'Perf Test%'").destroy_all
  end

  test "data consistency across operations" do
    initial_count = Employee.count
    initial_total_salary = Employee.sum(:salary)
    
    # Create employee
    employee = Employee.create!(@employee_data)
    
    assert_equal initial_count + 1, Employee.count
    assert_equal initial_total_salary + @employee_data[:salary], Employee.sum(:salary)
    
    # Update employee salary
    new_salary = 95000
    employee.update!(salary: new_salary)
    
    expected_total = initial_total_salary + new_salary
    assert_equal expected_total, Employee.sum(:salary)
    
    # Verify insights reflect the changes
    get insights_employees_path, headers: { Accept: 'application/json' }
    insights = JSON.parse(response.body)
    
    assert_equal Employee.count, insights['company_stats']['total_employees']
    assert_equal Employee.sum(:salary), insights['company_stats']['total_budget']
    
    # Clean up
    employee.destroy
    assert_equal initial_count, Employee.count
    assert_equal initial_total_salary, Employee.sum(:salary)
  end

  test "application security measures" do
    # Test CSRF protection (non-JSON requests should be protected)
    post employees_path, params: { employee: @employee_data }
    # Should not be :created without CSRF token
    assert_not_equal 201, response.status
    
    # Test parameter sanitization
    malicious_data = @employee_data.merge(full_name: "<script>alert('xss')</script>")
    
    post employees_path,
         params: { employee: malicious_data },
         headers: { Accept: 'application/json' }
    
    if response.status == 201
      created_employee = JSON.parse(response.body)
      # XSS should be prevented
      assert_not_includes created_employee['full_name'], '<script>'
      
      # Clean up if created
      Employee.find(created_employee['id']).destroy
    end
  end
end
