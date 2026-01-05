module DaouCustom
  module QueriesHelperPatch
    # 일감 목록에 상태 컬럼의 내용을 상태 배지로 감싸서 출력
    def column_content(column, item)
      content = super
      
      if column.name == :status
        # item이 status를 가지고 있는지 안전하게 확인 (Issue 외의 모델일 수도 있으므로)
        if item.respond_to?(:status)
          return content_tag(:span, content, class: "status-badge", "data-status" => item.status.to_s)
        end
      end
      
      content
    end
  end
end
