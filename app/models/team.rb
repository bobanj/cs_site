# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :players, dependent: :destroy

  def logo_name
    "#{name.downcase.tr(' ', '_')}_logo"
  end
end
