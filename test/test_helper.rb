ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helper methods for all tests
    
    # Create a valid employee for testing
    def create_test_employee(overrides = {})
      default_attributes = {
        full_name: "Test Employee #{rand(1000)}",
        job_title: "Software Developer",
        country: "United States",
        salary: 75000.00,
        department: "Engineering"
      }
      
      Employee.create!(default_attributes.merge(overrides))
    end

    # Create multiple test employees for bulk testing
    def create_test_employees(count, base_attributes = {})
      employees_data = []
      
      count.times do |i|
        employees_data << {
          full_name: "Test Employee #{i}",
          job_title: ["Developer", "Manager", "Analyst", "Designer"][i % 4],
          country: ["United States", "India", "Germany", "Canada"][i % 4],
          salary: 50000 + (i * 1000),
          department: ["Engineering", "Product", "Marketing", "Sales"][i % 4],
          created_at: Time.current,
          updated_at: Time.current
        }.merge(base_attributes)
      end
      
      Employee.insert_all(employees_data)
    end

    # Clean up test employees by name pattern
    def cleanup_test_employees(pattern = "Test Employee%")
      Employee.where("full_name LIKE ?", pattern).destroy_all
    end

    # Assert JSON response structure
    def assert_json_response(response, expected_keys)
      assert_response :success
      json_data = JSON.parse(response.body)
      
      expected_keys.each do |key|
        assert json_data.key?(key), "JSON response missing key: #{key}"
      end
      
      json_data
    end

    # Assert paginated response structure
    def assert_paginated_response(response)
      json_data = assert_json_response(response, ['data', 'pagination'])
      pagination = json_data['pagination']
      
      %w[current_page total_pages total_count per_page].each do |key|
        assert pagination.key?(key), "Pagination missing key: #{key}"
      end
      
      json_data
    end

    # Time a block execution
    def time_execution(&block)
      start_time = Time.current
      result = block.call
      end_time = Time.current
      
      [result, end_time - start_time]
    end

    # Assert execution time is under threshold
    def assert_performance(threshold_seconds, message = "Operation took too long")
      start_time = Time.current
      yield
      end_time = Time.current
      
      execution_time = end_time - start_time
      assert execution_time < threshold_seconds, "#{message}: #{execution_time}s"
    end

    # Assert no N+1 queries
    def assert_no_n_plus_one_queries
      queries_before = count_queries
      yield
      queries_after = count_queries
      
      query_count = queries_after - queries_before
      # Allow for reasonable number of queries (adjust threshold as needed)
      assert query_count < 10, "Too many queries executed: #{query_count}"
    end

    # Temporarily suppress stdout during test (for noisy operations)
    def suppress_output
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
    ensure
      $stdout = original_stdout
    end

    private

    def count_queries
      # Simple query counter (you might want to use a more sophisticated approach)
      ActiveRecord::Base.connection.query_cache.size
    end
  end
end

# Custom assertions for employee-specific testing
module EmployeeTestAssertions
  def assert_valid_employee(employee)
    assert employee.valid?, "Employee should be valid: #{employee.errors.full_messages}"
  end

  def assert_employee_attributes(employee, expected_attributes)
    expected_attributes.each do |key, value|
      assert_equal value, employee.send(key), "Employee #{key} doesn't match expected value"
    end
  end

  def assert_salary_range(salary, min, max)
    assert salary >= min, "Salary #{salary} is below minimum #{min}"
    assert salary <= max, "Salary #{salary} is above maximum #{max}"
  end

  def assert_valid_country(country)
    # List of valid countries for testing
    valid_countries = ["United States", "India", "Germany", "Canada", "United Kingdom", "Spain", "France"]
    assert_includes valid_countries, country, "Invalid country: #{country}"
  end

  def assert_valid_department(department)
    # List of valid departments for testing
    valid_departments = ["Engineering", "Product", "Marketing", "Sales", "Human Resources", "Data Science"]
    assert_includes valid_departments, department, "Invalid department: #{department}"
  end
end

# Include custom assertions in test classes
ActiveSupport::TestCase.include EmployeeTestAssertions
