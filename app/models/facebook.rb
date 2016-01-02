class Facebook
  include KntnSync

  def self.setting
    {
      site: 'https://graph.facebook.com/v2.5/',
      model_names: ['Event', 'Like']
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
end

