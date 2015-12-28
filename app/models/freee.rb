class Freee
  include KntnSync
  def initialize
    @company_id = company_id
    @walletable_names = walletable_names
  end

  def sync
    id = ENV['FREEE_KINTONE_APP'].to_i
    @kntn = Kntn.new(id)
    @freee = Freee.new
    offset = 0
    items = @freee.wallet_txns
    while(items.count >= 100) do
      items.each do |item|
        kintone(item)
      end
      offset += 100 
      items = @freee.wallet_txns(offset)
    end
  end

  def walletable_name walletable_id
    @walletable_names[walletable_id]
  end

  def kintone item
    record = {}
    item.keys.each do |column_name|
      next if ['created_at', 'updated_at'].include?(column_name)
      key = column_name.gsub(/_id$/, '_name')
      if column_name.match(/_id$/)
        val = walletable_name(item[column_name])
      else
        val = item[column_name]
        val = val * (-1) if column_name.match(/amount/) && item['entry_side'] == 'expense'
      end
      record[key] = {value: val}
    end
    @kntn.save(record)
  end

  def walletable_names
    url = "/api/1/walletables.json?company_id=#{@company_id}"
    puts "url is #{url}"
    res = {}
    walletables = api.get(
      url
    ).parsed['walletables']
    walletables.each do |walletable|
      res[walletable['id']] = walletable['name']
    end
    res
  end

  def wallet_txns(offset=0)
    url = "/api/1/wallet_txns.json?limit=100&company_id=#{@company_id}"
    url += "&offset=#{offset}"
    puts "url is #{url}"
    api.get(
      url
    ).parsed['wallet_txns']
  end

  def company_id
   api.get(
    '/api/1/users/me?companies=true'
  ).parsed['user']['companies'].first['id'].to_i
  end

  def api(code=nil, callback_url=nil)
    client = OAuth2::Client.new(
      ENV['FREEE_KEY'],
      ENV['FREEE_SECRET'],
      {
        site: 'https://api.freee.co.jp/',
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }
    ) do |conn|
      conn.request :url_encoded
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
    params = {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => HTTPAuth::Basic.pack_authorization(
          ENV['FREEE_KEY'],
          ENV['FREEE_SECRET'],
        )
      }
    }
    if code
      params.merge!({
        grant_type: 'authorization_code',
        #redirect_uri: YOUR_REDIRECT_URI,
        #redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        redirect_uri: callback_url,
        code: code
      })
    else
      params.merge!({
        grant_type: 'refresh_token',
        refresh_token: Freee.get('refresh_token')
      })
    end

    token = client.get_token(params)

    new_token = token.refresh!

    Freee.set('token', new_token.token)
    Freee.set('refresh_token', new_token.refresh_token)

    OAuth2::AccessToken.new(client, new_token.token)
  end

  private
    def self.get key
      File.open("tmp/freee_#{key}.txt", 'r').read
    end

    def self.set key, val
      File.open("tmp/freee_#{key}.txt", 'w') { |file| file.write(val) }
    end
end
