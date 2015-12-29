class Misoca
  include KntnSync

  def self.setting
    {
      site: 'https://app.misoca.jp/api/v1/',
      authorize_url: 'https://app.misoca.jp/oauth2/authorize',
      token_url: 'https://app.misoca.jp/oauth2/token'
    }
  end

  def sync
    kntn_loop('invoices')
  end

  def invoice(id)
    fetch "/api/v1/invoice/#{id}"
  end

  def invoices(offset=0)
    fetch "/api/v1/invoices/?limit=80&offset=#{offset}"
  end
end
