module DaouCustom
  module ProjectsHelperPatch
    def project_settings_tabs
      tabs = super
      
      tabs << {
        name: 'project_required_fields',
        action: :edit_project,
        partial: 'projects/settings/project_required_fields',
        label: :label_project_required_fields
      }
      
      tabs
    end
  end
end
