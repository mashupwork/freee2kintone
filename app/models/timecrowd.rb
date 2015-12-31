class Timecrowd
  include KntnSync

  def self.setting
    {
      site: 'https://timecrowd.net',
      #model_names: ['Task', 'TimeEntry']
      model_names: ['TimeEntry']
    }
  end

  def sync model_name
    case model_name
    when 'TimeEntry'
      kntn_loop('time_entries', {page: 1})
    when 'Task'
      teams.each do |team|
        kntn_loop('tasks', {team_id: team['id'], page: 1})
      end
    end
  end

  def me
    fetch "/api/v1/user"
  end

  def teams
    me['teams']
  end

  def tasks params = {}
    team_id = params[:team_id] || teams.first['id']
    page    = params[:page] || 1
    fetch "/api/v1/teams/#{team_id}/tasks?page=#{page}"
  end

  def time_entries params = {}
    page = params[:page] || 1
    fetch "/api/v1/time_entries?page=#{page}"
  end
end

