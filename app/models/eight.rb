class Eight
  include KntnSync
  
  def self.from
    Kntn.new(ENV['KINTONE_EIGHT'])
  end

  def self.to
    Kntn.new(ENV['KINTONE_PEOPLE'])
  end

  def self.sync (refresh =1)
    from = self.from
    to = self.to
    to.remove if refresh
    eight_ids = {}
    if to.all.present?
      to.all.each do |record|
        val = record['eight_id']['value']
        next if val.blank?
        eight_ids[val] = true
      end
    end
    from.all.each do |record|
      next unless record['e_mail']['value']
      #next if eight_ids[record['id']['value']] # CSVにはidなかった
      next if eight_ids[record['e_mail']['value']]
      next if record['Name']['value'].blank?
      next if record['Address']['value'].blank?
      params = {
        Company: record['Company']['value'],
        Address: record['Address']['value'],
        Name: record['Name']['value'],
        Division: record['Division']['value'],
        #eight_id: record['id']['value']
        eight_id: record['e_mail']['value']
      }
      to.save!(params)
    end
  end
end

