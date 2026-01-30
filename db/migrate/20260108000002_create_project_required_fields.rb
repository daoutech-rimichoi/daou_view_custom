# frozen_string_literal: true

class CreateProjectRequiredFields < ActiveRecord::Migration[6.1]
  def change
    create_table :project_required_fields, if_not_exists: true do |t|
      t.references :project, type: :integer, foreign_key: true
      t.string :field_name, null: false
    end

    unless index_exists?(:project_required_fields, [:project_id, :field_name])
      add_index :project_required_fields, [:project_id, :field_name], unique: true
    end
  end
end
