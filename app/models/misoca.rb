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
      next if [647032].include?(item['id'])
      invoice = invoice(item['id'])
      param = {
        id: item['id'],
        recipient_name: item['recipient_name'],
        issue_date: item['issue_date'],
        final_total_price: invoice['final_total_price'],
        invoice_status: invoice['invoice_status']
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
    fetch "/api/v1/invoice/#{id}"
  end

  def invoices(offset=0)
    fetch "/api/v1/invoices/?limit=80&offset=#{offset}"
  end
end
