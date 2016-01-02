class Facebook
  include KntnSync

  def self.setting
    {
      site: 'https://graph.facebook.com/',
      model_names: ['Like']
    }
  end

  def sync model_name
    case model_name
    when 'Like'
      kntn_loop('likes')
    end
  end

  def me
    fetch "/v2.5/me"
  end
  
  def likes params = {}
    fetch("/v2.5/#{me['id']}/likes")
  end
end

