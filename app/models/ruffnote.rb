class Ruffnote
  include KntnSync

  def self.setting
    {site: 'https://ruffnote.com'}
  end

  def sync
    kntn_loop('notes')
  end

  def notes params={}
    fetch "/api/v1/notes"
  end
end

