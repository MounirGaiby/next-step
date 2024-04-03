# frozen_string_literal: true

class Navigations::NavbarComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end

end
