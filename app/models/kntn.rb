class Kntn
  def self.create!(name, fields=nil)
    k = Kntn.new
    k.create!(name, fields)
  end

  def self.remove(app_id)
    Kntn.new(app_id).remove
  end

  def initialize(app_id=nil)
    host = ENV['KINTONE_HOST']
    user = ENV['KINTONE_USER']
    pass = ENV['KINTONE_PASS']
    @app_id = app_id
    @api = Kintone::Api.new(host, user, pass)
  end

  def api
    @api
  end

  def create!(name, fields=nil)
    @api.app.register(name, fields)
  end

  def deploy
    @api.app.deploy(@app_id)
  end

  def save record
    begin
      @api.record.register(@app_id, record)
    rescue
      sleep 5
      save record
    end
  end

  def save! record
    res = save(record)
    res['message'] ? raise(res.inspect) : res
  end

  def remove
    # 500以上にしたらエラーになる
    # 削除が一度に100件しかできない）
    query = 'limit 100' 

    records = @api.records.get(@app_id, query, [])['records']
    is_retry = true if records.present? && records.count >= 100
    return 'no records' if records.blank?
    ids = records.map{|r| r['$id']['value'].to_i}
    puts 'start to delete'
    @api.records.delete(@app_id, ids)
    puts 'end to delete'
    remove if is_retry
  end
end

