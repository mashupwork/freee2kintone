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

  def field_names
    items = invoices 
    return nil unless items.present?
    item = items.first
    res = {}
    item.keys.each do |key|
      val = item[key]
      if val == Hash
        val.each do |k, v|
          key2 = "#{key}_#{k}"
          res[key2] = {
            code: key,
            label: key,
            type: item2type(k, v)
          }
        end
      else
        res[key] = {
          code: key, 
          label: key, 
          type: item2type(key, val)
        }
        res[key][:unique] = true if key == 'id'
      end
    end
    res 
  end

  def item2type key, val
    if key.match(/_at$/)
      'DATETIME'
    elsif key.match(/_on$/)
      'DATE'
    elsif val.class == Fixnum
      'NUMBER'
    else
      'SINGLE_LINE_TEXT'
    end
  end
end
