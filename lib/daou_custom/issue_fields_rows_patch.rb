module DaouCustom
  module IssueFieldsRowsPatch
    def cells(label, text, options={})
      # 'status' 클래스가 포함된 경우 (상태 필드)
      if options[:class].to_s.split.include?('status')
        # 바깥쪽 div(options)에 data-status 속성 추가
        # text는 상태 이름(예: "진행")이므로 이를 문자열로 변환하여 사용
        options['data-status'] = text.to_s
      end
      
      super(label, text, options)
    end
  end
end
