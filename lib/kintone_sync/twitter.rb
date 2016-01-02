module KintoneSync
  class Twitter
    include KintoneSync::Base

    def self.setting
      {
        site: 'https://api.twitter.com/',
        model_names: ['Tweet']
      }
    end

    def tweets params = {}
      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key    = ENV['TWITTER_KEY']
        config.consumer_secret = ENV['TWITTER_SECRET']
        config.access_token    = get('token')
        config.access_token_secret = get('secret')
      end
      @client.user_timeline("pandeiro245")
    end
  end
end
