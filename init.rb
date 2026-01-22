# frozen_string_literal: true

Redmine::Plugin.register :daou_view_custom do
  name 'Daoutech View Custom Plugin'
  author 'rimichoi'
  description 'Custom view hooks and patches for Daoutech Redmine'
  version '0.0.3'
  requires_redmine :version_or_higher => '6.0.0'
  url 'https://github.com/daoutech-rimichoi/daou_view_custom'
  author_url 'mailto:rimichoi@daou.co.kr'
end

apply_patches = -> do
  load File.expand_path('../lib/daou_view_custom/application_helper_patch.rb', __FILE__)
  load File.expand_path('../lib/daou_view_custom/issue_patch.rb', __FILE__)
  load File.expand_path('../lib/daou_view_custom/queries_helper_patch.rb', __FILE__)
  load File.expand_path('../lib/daou_view_custom/project_patch.rb', __FILE__)
  load File.expand_path('../lib/daou_view_custom/projects_helper_patch.rb', __FILE__)
  load File.expand_path('../lib/daou_view_custom/issue_fields_rows_patch.rb', __FILE__)

  # ApplicationHelper 패치
  unless ApplicationHelper.ancestors.include?(DaouViewCustom::ApplicationHelperPatch)
    ApplicationHelper.prepend(DaouViewCustom::ApplicationHelperPatch)
  end

  # Issue 모델 패치
  unless Issue.ancestors.include?(DaouViewCustom::IssuePatch)
    Issue.prepend(DaouViewCustom::IssuePatch)
  end

  # QueriesHelper 패치
  unless QueriesHelper.ancestors.include?(DaouViewCustom::QueriesHelperPatch)
    QueriesHelper.prepend(DaouViewCustom::QueriesHelperPatch)
  end

  # Project 모델 패치
  unless Project.ancestors.include?(DaouViewCustom::ProjectPatch)
    Project.prepend(DaouViewCustom::ProjectPatch)
  end

  # ProjectsHelper 패치
  unless ProjectsHelper.ancestors.include?(DaouViewCustom::ProjectsHelperPatch)
    ProjectsHelper.send(:include, DaouViewCustom::ProjectsHelperPatch)
  end

  # IssuesHelper::IssueFieldsRows 패치
  if defined?(IssuesHelper::IssueFieldsRows)
    unless IssuesHelper::IssueFieldsRows.ancestors.include?(DaouViewCustom::IssueFieldsRowsPatch)
      IssuesHelper::IssueFieldsRows.prepend(DaouViewCustom::IssueFieldsRowsPatch)
    end
  end
end

# 1. 즉시 실행 (부팅 시 적용)
apply_patches.call

# 2. 리로드 시 실행 (개발 모드 대응)
Rails.configuration.to_prepare do
  apply_patches.call
end
