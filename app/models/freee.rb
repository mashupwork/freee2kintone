class Freee
  def self.sync
    %w(account_item partner bank walletable wallet_txn transfer deal).each do |name|
      name.camelcase.constantize.sync
    end
  end

  def self.company_id
    self.freee.get(
      '/api/1/users/me?companies=true'
    ).parsed['user']['companies'].first['id'].to_i
  end

  def self.check(model, params=[])
    plural = model.to_s.split('::').last.underscore.pluralize
    url = "/api/1/#{plural}.json?limit=100"
    params.each do |key, val|
      url += "&#{key}=#{val}"
    end
    puts "url is #{url}"
    self.freee.get(
      url
    ).parsed[plural]
  end

  def self.fetch(model, param=[])
    self.check(model, param).each do |item|
      model.import(item)
    end
  end

  def self.freee(code=nil)
    client = OAuth2::Client.new(
      ENV['FREEE_CLIENT_ID'],
      ENV['FREEE_SECRET_KEY'],
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
          ENV['FREEE_CLIENT_ID'],
          ENV['FREEE_SECRET_KEY'],
        )
      }
    }
    if code
      params.merge!({
        grant_type: 'authorization_code',
        #redirect_uri: YOUR_REDIRECT_URI,
        #redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        redirect_uri: ENV['FREEE_CALLBACK_URL'],
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
