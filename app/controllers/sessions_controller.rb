class SessionsController < ApplicationController
  def login
    callback_url = "#{request.url}/callback"
    url = "https://secure.freee.co.jp/oauth/authorize?client_id=#{ENV['FREEE_KEY']}&redirect_uri=#{callback_url.gsub(':', '%3A').gsub('/', '%2F')}&response_type=code"
    redirect_to url
  end

  def callback
    url = request.url
    url = url.split('?code=').first
    f = Freee.new
    f.api(params[:code], url)
    redirect_to '/', notice: 'ログイン完了'
  end
end
