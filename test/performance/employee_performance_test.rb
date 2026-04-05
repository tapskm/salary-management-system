require "test_helper"

class EmployeePerformanceTest < ActiveSupport::TestCase
  def setup
    # Clear any existing test data
    Employee.where("full_name LIKE 'Perf Test%'").destroy_all
  end

  def teardown
    # Clean up test data
    Employee.where("full_name LIKE 'Perf Test%'").destroy_all
  end

  test "bulk employee creation performance" do
    # Test creating 1000 employees using insert_all (realistic seed scenario)
    employees_data = []
    
    1000.times do |i|
      employees_data << {
        full_name: "Perf Test Employee #{i}",
        job_title: ["Developer", "Manager", "Analyst", "Designer"][i % 4],
        country: ["United States", "India", "Germany", "Canada"][i % 4], 
        salary: 40000 + (i * 50),
        department: ["Engineering", "Product", "Marketing", "Sales"][i % 4],
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    # Measure bulk insert performance
    start_time = Time.current
    Employee.insert_all(employees_data)
    end_time = Time.current
    
    bulk_insert_time = end_time - start_time
    
    # Should complete within 5 seconds for 1000 records
    assert bulk_insert_time < 5.0, "Bulk insert took too long: #{bulk_insert_time}s"
    assert_equal 1000, Employee.where("full_name LIKE 'Perf Test%'").count
  end

  test "query performance with large dataset" do
    # Create 500 test employees first
    create_test_employees(500)
    
    # Test various query performance scenarios
    queries = [
      -> { Employee.where(country: "United States").count },
      -> { Employee.where(department: "Engineering").average(:salary) },
      -> { Employee.group(:country).count },
      -> { Employee.group(:department).average(:salary) },
      -> { Employee.where("salary > ?", 80000).count },
      -> { Employee.order(:salary).limit(10) }
    ]
    
    queries.each_with_index do |query, index|
      start_time = Time.current
      result = query.call
      end_time = Time.current
      
      query_time = end_time - start_time
      assert query_time < 1.0, "Query #{index + 1} took too long: #{query_time}s"
      assert_not_nil result
    end
  end

  test "pagination performance" do
    create_test_employees(200)
    
    # Test pagination with different page sizes
    [10, 25, 50, 100].each do |per_page|
      start_time = Time.current
      
      paginated = Employee.where("full_name LIKE 'Perf Test%'")
                         .page(1).per(per_page)
      
      # Force query execution
      paginated.to_a
      paginated.total_pages
      paginated.total_count
      
      end_time = Time.current
      
      pagination_time = end_time - start_time
      assert pagination_time < 0.5, "Pagination with #{per_page} per page took too long: #{pagination_time}s"
    end
  end

  test "aggregation query performance" do
    create_test_employees(300)
    
    aggregation_queries = [
      -> { Employee.group(:country).select(:country, "AVG(salary) as avg_salary", "COUNT(*) as count") },
      -> { Employee.group(:department).select(:department, "SUM(salary) as total", "COUNT(*) as count") },
      -> { Employee.group(:job_title).select(:job_title, "MAX(salary) as max_salary", "MIN(salary) as min_salary") },
      -> { Employee.where("created_at > ?", 30.days.ago).group(:country).count }
    ]
    
    aggregation_queries.each_with_index do |query, index|
      start_time = Time.current
      result = query.call.to_a  # Force execution
      end_time = Time.current
      
      query_time = end_time - start_time
      assert query_time < 1.0, "Aggregation query #{index + 1} took too long: #{query_time}s"
      assert result.is_a?(Array)
    end
  end

  test "salary distribution calculation performance" do
    create_test_employees(400)
    
    start_time = Time.current
    distribution = Employee.salary_distribution
    end_time = Time.current
    
    calculation_time = end_time - start_time
    assert calculation_time < 2.0, "Salary distribution calculation took too long: #{calculation_time}s"
    
    # Verify the distribution structure
    assert_kind_of Hash, distribution
    assert_equal 5, distribution.keys.length
    
    total_employees = distribution.values.sum
    assert total_employees > 0
  end

  test "concurrent read performance" do
    create_test_employees(100)
    
    # Simulate multiple concurrent read operations
    threads = []
    results = []
    
    start_time = Time.current
    
    10.times do |i|
      threads << Thread.new do
        thread_results = []
        
        # Each thread performs multiple operations
        thread_results << Employee.where(country: "United States").count
        thread_results << Employee.where(department: "Engineering").average(:salary)
        thread_results << Employee.order(:salary).limit(5).pluck(:full_name)
        
        results << thread_results
      end
    end
    
    threads.each(&:join)
    end_time = Time.current
    
    concurrent_time = end_time - start_time
    assert concurrent_time < 3.0, "Concurrent reads took too long: #{concurrent_time}s"
    assert_equal 10, results.length
    
    # Verify all threads completed successfully
    results.each do |thread_result|
      assert_equal 3, thread_result.length
      assert_kind_of Integer, thread_result[0]  # count
      assert thread_result[1].nil? || thread_result[1].is_a?(Numeric)  # average
      assert_kind_of Array, thread_result[2]    # names
    end
  end

  test "memory usage during large operations" do
    # Monitor memory usage during bulk operations
    initial_memory = get_memory_usage
    
    create_test_employees(500)
    
    # Perform various operations
    Employee.where("full_name LIKE 'Perf Test%'").find_each(batch_size: 50) do |employee|
      employee.salary_category  # Trigger instance method
    end
    
    final_memory = get_memory_usage
    memory_increase = final_memory - initial_memory
    
    # Memory increase should be reasonable (less than 100MB for this test)
    assert memory_increase < 100_000_000, "Memory usage increased too much: #{memory_increase / 1_000_000}MB"
  end

  private

  def create_test_employees(count)
    employees_data = []
    
    count.times do |i|
      employees_data << {
        full_name: "Perf Test Employee #{i}",
        job_title: ["Developer", "Manager", "Analyst", "Designer", "Lead"][i % 5],
        country: ["United States", "India", "Germany", "Canada", "UK"][i % 5],
        salary: 30000 + (i * 100) + rand(20000),
        department: ["Engineering", "Product", "Marketing", "Sales", "HR"][i % 5],
        created_at: Time.current - rand(365).days,
        updated_at: Time.current
      }
    end
    
    Employee.insert_all(employees_data)
  end

  def get_memory_usage
    # Simple memory usage check (works on Unix-like systems)
    if File.exist?("/proc/#{Process.pid}/status")
      status = File.read("/proc/#{Process.pid}/status")
      match = status.match(/VmRSS:\s+(\d+)\s+kB/)
      return match ? match[1].to_i * 1024 : 0
    else
      # Fallback for non-Unix systems
      return 0
    end
  rescue
    0
  end
end
