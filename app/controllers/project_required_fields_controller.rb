class ProjectRequiredFieldsController < ApplicationController
  before_action :find_project_by_project_id

  def update
    unless User.current.allowed_to?(:edit_project, @project)
      return deny_access
    end

    current_fields = @project.project_required_fields.pluck(:field_name)
    new_fields = params[:required_fields] || []
    
    to_add = new_fields - current_fields
    to_remove = current_fields - new_fields
    
    ProjectRequiredField.transaction do
      if to_remove.any?
        @project.project_required_fields.where(field_name: to_remove).destroy_all
      end
      
      to_add.each do |field_name|
        @project.project_required_fields.create(field_name: field_name)
      end
    end
    
    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path(@project, tab: 'project_required_fields')
  end
end
