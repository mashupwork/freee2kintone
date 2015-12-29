Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'repo'
  #provider :misoca, ENV['MISOCA_KEY'], ENV['MISOCA_SECRET'], scope: 'write'
  provider :trello, ENV['TRELLO_KEY'], ENV['TRELLO_SECRET'],
    scope: 'read,write,account', expiration: 'never'
end
OmniAuth.config.logger = Rails.logger
