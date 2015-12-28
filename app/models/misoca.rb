class Misoca
  def initialize(token=nil)
    @client = OAuth2::Client.new(
      ENV['MISOCA_KEY'],
      ENV['MISOCA_SECRET'],
      site: 'https://app.misoca.jp/api/v1/',
      authorize_url: 'https://app.misoca.jp/oauth2/authorize',
      token_url: 'https://app.misoca.jp/oauth2/token'
    )
    @token = token
  end

  def client
    @client
  end

  def access_token
    OAuth2::AccessToken.new(@client, @token)
  end
end
