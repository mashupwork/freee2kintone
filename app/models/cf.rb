class Cf
  def initialize
    @kntn = Kntn.new
    @apps = {
      freee:  Freee.kintone_id,
      future: ENV['KINTONE_CF_FUTURE'],
      all:    ENV['KINTONE_CF_ALL']
    }
  end

  def sync (refresh=false)
    remove if refresh
    last_balance = sync_pasts
    sync_futures(last_balance)
  end

  def remove
    @kntn.remove(@app[:all])
  end

  def sync_futures(last_balance=nil)
    month = Month.new
    final_month = Month.new(2017, 3)
    while(month.future?(final_month))
      last_balance = save_future(month, last_balance)
      month = month.next
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
    @kntn.app(@apps[:future]).all
  end

  def save_future month, last_balance=nil
    save 'future', month, last_balance
  end

  def save_past month, last_balance=nil
    save 'past', month, last_balance
  end

  def save type='future', month, last_balance
    puts "#{month.year}-#{month.month}: #{last_balance}"
    day = month.date
    breakdown = ''
    if last_balance
      balance = last_balance
    else
      balance = month.last.balance || 0
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
      record = @kntn.api.records.get(@apps[:freee], query, [])
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
    @kntn.api.record.register(@apps[:all], record)
    balance
  end
end

