class Kntn
  def initialize
    host = ENV['KINTONE_HOST']
    user = ENV['KINTONE_USER']
    pass = ENV['KINTONE_PASS']
    @app = ENV['KINTONE_APP'].to_i
    
    @api = Kintone::Api.new(host, user, pass)
  end

  def sync
    WalletTxn.all.each_with_index do |wt, i|
      record = {}
      WalletTxn.column_names.each do |column_name|
        next if ['created_at', 'updated_at'].include?(column_name)
        key = column_name.gsub(/_id$/, '_name')
        if column_name.match(/_id$/)
          val = wt.send(column_name.gsub(/_id$/, '')).name
        else
          val = wt.send(column_name)
          val = val * (-1) if column_name.match(/amount/) && wt.entry_side == 'expense'
        end
        record[key] = {value: val}
      end
      puts "#{i}: saving #{wt.description}"
      @api.record.register(@app, record)
    end
  end

  def remove
    query = 'limit 100' # 500以上にしたらエラーになる(削除が一度に100件しかできない）
    records = @api.records.get(@app, query, [])['records']
    is_retry = true if records.present? && records.count >= 100
    ids = records.map{|r| r['$id']['value'].to_i}
    puts 'start to delete'
    @api.records.delete(@app, ids)
    puts 'end to delete'
    remove if is_retry
  end
end

