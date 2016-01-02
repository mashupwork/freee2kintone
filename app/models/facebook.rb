class Facebook
  include KntnSync

  def self.setting
    {
      site: 'https://graph.facebook.com/v2.5/',
      model_names: ['Group', 'Feed', 'Event', 'Like']
    }
  end

  def me
    fetch "/me"
  end

  def mine key
    fetch("/#{me['id']}/#{key}")
  end
 
  def likes params = {}
    mine 'likes'
  end

  def events params = {}
    mine 'events'
  end

  def friends params = {}
    mine 'friends'
  end

  def feeds params = {}
    mine 'feed'
  end

  def groups params = {}
    mine 'groups'
  end
end

