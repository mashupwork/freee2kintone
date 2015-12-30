class Github
  include KntnSync

  def self.setting
    {
      site: 'https://api.github.com',
      authorize_url: nil,
      token_url: nil
    }
  end

  def sync
    sync_issues
  end

  def sync_issues(page=1)
    kntn_loop('issues', {page: page})
  end

  def issues params
    page = params[:page] || 1
    fetch "/issues?page=#{page}&state=all"
  end
end
