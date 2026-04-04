class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :full_name
      t.string :job_title
      t.string :country
      t.float :salary
      t.string :department

      t.timestamps
    end
    add_index :employees, :country
    add_index :employees, [:country, :job_title]
  end
end
