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
        next if ['date', 'created_at', 'updated_at'].include?(column_name)
        record[column_name] = {value: wt.send(column_name)}
      end
      puts "#{i}: saving #{wt.description}"
      #raise record.inspect
      @api.record.register(@app, record)
    end
  end

  def remove
    query = 'limit 100' # 500以上にしたらエラーになる(削除が一度に100件しかできないので100にしてある）
    records = @api.records.get(@app, query, [])['records']
    raise @api.records.get(@app, query, []).inspect
    is_retry = true if records.present? && records.count < 99
    ids = records.map{|r| r['$id']['value'].to_i}
    puts 'start to delete'
    @api.records.delete(@app, ids)
    puts 'end to delete'
    remove if is_retry
  end
end

