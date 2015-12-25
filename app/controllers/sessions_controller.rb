class SessionsController < ApplicationController
  def login
    callback_url = request.url.gsub(/login/, 'callback')
    url = "https://secure.freee.co.jp/oauth/authorize?client_id=#{ENV['FREEE_CLIENT_ID']}&redirect_uri=#{callback_url.gsub(':', '%3A').gsub('/', '%2F')}&response_type=code"
    redirect_to url
  end

  def callback
    Freee.freee(params[:code])
    redirect_to '/'
  end
end
