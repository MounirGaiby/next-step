class HomesController < ApplicationController
  def index
    @holidays = HolidayService.new.get_holidays
  end
end
