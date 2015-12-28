class SessionsController < ApplicationController
  def freee
    callback_url = "#{request.url}/callback"
    url = "https://secure.freee.co.jp/oauth/authorize?client_id=#{ENV['FREEE_KEY']}&redirect_uri=#{callback_url.gsub(':', '%3A').gsub('/', '%2F')}&response_type=code"
    redirect_to url
  end

  def timecrowd_callback
    redirect_to :root
  end

  def callback
    provider = params[:provider]
    case provider
    when 'freee'
      url = request.url
      url = url.split('?code=').first
      f = Freee.new
      f.api(params[:code], url)
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
