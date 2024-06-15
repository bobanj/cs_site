# frozen_string_literal: true

class String
  def second_to_last
    split('/')[-2]
  end
end
