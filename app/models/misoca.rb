class Misoca
  include KntnSync
  def initialize
    @client = OAuth2::Client.new(
      ENV['MISOCA_KEY'],
      ENV['MISOCA_SECRET'],
      site: 'https://app.misoca.jp/api/v1/',
      authorize_url: 'https://app.misoca.jp/oauth2/authorize',
      token_url: 'https://app.misoca.jp/oauth2/token'
    )
    #id = ENV['MISOCA_KINTONE_APP']
    id = 20
    @kntn = Kntn.new(id)
  end

  def sync
    offset = 0
    items = invoices(offset)
    kintones(items)
    while(items.present?) do
      offset += 1
      items = invoices(offset)
      kintones(items)
    end
  end
  
  def kintones items
    puts 'kintones'
    items.each do |item|
      invoice = invoice(item['id'])
      param = {
        id: item['id'],
        recipient_name: item['recipient_name'],
        issue_date: item['issue_date'],
        final_total_price: invoice['final_total_price']
      }
      kintone(param)
    end
  end

  def kintone item
    puts "kintone #{item[:id]}: #{item[:recipient_name]}"
    record = {}
    item.keys.each do |column_name|
      key = column_name.to_s
      val = item[column_name]
      record[key] = {value: val}
    end

    @kntn.save(record)
  end

  def invoice(id)
    url = "/api/v1/invoice/#{id}"
    access_token.get(url).parsed
  end

  def invoices(offset=0)
    puts "offset is #{offset}"
    url = "/api/v1/invoices/?limit=80&offset=#{offset}"
    access_token.get(url).parsed
  end

  def client
    @client
  end

  def access_token
    token = Misoca.get 'token'
    OAuth2::AccessToken.new(@client, token)
  end

  private
    def self.get key
      File.open("tmp/misoca_#{key}.txt", 'r').read
    end

    def self.set key, val
      File.open("tmp/misoca_#{key}.txt", 'w') { |file| file.write(val) }
    end
end
