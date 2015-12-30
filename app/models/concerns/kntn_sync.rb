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
        @kntn = Kntn.new(id)
      end
    end

    def access_token
      token = self.class.get 'token'
      OAuth2::AccessToken.new(@client, token)
    end

    def kntn_loop(method_name, params={})
      @kntn = Kntn.new(self.class.get('kintone_app')) unless @kntn
      items = self.send(method_name, params)
      while items.present?
        items.each_with_index do |item, i|
          record = item2record(item)
          name = item['name'] || item['title'] || item['description'] || item['id'] || '名称不明'
          puts "#{i}: saving #{name}"
          if app = params[:kntn_app]
            raise "FIXME!: #{app}".inspect
          else
            @kntn.save(record)
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

    def item2field_names item
      res = {}
      item.keys.each do |key|
        val = item[key]
        if val.class == Hash
          val.each do |k, v|
            key2 = "#{key}_#{k}"
            res[key2] = {
              code: key2,
              label: key2,
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

    def self.sync(refresh=false)
      unless @kntn 
        instance = self.new
        id = Kntn.create!("#{self.to_s}連携", instance.field_names)[:app]
        self.set 'kintone_app', id
      end
      i = self.new
      i.remove if refresh
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
