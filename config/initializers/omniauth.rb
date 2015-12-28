Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
  provider :misoca, ENV['MISOCA_KEY'], ENV['MISOCA_SECRET']
end
OmniAuth.config.logger = Rails.logger
