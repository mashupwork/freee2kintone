class Month
  def initialize(year=nil, month=nil)
    today = Date.today
    @year = year || today.year
    @month = month || today.month
    @date = Date.new(@year, @month, 1)
    @kntn = Kntn.new(ENV['KINTONE_CF_ALL'])
    @cf   = Cf.new
  end

  def previous
    prev = @date - 1.month
    self.class.new(prev.year, prev.month)
  end

  def next
    n = @date + 1.month
    self.class.new(n.year, n.month)
  end

  def date
    @date
  end

  def future? target=nil
    date = target ? target.date : Date.today
    date >= self.date # 当月は未来として扱う
  end

  def year
    @year
  end

  def month
    @month
  end

  def year_month
    "#{year}-#{month}"
  end

  def balance
    res = @kntn.where(year_month: @date)['records']
    if res.present?
      res.first['balance']['value'].to_i
    else
      @cf.balance_from_freee(self)
    end
  end
end

