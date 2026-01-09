module DaouCustom
  module ProjectPatch
    def self.prepended(base)
      base.class_eval do
        has_many :project_required_fields, class_name: 'ProjectRequiredField', dependent: :destroy
      end
    end
  end
end
