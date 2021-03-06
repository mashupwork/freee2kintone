class Freee
  include KntnSync

  def self.setting
    {
      site: 'https://api.freee.co.jp/',
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token',
      #model_names: ['WalletTxn', 'Walletable', 'Deal', 'Bank']
      model_names: ['Walletable', 'WalletTxn']
      #model_names: ['Walletable']
    }
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

  def sync model_name
    case model_name
    when 'WalletTxn'
      kntn_loop('wallet_txns', {offset: 0})
    when 'Walletable'
      kntn_loop('walletables', {is_all: true})
    end
  end

  def wallet_txns(params={})
    offset = params[:offset] || 0
    url = "/api/1/wallet_txns.json?company_id=#{company_id}&offset=#{offset}"
    res = fetch(url)
    res['wallet_txns'].map do |i|
      i2 = i
      i.keys.each do |column_name|
        val = i[column_name]
        val = val * (-1) if column_name.match(/amount/) && i['entry_side'] == 'expense'
        i2[column_name] = val
      end
      i2
    end
  end

  def walletables prams = {}
    fetch("/api/1/walletables.json?company_id=#{company_id}")['walletables']
  end

  def company_id
    url = '/api/1/users/me?companies=true'
    fetch(url)['user']['companies'].first['id'].to_i
  end    
end

