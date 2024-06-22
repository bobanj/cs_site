# frozen_string_literal: true

Rails.application.config.after_initialize do
  ActiveRecord.yaml_column_permitted_classes += [
    ActiveSupport::TimeWithZone,
    Time,
    ActiveSupport::TimeZone
  ]
end
