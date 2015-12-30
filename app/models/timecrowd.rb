class Timecrowd
  include KntnSync

  def self.setting
    {
      site: 'https://timecrowd.net',
      authorize_url: nil,
      token_url: nil
    }
  end

  def sync
    sync_entries
    sync_tasks
  end

  def sync_entries(page=1)
    kntn_loop('entries', {page: page})
  end

  def sync_tasks(page=1)
    teams.each do |team|
      kntn_loop('tasks', {team_id: team['id'], page: page, kntn_app: 2})
    end
  end

  def me
    fetch "/api/v1/user"
  end

  def teams
    me['teams']
  end

  def tasks params = {}
    team_id = params[:team_id]
    page    = params[:page] || 1
    fetch "/api/v1/teams/#{team_id}/tasks?page=#{page}"
  end

  def entries params = {}
    page = params[:page] || 1
    fetch "/api/v1/time_entries?page=#{page}"
  end

  def field_names
    items = entries
    return nil unless items.present?
    item = items.first
    item2field_names(item)
  end
end

