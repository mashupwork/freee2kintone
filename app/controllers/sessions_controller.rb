class SessionsController < ApplicationController
  def freee
    redirect_uri = "#{request.url}/callback"
    url = "https://secure.freee.co.jp/oauth/authorize?client_id=#{ENV['FREEE_KEY']}&redirect_uri=#{redirect_uri.gsub(':', '%3A').gsub('/', '%2F')}&response_type=code"
    redirect_to url
  end

  def misoca
    redirect_uri = "#{request.url}/callback"
    m = Misoca.new
    authorize_url = m.client.auth_code.authorize_url(
      redirect_uri: redirect_uri,
      scope: 'write'
    )
    redirect_to authorize_url
  end

  def timecrowd_callback
    redirect_to :root
  end

  def callback
    provider = params[:provider]
    if ['freee', 'misoca'].include?(provider)
      url = request.url
      url = url.split('?code=').first
      m = provider.capitalize.constantize.new
      token = m.api(
        params[:code],
        url
      ).token
      m.class.set('token', token)
    else
      save_token(provider, request.env['omniauth.auth'])
    end
    redirect_to :root, notice: "ログイン完了(from #{provider})"
  end

  def failure
    raise request.env.inspect
  end

  private
    def save_token provider, auth_hash
      %w(expires_at refresh_token token).each do |key|
        val = auth_hash.credentials.send(key)
        File.open("tmp/#{provider}_#{key}.txt", 'w') { |file| file.write(val) }
      end
    end
end
