Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
  provider :ruffnote, ENV['RUFFNOTE_KEY'], ENV['RUFFNOTE_SECRET']
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'repo'
  #provider :misoca, ENV['MISOCA_KEY'], ENV['MISOCA_SECRET'], scope: 'write'
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope:'email,user_birthday,user_likes,user_friends,user_actions.news,user_events,user_posts,user_relationships,user_relationship_details,user_tagged_places,read_page_mailboxes,ads_read,ads_management,pages_show_list,publish_actions'
end
OmniAuth.config.logger = Rails.logger
