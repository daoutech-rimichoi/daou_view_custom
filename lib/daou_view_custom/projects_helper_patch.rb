# frozen_string_literal: true

module DaouViewCustom
  module ProjectsHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :project_settings_tabs_without_daou, :project_settings_tabs
        alias_method :project_settings_tabs, :project_settings_tabs_with_daou
      end
    end

    module InstanceMethods
      def project_settings_tabs_with_daou
        tabs = project_settings_tabs_without_daou
        
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
end