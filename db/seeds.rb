indian_first = File.readlines('indian_first_names.txt').map(&:strip)
indian_last = File.readlines('indian_last_names.txt').map(&:strip)
western_first = File.readlines('western_first_names.txt').map(&:strip)
western_last = File.readlines('western_last_names.txt').map(&:strip)

DEPT_MAPPING = {
  "Engineering" => ["Software Engineer", "DevOps Engineer", "Data Scientist"],
  "People"      => ["HR Manager", "Recruiter"],
  "Finance"     => ["Accountant", "Financial Analyst"],
  "Product"     => ["Product Manager", "UX Designer"],
  "Sales"       => ["Sales Executive", "Sales Manager"]
}

COUNTRIES = ["India", "USA", "UK", "Germany", "Canada"]

employees = []

10_000.times do
  country = COUNTRIES.sample
  dept = DEPT_MAPPING.keys.sample
  title = DEPT_MAPPING[dept].sample

  if (country == "India" && rand < 0.9) || (country != "India" && rand < 0.15)
    full_name = "#{indian_first.sample} #{indian_last.sample}"
  else
    full_name = "#{western_first.sample} #{western_last.sample}"
  end

  # Realistic Salary Ranges per Country
  salary = case country
           when "India" then rand(800000..4000000)
           when "USA" then rand(90000..190000)
           else rand(50000..130000)
           end

  employees << {
    full_name: full_name,
    job_title: title,
    country: country,
    salary: salary,
    department: dept,
    created_at: Time.current,
    updated_at: Time.current
  }
end

Employee.insert_all(employees)
