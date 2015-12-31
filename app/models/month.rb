class Month
  def initialize(year=nil, month=nil)
    today = Date.today
    @year = year || today.year
    @month = month || today.month
    @date = Date.new(@year, @month, 1)
    @kntn = Kntn.new(ENV['KINTONE_CF_ALL'])
  end

  def previous
    previous_date = @date - 1.month
    self.class.new(previous_date)
  end

  def next
    next_date = @date + 1.month
    self.class.new(next_date)
  end

  def date
    @date
  end

  def future? instance=nil
    instance.date > self.date if instance
    Date.today > self.date
  end

  def balance
    query = "date = \"#{@date_to_s}\""
    res = @kntn.api.records.get(89, query, [])
    return nil unless res['records']
    res['records'].first['balance']['value'].to_i
  end
end

