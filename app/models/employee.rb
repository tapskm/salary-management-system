class Employee < ApplicationRecord
  # Validations
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :job_title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :country, presence: true, length: { minimum: 2, maximum: 50 }
  validates :salary, presence: true, numericality: { greater_than: 0, less_than: 10_000_000 }
  validates :department, presence: true, length: { minimum: 2, maximum: 50 }

  # Scopes for common queries
  scope :by_country, ->(country) { where(country: country) }
  scope :by_department, ->(department) { where(department: department) }
  scope :by_salary_range, ->(min, max) { where(salary: min..max) }
  scope :high_earners, -> { where('salary > ?', 100_000) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods for analytics
  def self.average_salary_by_country
    group(:country).average(:salary)
  end

  def self.average_salary_by_department
    group(:department).average(:salary)
  end

  def self.salary_distribution
    {
      "0-50k" => where("salary <= 50000").count,
      "50k-100k" => where("salary > 50000 AND salary <= 100000").count,
      "100k-150k" => where("salary > 100000 AND salary <= 150000").count,
      "150k-200k" => where("salary > 150000 AND salary <= 200000").count,
      "200k+" => where("salary > 200000").count
    }
  end

  # Instance methods
  def salary_category
    case salary
    when 0..50_000
      "Entry Level"
    when 50_001..100_000
      "Mid Level"
    when 100_001..150_000
      "Senior Level"
    when 150_001..200_000
      "Executive Level"
    else
      "C-Level"
    end
  end

  def formatted_salary
    "$#{salary.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
