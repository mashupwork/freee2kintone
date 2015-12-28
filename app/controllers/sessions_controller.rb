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

    raise provider.inspect

    case provider
    when 'freee'
      url = request.url
      url = url.split('?code=').first
      f = Freee.new
      f.api(params[:code], url)
    when 'timecrowd'
  
    end
    redirect_to :root, notice: "ログイン完了(from #{provider})"
  end

  def failure
    raise request.env.inspect
  end
end
