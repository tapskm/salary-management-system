class EmployeesController < ApplicationController

  def index
    @employees = Employee.order(created_at: :desc).page(params[:page]).per(50)
  end

  def insights
    @country_stats = Employee.group(:country).select(
      :country,
      "MIN(salary) as min_salary",
      "MAX(salary) as max_salary",
      "AVG(salary) as avg_salary",
      "COUNT(*) as total_count"
    ).order(:country)

    @job_title_stats = Employee.group(:country, :job_title).select(
      :country, 
      :job_title, 
      "AVG(salary) as avg_salary"
    ).order(:country, :job_title)

    @dept_stats = Employee.group(:department).select(
      :department,
      "SUM(salary) as total_budget",
      "COUNT(*) as staff_count"
    ).order("total_budget DESC")
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to employees_path, notice: "Employee was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      redirect_to employees_path, notice: "Employee was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_url, notice: "Employee was successfully removed."
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:full_name, :job_title, :country, :salary, :department)
  end
end