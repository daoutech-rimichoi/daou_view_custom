class CreateProjectRequiredFields < ActiveRecord::Migration[7.2]
  def change
    create_table :project_required_fields do |t|
      t.references :project, type: :integer, foreign_key: true
      t.string :field_name, null: false
    end

    add_index :project_required_fields, [:project_id, :field_name], unique: true
  end
end
