class Ruffnote
  include KntnSync

  def self.setting
    {
      site: 'https://ruffnote.com',
      authorize_url: nil,
      token_url: nil
    }
  end

  def sync
    sync_notes
  end

  def sync_notes
    kntn_loop('notes')
  end

  def notes params={}
    fetch "/api/v1/notes"
  end
end

