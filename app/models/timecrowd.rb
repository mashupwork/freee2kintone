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
    sync_tasks
    sync_entries
  end

  def sync_entries(page=1)
    entries = @tc.time_entries(page)
    while entries.present?
      entries.each_with_index do |time_entry, i|
        id = time_entry['id']
        task_id = time_entry['task']['id']
        timecrowd_url = "https://timecrowd.net/tasks/#{task_id}/time_entries/#{id}/edit"
        record = {
          time_entry_id:      {value: id},
          time_entry_comment: {value: time_entry['comment']},
          stopped_at:         {value: Time.at(time_entry['stopped_at'].to_i)},
          started_at:         {value: Time.at(time_entry['started_at'].to_i)},
          user_nickname:      {value: time_entry['user']['nickname']},
          user_id:            {value: time_entry['user']['id']},
          task_name:          {value: time_entry['task']['title']},
          duration:           {value: time_entry['duration']},
          task_url:           {value: time_entry['task']['url']},
          task_id:            {value: task_id},
          team_id:            {value: time_entry['task']['team_id']},
          timecrowd_url:      {value: timecrowd_url}
        }
        puts "#{i}: saving #{time_entry['task']['title']}"
        @kntn.save(record)
      end
      page += 1
      entries = time_entries(page)
    end
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

  def tasks params
    team_id = params[:team_id]
    page    = params[:page] || 1
    begin
      fetch "/api/v1/teams/#{team_id}/tasks?page=#{page}"
    rescue
      sleep 5
      tasks(team_id, page)
    end
  end

  def entries page = 1
    fetch "/api/v1/time_entries?page=#{page}"
  end
end

