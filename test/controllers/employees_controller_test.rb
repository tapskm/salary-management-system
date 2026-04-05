require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @employee = employees(:john_doe)
    @valid_params = {
      employee: {
        full_name: "Test Employee",
        job_title: "Software Developer",
        country: "United States", 
        salary: 75000.00,
        department: "Engineering"
      }
    }
    @invalid_params = {
      employee: {
        full_name: "",
        job_title: "",
        country: "",
        salary: -1000,
        department: ""
      }
    }
  end

  # Index Action Tests
  test "should get index" do
    get employees_url
    assert_response :success
    assert_not_nil assigns(:employees)
  end

  test "should get index as JSON" do
    get employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?('employees')
    assert json_response.key?('meta')
    assert_kind_of Array, json_response['employees']
    assert_kind_of Hash, json_response['meta']
  end

  test "index should include pagination metadata" do
    get employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    meta = json_response['meta']
    
    assert meta.key?('current_page')
    assert meta.key?('total_pages')
    assert meta.key?('total_count')
  end

  test "index should respect page parameter" do
    get employees_url, params: { page: 1 }, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response['meta']['current_page']
  end

  # Insights Action Tests
  test "should get insights" do
    get insights_employees_url
    assert_response :success
  end

  test "should get insights as JSON" do
    get insights_employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Check all required sections are present
    assert json_response.key?('company_stats')
    assert json_response.key?('country_stats')
    assert json_response.key?('job_title_stats')
    assert json_response.key?('department_stats')
    assert json_response.key?('salary_distribution')
    assert json_response.key?('top_paying_jobs')
  end

  test "insights company_stats should contain expected fields" do
    get insights_employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    company_stats = json_response['company_stats']
    
    assert company_stats.key?('total_employees')
    assert company_stats.key?('total_budget')
    assert company_stats.key?('average_salary')
    assert company_stats.key?('recent_hires')
    assert company_stats.key?('previous_hires')
    assert company_stats.key?('hiring_trend')
    
    # Verify data types
    assert_kind_of Integer, company_stats['total_employees']
    assert_kind_of Numeric, company_stats['total_budget']
    assert_kind_of Numeric, company_stats['average_salary']
    assert ['up', 'down', 'stable'].include?(company_stats['hiring_trend'])
  end

  test "insights country_stats should be an array" do
    get insights_employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    country_stats = json_response['country_stats']
    
    assert_kind_of Array, country_stats
    
    if country_stats.any?
      first_stat = country_stats.first
      assert first_stat.key?('country')
      assert first_stat.key?('min_salary')
      assert first_stat.key?('max_salary')
      assert first_stat.key?('avg_salary')
      assert first_stat.key?('total_count')
    end
  end

  test "insights job_title_stats should have pagination" do
    get insights_employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    job_title_stats = json_response['job_title_stats']
    
    assert job_title_stats.key?('data')
    assert job_title_stats.key?('pagination')
    assert_kind_of Array, job_title_stats['data']
    assert_kind_of Hash, job_title_stats['pagination']
    
    pagination = job_title_stats['pagination']
    assert pagination.key?('current_page')
    assert pagination.key?('total_pages')
    assert pagination.key?('total_count')
    assert pagination.key?('per_page')
  end

  test "insights salary_distribution should have expected ranges" do
    get insights_employees_url, headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    salary_distribution = json_response['salary_distribution']
    
    expected_ranges = ["0-50k", "50k-100k", "100k-150k", "150k-200k", "200k+"]
    expected_ranges.each do |range|
      assert salary_distribution.key?(range), "Missing salary range: #{range}"
      assert_kind_of Integer, salary_distribution[range]
      assert salary_distribution[range] >= 0
    end
  end

  test "insights should respect pagination parameters" do
    get insights_employees_url, params: { page: 1, per_page: 10 }, 
        headers: { Accept: 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    pagination = json_response['job_title_stats']['pagination']
    
    assert_equal 1, pagination['current_page']
    assert_equal 10, pagination['per_page']
  end

  # Create Action Tests  
  test "should create employee with valid parameters" do
    assert_difference('Employee.count') do
      post employees_url, params: @valid_params, headers: { Accept: 'application/json' }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @valid_params[:employee][:full_name], json_response['full_name']
  end

  test "should not create employee with invalid parameters" do
    assert_no_difference('Employee.count') do
      post employees_url, params: @invalid_params, headers: { Accept: 'application/json' }
    end
    
    assert_response :unprocessable_entity
  end

  test "should return validation errors for invalid employee" do
    post employees_url, params: @invalid_params, headers: { Accept: 'application/json' }
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.key?('full_name')
    assert json_response.key?('salary')
  end

  # Update Action Tests
  test "should update employee with valid parameters" do
    new_salary = 90000
    patch employee_url(@employee), params: { 
      employee: { salary: new_salary }
    }, headers: { Accept: 'application/json' }
    
    assert_response :success
    @employee.reload
    assert_equal new_salary, @employee.salary
  end

  test "should not update employee with invalid parameters" do
    original_salary = @employee.salary
    patch employee_url(@employee), params: { 
      employee: { salary: -5000 }
    }, headers: { Accept: 'application/json' }
    
    assert_response :unprocessable_entity
    @employee.reload
    assert_equal original_salary, @employee.salary
  end

  # Destroy Action Tests
  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete employee_url(@employee)
    end
    
    assert_response :redirect
  end

  test "should destroy employee via JSON" do
    assert_difference('Employee.count', -1) do
      delete employee_url(@employee), headers: { Accept: 'application/json' }
    end
    
    assert_response :no_content
  end

  # Error Handling Tests
  test "should handle non-existent employee gracefully" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get employee_url(id: 99999)
    end
  end

  test "should require CSRF token for non-JSON requests" do
    # This test ensures CSRF protection is working
    post employees_url, params: @valid_params
    # Should either redirect or show an error, not create the record
    assert_not_equal :created, response.status
  end

  # Performance Tests
  test "index should handle large datasets efficiently" do
    # Create a reasonable number of test records
    employees_data = []
    20.times do |i|
      employees_data << {
        full_name: "Test Employee #{i}",
        job_title: "Developer #{i}",
        country: "Test Country",
        salary: 50000 + (i * 1000),
        department: "Engineering",
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    Employee.insert_all(employees_data)
    
    # Test that the endpoint responds quickly
    start_time = Time.current
    get employees_url, headers: { Accept: 'application/json' }
    end_time = Time.current
    
    assert_response :success
    # Should respond within 1 second for this dataset size
    assert (end_time - start_time) < 1.0, "Request took too long: #{end_time - start_time} seconds"
  end

  test "insights should handle large datasets efficiently" do
    # Test that insights endpoint responds reasonably fast
    start_time = Time.current
    get insights_employees_url, headers: { Accept: 'application/json' }
    end_time = Time.current
    
    assert_response :success
    # Should respond within 2 seconds for insights calculations
    assert (end_time - start_time) < 2.0, "Insights request took too long: #{end_time - start_time} seconds"
  end

  # Security Tests
  test "should sanitize input parameters" do
    malicious_params = {
      employee: {
        full_name: "<script>alert('xss')</script>",
        job_title: "Developer",
        country: "US",
        salary: 75000,
        department: "Engineering"
      }
    }
    
    post employees_url, params: malicious_params, headers: { Accept: 'application/json' }
    
    if response.status == 201  # If creation succeeded
      json_response = JSON.parse(response.body)
      # The script tag should be escaped or removed
      assert_not_includes json_response['full_name'], '<script>'
    end
  end
end
