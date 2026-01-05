# frozen_string_literal: true

module DaouCustom
  class ViewHook < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag('custom', :plugin => 'daou_custom')
    end

    def view_issues_form_details_bottom(context = {})
      javascript_include_tag('custom_issue', :plugin => 'daou_custom')
    end

    render_on :view_issues_show_details_bottom, partial: 'issues/custom_attributes'
  end
end