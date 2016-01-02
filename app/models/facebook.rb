class Facebook
  include KntnSync

  def self.setting
    {
      site: 'https://graph.facebook.com/v2.5/',
      model_names: ['Feed', 'Event', 'Like']
    }
  end

  def me
    fetch "/me"
  end
 
  def likes params = {}
    fetch("/#{me['id']}/likes")
  end

  def events params = {}
    fetch("/#{me['id']}/events")
  end

  def feeds params = {}
    fetch("/#{me['id']}/feed")
  end
end

