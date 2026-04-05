class EmployeesController < ApplicationController
  before_action :set_employee, only: [:edit, :update, :destroy]

  def index
    @employees = Employee.order(created_at: :desc).page(params[:page]).per(50)
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          employees: @employees.map do |emp|
            {
              id: emp.id,
              full_name: emp.full_name,
              job_title: emp.job_title,
              salary: emp.salary,
              country: emp.country,
              department: emp.department
            }
          end,
          meta: {
            current_page: @employees.current_page,
            total_pages: @employees.total_pages,
            total_count: @employees.total_count
          }
        }
      end
    end
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

    respond_to do |format|
      format.html
      format.json do
        render json: {
          country_stats: @country_stats.map do |stat|
            {
              country: stat.country,
              min_salary: stat.min_salary,
              max_salary: stat.max_salary,
              avg_salary: stat.avg_salary,
              total_count: stat.total_count
            }
          end,
          job_title_stats: @job_title_stats.map do |stat|
            {
              country: stat.country,
              job_title: stat.job_title,
              avg_salary: stat.avg_salary
            }
          end
        }
      end
    end
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    
    respond_to do |format|
      if @employee.save
        format.html { redirect_to employees_path, notice: "Employee was successfully created." }
        format.json { render json: @employee, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employees_path, notice: "Employee was successfully updated." }
        format.json { render json: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy
    
    respond_to do |format|
      format.html { redirect_to employees_url, notice: "Employee was successfully removed." }
      format.json { head :no_content }
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:full_name, :job_title, :country, :salary, :department)
  end
end