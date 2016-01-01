class Kntn
  def initialize(app_id=nil)
    host = ENV['KINTONE_HOST']
    user = ENV['KINTONE_USER']
    pass = ENV['KINTONE_PASS']
    @app_id = app_id
    @api = Kintone::Api.new(host, user, pass)
  end

  def self.app_create!(name, fields=nil)
    k = self.new
    k.api.app.register(name, fields)
  end

  def self.remove(app_id)
    Kntn.new(app_id).remove
  end

  def api
    @api
  end

  def app(app_id)
    @app_id = app_id
    self
  end

  def deploy
    @api.app.deploy(app_id)
  end

  def all
    res = @api.records.get(@app_id, '', [])
    res['records'].presence
  end

  def where cond
    query = ''
    cond.each do |k, v|
      query += "#{k} = \"#{v.to_s}\""
    end
    @api.records.get(@app_id, query, [])
  end

  def save pre_params, unique_key=nil
    if unique_key
      cond = {}
      cond[unique_key] = pre_params[unique_key]
      records = where(cond)['records']
      if records.present?
        id = records.first['$id']['value'].to_i
        return update(id, pre_params)
      end
    end
    create(pre_params)
  end

  def create pre_params
    params = {}
    pre_params.each do |k, v|
      params[k] = {value: v}
    end
    begin
      res = @api.record.register(@app_id, params)
    rescue
      sleep 5
      save pre_params
    end
    res
  end

  def save! record, unique_key=nil
    res = save(record, unique_key)
    res['message'] ? raise(res.inspect) : res
  end

  def update id, record
    params = {}
    record.each do |k, v|
      params[k] = {value: v}
    end
    @api.record.update(@app_id, id.to_i, params)
  end

  def calculate params
    logic = params[:logic]
    column_name = params[:column_name]
    puts "logic is #{logic}"
    all.each do |record|
      case logic
      when 'absolute'
        from_column_name='amount'
        to_column_name='amount_absolute'
        params[to_column_name] = record[from_column_name]['value'].to_i.abs
      when 'blank_is_forever'
        next if record[column_name]['value'].present?
        params[column_name] = '3000-01-01'
      end
      id = record['$id']['value']
      update(id, params)
    end
  end

  def remove app_id=nil
    app_id ||= @app_id
    # 500以上にしたらエラーになる
    # 削除が一度に100件しかできない）
    query = 'limit 100' 
    records = @api.records.get(app_id, query, [])['records']
    is_retry = true if records.present? && records.count >= 100
    return 'no records' if records.blank?
    ids = records.map{|r| r['$id']['value'].to_i}
    puts 'start to delete'
    @api.records.delete(app_id, ids)
    puts 'end to delete'
    remove if is_retry
  end
end

