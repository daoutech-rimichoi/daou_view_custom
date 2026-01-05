require File.expand_path('../lib/daou_custom/application_helper_patch', __FILE__)
require File.expand_path('../lib/daou_custom/issue_patch', __FILE__)
require File.expand_path('../lib/daou_custom/queries_helper_patch', __FILE__)
require File.expand_path('../lib/daou_custom/issue_fields_rows_patch', __FILE__)
require File.expand_path('../lib/daou_custom/view_hook', __FILE__)

# IssuesHelper 로드 보장
require 'issues_helper'

Rails.application.config.after_initialize do
  unless ApplicationHelper.ancestors.include?(DaouCustom::ApplicationHelperPatch)
    ApplicationHelper.prepend(DaouCustom::ApplicationHelperPatch)
  end

  unless Issue.ancestors.include?(DaouCustom::IssuePatch)
    Issue.prepend(DaouCustom::IssuePatch)
  end

  unless QueriesHelper.ancestors.include?(DaouCustom::QueriesHelperPatch)
    QueriesHelper.prepend(DaouCustom::QueriesHelperPatch)
  end

  # IssuesHelper 내의 내부 클래스인 IssueFieldsRows에 패치 적용
  # 재시작 시와 개발 모드 리로딩 시 모두 대응
  patch_issue_fields = -> {
    if defined?(IssuesHelper::IssueFieldsRows) && !IssuesHelper::IssueFieldsRows.ancestors.include?(DaouCustom::IssueFieldsRowsPatch)
      IssuesHelper::IssueFieldsRows.prepend(DaouCustom::IssueFieldsRowsPatch)
    end
  }

  patch_issue_fields.call
  ActiveSupport::Reloader.to_prepare(&patch_issue_fields)
end

Redmine::Plugin.register :daou_custom do
  name 'Daoutech Custom Plugin'
  author 'Daoutech'
  description 'Custom hooks for Daou Redmine'
  version '0.0.1'
  url 'https://www.daou.co.kr/'
  author_url 'https://www.daou.co.kr/'
end
