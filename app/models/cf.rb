class Cf
  def initialize
    @kntn = Kntn.new
    @apps = {
      freee:  Freee.kintone_id,
      future: ENV['KINTONE_CF_FUTURE'],
      all:    ENV['KINTONE_CF_ALL']
    }
    @freee_walletable_id = 4409 #TODO freee APIで walletable_type=bank_accountのものを自動取得する
  end

  def sync (refresh=false)
    remove if refresh
    previous_balance = sync_pasts
    sync_futures(previous_balance)
  end

  def remove
    Kntn.remove(@apps[:all])
  end

  def sync_futures(previous_balance=nil)
    previous_balance ||= Month.new.previous.balance
    month = Month.new
    final_month = Month.new(2017, 3)
    while(month.future?(final_month))
      previous_balance = save_future(
        month, previous_balance
      )
      month = month.next
    end
  end

  def sync_pasts
    month = Month.new(2008, 12)
    final_month = Month.new.previous # 今月は未来なので先月まで
    while(month.future?(final_month))
      balance = save_past(month)
      month = month.next
    end
    balance
  end

  def futures
    @kntn.app(@apps[:future]).all
  end

  def save_future month, previous_balance=nil
    save 'future', month, previous_balance
  end

  def save_past month
    save 'past', month, nil
  end

  def save type='future', month, previous_balance
    puts "#{month.year_month}: #{previous_balance}"
    day = month.date
    breakdown = ''
    income = expense = 0
    if Month.new.future?(month)
      if previous_balance
        balance = previous_balance
      else
        balance = month.previous.balance || 0
      end
      futures.each do |f|
        if active?(month, f)
          amount = f['amount']['value'].to_i
          balance += amount
          if amount > 0
            income += amount
          else
            expense += amount
          end
          breakdown += "#{f['memo']['value']}: #{amount}\n"
        end
      end
    else # past
      balance = balance_from_freee(month)
    end

    year_month =  day.to_s
    helper =  ActionController::Base.helpers
    record_title = "#{year_month.to_s.gsub(/_01$/, '')}: "
    record_title += helper.number_with_delimiter(balance)
    record = {
      record_title: record_title,
      year_month: year_month,
      balance:    balance,
      income:    income,
      expense:    expense,
      breakdown:  breakdown
    }
    puts record.inspect
    @kntn.app(@apps[:all]).save!(record, :year_month)
    balance
  end

  def balance_from_freee month
    query = "date < \"#{month.next.date.beginning_of_month.to_s}\" and walletable_id = #{@freee_walletable_id} order by date desc limit 1"
    record = @kntn.api.records.get(@apps[:freee], query, [])['records']
    record.present? ? record.first['balance']['value'].to_i : 0
  end

  def active? month, future
    day = month.date
    from = future['year_month_start']['value'].to_date
    to   = future['year_month_end']['value'].to_date
    loop_type = future['loop_type']['value']
    return false unless (from <= day && to >= day) # 期間外
    return false if loop_type.match(/来月以降/) && day == Month.new.date # 今月はfalse
    return false if loop_type.match(/再来月以降/) && day == Month.new.next.date # 来月もfalse
    return true if ['毎月', '単発'].include?(loop_type)
    return true if loop_type == '毎年' && day.month == from.month
    return true if loop_type == '半年毎' && [from.month, (from+6.month).month].include?(day.month)
    return false
  end
end

