# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :team

  def logo_name
    "#{nickname.downcase.tr(' ', '_')}_logo"
  end

  def logo_url
    hltv_photo_url
  end
end
