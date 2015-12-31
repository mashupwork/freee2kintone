class Month
  def initialize(year=nil, month=nil)
    today = Date.today
    @year = year || today.year
    @month = month || today.month
  end

  def last_month
    if @month == 1
      new_year = @year - 1
      new_month = 12
    else
      new_year = @year
      new_month = @month - 1
    end
    self.class.new(new_year, new_month)
  end

  def balance

  end
end
