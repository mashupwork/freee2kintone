class Timecrowd
  include KntnSync
  attr_accessor :client, :access_token

  def initialize
    id = ENV['TIMECROWD_KINTONE_APP'].to_i
    @kntn = Kntn.new(id)

    self.client = OAuth2::Client.new(
      ENV['TIMECROWD_KEY'],
      ENV['TIMECROWD_SECRET'],
      site: 'https://timecrowd.net',
      ssl: { verify: false }
    )
    self.access_token = OAuth2::AccessToken.new(
      client,
      File.open("tmp/timecrowd_token.txt", 'r').read,
      refresh_token: File.open("tmp/timecrowd_refresh_token.txt", 'r').read,
      expires_at: File.open("tmp/timecrowd_expires_at.txt", 'r').read
    )

    #self.access_token = access_token.refresh! if self.access_token.expired?
    self.access_token = access_token.refresh!

    %w(expires_at refresh_token token).each do |key|
      val = self.access_token.send(key)
      File.open("tmp/timecrowd_#{key}.txt", 'w') { |file| file.write(val) }
    end
    @tc = access_token
  end

  def sync(page=1)
    entries = time_entries(page)
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

  def time_entries page = nil
    url = '/api/v1/time_entries'
    url += "?page=#{page}" unless page.nil?
    puts url
    access_token.get(url).parsed
  end



end

