# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :players, dependent: :destroy

  def self.get_duplicates(*columns)
    order('created_at ASC').select("#{columns.join(',')}, COUNT(*)").group(columns).having('COUNT(*) > 1')
  end

  def logo_name
    "#{name.downcase.tr(' ', '_')}_logo"
  end

  def hltv_update; end
end
