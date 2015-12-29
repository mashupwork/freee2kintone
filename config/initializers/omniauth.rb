Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
  provider :ruffnote, ENV['RUFFNOTE_KEY'], ENV['RUFFNOTE_SECRET']
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'repo'
  #provider :misoca, ENV['MISOCA_KEY'], ENV['MISOCA_SECRET'], scope: 'write'
end
OmniAuth.config.logger = Rails.logger
