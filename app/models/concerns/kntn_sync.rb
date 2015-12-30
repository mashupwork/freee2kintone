module KntnSync
  extend ActiveSupport::Concern
  included do
    def initialize
      setting = self.class.setting
      upcase = self.to_s.upcase
      downcase = self.to_s.downcase
      @client = OAuth2::Client.new(
        ENV["#{upcase}_KEY"],
        ENV["#{upcase}_SECRET"],
        site: setting[:site],
        authorize_url: setting[:authorize_url],
        token_url: setting[:token_url],
        ssl: { verify: false }
      )
      if self.class.exist? downcase
        id = self.class.get downcase
      else
        id = Kntn.create!("#{self.class.to_s}連携", self.field_names)[:app]
        self.class.set downcase, 'id'
      end
      @kntn = Kntn.new(id)
    end

    def access_token
      token = self.class.get 'token'
      OAuth2::AccessToken.new(@client, token)
    end

    def kntn_loop(method_name, params={})
      items = self.send(method_name, params)
      while items.present?
        items.each_with_index do |item, i|
          record = item2record(item)
          name = item['name'] || item['title'] || item['description'] || item['id'] || '名称不明'
          puts "#{i}: saving #{name}"
          if app = params[:kntn_app]
            id = ENV["#{self.class.to_s.upcase}_KINTONE_APP#{app}"].to_i
            k = Kntn.new(id)
            k.save(record)
          else
            @kntn.save!(record)
          end
        end
        if params[:page]
          params[:page] += 1
          items = self.send(method_name, params)
        else
          return
        end
      end
    end

    def item2record item
      record = {}
      item.keys.each do |key|
        val = item[key]
        if key.match(/_at$/) && item[key].to_i > 0
          val = Time.at(val.to_i)
          record[key] = {value: val}
        elsif key.match(/^is_/)
          val = val == true ? 1 : 0
          record[key] = {value: val}
        elsif val.class == Hash
          val.keys.each do |k|
            record["#{key}_#{k}"] = {value: val[k]}
            record["#{k}"] = {value: val[k]}
          end
        else
          record[key] = {value: val}
        end
      end
      record
    end

    def self.sync(refresh=false)
      id = ENV["#{self.to_s.upcase}_KINTONE_APP"].to_i
      Kntn.new(id).remove if refresh
      i = self.new
      i.sync
    end

    def self.remove
      id = ENV["#{self.to_s.upcase}_KINTONE_APP"].to_i
      id = 20
      Kntn.new(id).remove
    end

    def client
      @client
    end

    def fetch url
      begin
        puts "url is #{url}"
        access_token.get(url).parsed
      rescue=>e
        raise e.inspect
        sleep 5
        fetch url
      end
    end

    def self.exist? key
      File.exist?("tmp/#{self.to_s.downcase}_#{key}.txt")
    end

    def self.get key
      File.open("tmp/#{self.to_s.downcase}_#{key}.txt", 'r').read
    end

    def self.set key, val
      File.open("tmp/#{self.to_s.downcase}_#{key}.txt", 'w') { |file| file.write(val) }
    end
  end
end
