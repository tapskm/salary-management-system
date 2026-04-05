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
    # Basic statistics
    @total_employees = Employee.count
    @total_budget = Employee.sum(:salary)
    @average_company_salary = Employee.average(:salary)
    
    # Country statistics
    @country_stats = Employee.group(:country).select(
      :country,
      "MIN(salary) as min_salary",
      "MAX(salary) as max_salary",
      "AVG(salary) as avg_salary",
      "COUNT(*) as total_count"
    ).order(:country)

    # Paginated job title statistics by role and country
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    @job_title_stats = Employee.group(:country, :job_title)
      .select(:country, :job_title, "AVG(salary) as avg_salary", "COUNT(*) as employee_count")
      .order(:country, :job_title)
      .page(page).per(per_page)

    # Department statistics
    @dept_stats = Employee.group(:department).select(
      :department,
      "AVG(salary) as avg_salary",
      "MIN(salary) as min_salary", 
      "MAX(salary) as max_salary",
      "SUM(salary) as total_budget",
      "COUNT(*) as staff_count"
    ).order("avg_salary DESC")

    # Salary distribution (ranges)
    @salary_distribution = {
      "0-50k" => Employee.where("salary <= 50000").count,
      "50k-100k" => Employee.where("salary > 50000 AND salary <= 100000").count,
      "100k-150k" => Employee.where("salary > 100000 AND salary <= 150000").count,
      "150k-200k" => Employee.where("salary > 150000 AND salary <= 200000").count,
      "200k+" => Employee.where("salary > 200000").count
    }

    # Top paying job titles
    @top_paying_jobs = Employee.group(:job_title)
      .select(:job_title, "AVG(salary) as avg_salary", "COUNT(*) as count")
      .order("avg_salary DESC")
      .limit(10)

    # Recent hiring trends (last 30 days vs previous 30 days)
    thirty_days_ago = 30.days.ago
    sixty_days_ago = 60.days.ago
    
    @recent_hires = Employee.where("created_at > ?", thirty_days_ago).count
    @previous_hires = Employee.where("created_at BETWEEN ? AND ?", sixty_days_ago, thirty_days_ago).count

    respond_to do |format|
      format.html
      format.json do
        render json: {
          # Company overview
          company_stats: {
            total_employees: @total_employees,
            total_budget: @total_budget,
            average_salary: @average_company_salary,
            recent_hires: @recent_hires,
            previous_hires: @previous_hires,
            hiring_trend: @recent_hires > @previous_hires ? 'up' : (@recent_hires < @previous_hires ? 'down' : 'stable')
          },
          
          # Country statistics  
          country_stats: @country_stats.map do |stat|
            {
              country: stat.country,
              min_salary: stat.min_salary,
              max_salary: stat.max_salary,
              avg_salary: stat.avg_salary,
              total_count: stat.total_count
            }
          end,
          
          # Job title statistics with pagination
          job_title_stats: {
            data: @job_title_stats.map do |stat|
              {
                country: stat.country,
                job_title: stat.job_title,
                avg_salary: stat.avg_salary,
                employee_count: stat.employee_count
              }
            end,
            pagination: {
              current_page: @job_title_stats.current_page,
              total_pages: @job_title_stats.total_pages,
              total_count: @job_title_stats.total_count,
              per_page: @job_title_stats.limit_value
            }
          },
          
          # Department statistics
          department_stats: @dept_stats.map do |stat|
            {
              department: stat.department,
              avg_salary: stat.avg_salary,
              min_salary: stat.min_salary,
              max_salary: stat.max_salary,
              total_budget: stat.total_budget,
              staff_count: stat.staff_count
            }
          end,
          
          # Salary distribution
          salary_distribution: @salary_distribution,
          
          # Top paying jobs
          top_paying_jobs: @top_paying_jobs.map do |job|
            {
              job_title: job.job_title,
              avg_salary: job.avg_salary,
              count: job.count
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