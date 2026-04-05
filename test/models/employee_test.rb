require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  def setup
    @employee = Employee.new(
      full_name: "Test Employee",
      job_title: "Software Developer",
      country: "United States",
      salary: 75000.00,
      department: "Engineering"
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @employee.valid?
  end

  test "should not be valid without full_name" do
    @employee.full_name = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:full_name], "can't be blank"
  end

  test "should not be valid with too short full_name" do
    @employee.full_name = "A"
    assert_not @employee.valid?
    assert_includes @employee.errors[:full_name], "is too short (minimum is 2 characters)"
  end

  test "should not be valid with too long full_name" do
    @employee.full_name = "A" * 101
    assert_not @employee.valid?
    assert_includes @employee.errors[:full_name], "is too long (maximum is 100 characters)"
  end

  test "should not be valid without job_title" do
    @employee.job_title = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:job_title], "can't be blank"
  end

  test "should not be valid without country" do
    @employee.country = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:country], "can't be blank"
  end

  test "should not be valid without salary" do
    @employee.salary = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "can't be blank"
  end

  test "should not be valid with negative salary" do
    @employee.salary = -1000
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "must be greater than 0"
  end

  test "should not be valid with zero salary" do
    @employee.salary = 0
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "must be greater than 0"
  end

  test "should not be valid with extremely high salary" do
    @employee.salary = 20_000_000
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "must be less than 10000000"
  end

  test "should not be valid without department" do
    @employee.department = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:department], "can't be blank"
  end

  # Scope Tests
  test "by_country scope should return employees from specific country" do
    us_employees = Employee.by_country("United States")
    assert_includes us_employees, employees(:john_doe)
    assert_includes us_employees, employees(:jane_smith)
    assert_not_includes us_employees, employees(:raj_patel)
  end

  test "by_department scope should return employees from specific department" do
    engineering_employees = Employee.by_department("Engineering")
    assert_includes engineering_employees, employees(:john_doe)
    assert_includes engineering_employees, employees(:raj_patel)
    assert_not_includes engineering_employees, employees(:jane_smith)
  end

  test "by_salary_range scope should return employees within salary range" do
    mid_range_employees = Employee.by_salary_range(50000, 100000)
    assert_includes mid_range_employees, employees(:john_doe)
    assert_includes mid_range_employees, employees(:hans_mueller)
    assert_not_includes mid_range_employees, employees(:low_salary_employee)
    assert_not_includes mid_range_employees, employees(:high_salary_employee)
  end

  test "high_earners scope should return employees with salary > 100k" do
    high_earners = Employee.high_earners
    assert_includes high_earners, employees(:high_salary_employee)
    assert_not_includes high_earners, employees(:john_doe)
    assert_not_includes high_earners, employees(:low_salary_employee)
  end

  # Class Method Tests
  test "average_salary_by_country should return correct averages" do
    averages = Employee.average_salary_by_country
    assert_kind_of Hash, averages
    assert averages.key?("United States")
    assert averages.key?("India")
    
    # Should have higher average salary for US than India
    assert averages["United States"] > averages["India"]
  end

  test "average_salary_by_department should return correct averages" do
    averages = Employee.average_salary_by_department
    assert_kind_of Hash, averages
    assert averages.key?("Engineering")
    assert averages.key?("Product")
  end

  test "salary_distribution should return correct distribution" do
    distribution = Employee.salary_distribution
    
    assert_kind_of Hash, distribution
    assert_equal 5, distribution.keys.length
    assert distribution.key?("0-50k")
    assert distribution.key?("50k-100k")
    assert distribution.key?("100k-150k")
    assert distribution.key?("150k-200k")
    assert distribution.key?("200k+")
    
    # All values should be non-negative integers
    distribution.each do |range, count|
      assert_kind_of Integer, count
      assert count >= 0
    end
  end

  # Instance Method Tests
  test "salary_category should return correct category for different salaries" do
    # Entry Level
    employee_entry = employees(:low_salary_employee)
    assert_equal "Entry Level", employee_entry.salary_category

    # Mid Level  
    employee_mid = employees(:john_doe)
    assert_equal "Mid Level", employee_mid.salary_category

    # Senior Level
    employee_senior = employees(:jane_smith)
    assert_equal "Mid Level", employee_senior.salary_category

    # Executive Level (180k salary falls in Executive Level range)
    employee_exec = employees(:high_salary_employee)
    assert_equal "Executive Level", employee_exec.salary_category
  end

  test "formatted_salary should return properly formatted salary string" do
    employee = employees(:john_doe)
    assert_equal "$85,000", employee.formatted_salary
    
    high_salary_employee = employees(:high_salary_employee)
    assert_equal "$180,000", high_salary_employee.formatted_salary
    
    low_salary_employee = employees(:low_salary_employee)
    assert_equal "$25,000", low_salary_employee.formatted_salary
  end

  test "formatted_salary should handle edge cases" do
    @employee.salary = 1000
    assert_equal "$1,000", @employee.formatted_salary
    
    @employee.salary = 999
    assert_equal "$999", @employee.formatted_salary
    
    @employee.salary = 1_234_567
    assert_equal "$1,234,567", @employee.formatted_salary
  end

  # Database Integration Tests
  test "should be able to save valid employee" do
    assert_difference('Employee.count') do
      @employee.save
    end
  end

  test "should not save invalid employee" do
    @employee.full_name = nil
    assert_no_difference('Employee.count') do
      @employee.save
    end
  end

  test "should update existing employee" do
    employee = employees(:john_doe)
    original_salary = employee.salary
    
    employee.update(salary: 90000)
    employee.reload
    
    assert_not_equal original_salary, employee.salary
    assert_equal 90000, employee.salary
  end

  # Edge Case Tests
  test "should handle decimal salaries correctly" do
    @employee.salary = 75000.50
    assert @employee.valid?
    assert @employee.save
    
    @employee.reload
    assert_equal 75000.50, @employee.salary
  end

  test "should handle unicode characters in name" do
    @employee.full_name = "José María González"
    assert @employee.valid?
    assert @employee.save
  end

  test "should handle special characters in job title" do
    @employee.job_title = "Senior Software Engineer - Team Lead (Frontend)"
    assert @employee.valid?
    assert @employee.save
  end
end
