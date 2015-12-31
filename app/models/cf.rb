class Cf
  def initialize
    @kntn = Kntn.new
    @app_freee = 78
    @freee_walletable_id = 4409
    @app_future = 91
    @app_all   = 89
    @fields = ["balance"]
  end

  def sync (refresh=false)
    remove if refresh
    last_balance = sync_pasts
    sync_futures(last_balance)
  end

  def remove
    @kntn.remove(@app_all)
  end

  def sync_futures(last_balance=nil)
    2008.upto(2016).each do |y|
      1.upto(12).each do |m|
        next if Date.new(y, m, 1) < Date.today
        last_balance = save_future(year, month, last_balance)
      end
    end
  end

  def sync_pasts
    balance = 0
    2008.upto(2016).each do |y|
      1.upto(12).each do |m|
        next if Date.new(y, m, 1) >= Date.today
        balance = save_past(y, m)
      end
    end
    balance
  end

  def futures
    @kntn.app(@app_future).all
  end

  def save_future year, month, last_balance=nil
    save 'future', year, month, last_balance
  end

  def save_past year, month, last_balance=nil
    save 'past', year, month, last_balance
  end

  def save type='future', year, month, last_balance
    puts "#{year}-#{month}: #{last_balance}"
    day = Date.new(year, month, 1)
    breakdown = ''
    if last_balance
      balance = last_balance
    else
      balance = last_month_balance || 0
    end

    if future?
      futures.each do |f|
        from = f['year_month_start']['value'].to_date
        to   = f['year_month_end']['value']
        to   = to.to_date if to
        balance += f['amount']['value'].to_i if from <= day && (to.nil? || to > day)
        breakdown += "#{f['memo']['memo']}: #{f['amount']['value']}\n"
      end
    else # past
      next_day = (day + 1.month).beginning_of_month
      query = "date < \"#{next_day}\" and walletable_id = #{@freee_walletable_id} order by date desc limit 1"
      record = @kntn.api.records.get(@app_freee, query, @fields)
      return if record['records'].blank?
      balance = record['records'].first['balance']['value']
    end

    year_month =  day.to_s
    helper =  ActionController::Base.helpers
    record = {
      record_title: {value: "#{year_month.to_s.gsub(/_01$/, '')}: #{helper.number_with_delimiter(balance)}"},
      year_month: {value: year_month},
      balance: {value: balance},
      breakdown: {value: breakdown}
    }
    @kntn.api.record.register(@app_all, record)
    balance
  end

  def future?(year, month)
    day = Date.new(year, month, 1)
    Date.today < day
  end
end
