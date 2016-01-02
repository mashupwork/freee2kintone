module KintoneSync
  module Base
    def initialize
      setting = self.class.setting
      upcase = self.class.to_s.upcase
      @client = OAuth2::Client.new(
        ENV["#{upcase}_KEY"],
        ENV["#{upcase}_SECRET"],
        site: setting[:site],
        #authorize_url: setting[:authorize_url],
        #token_url: setting[:token_url],
        #ssl: { verify: false }
      )
    end

    def kntn
      @kntn
    end

    def access_token
      token = self.class.get 'token'
      OAuth2::AccessToken.new(@client, token)
    end

    def kntn_loop(model_name, params={})
      @kntn = Kntn.new(get("kintone_app_#{model_name.underscore.pluralize}")) unless @kntn

      if self.class == Facebook
        data = self.send(model_name, params)
        items = data['data']
        next_page = data['paging']['next']
      else
        items = self.send(model_name, params)
      end

      while items.present?
        items.each_with_index do |item, i|
          record = item2record(item)
          name = item['name'] || item['title'] || item['description'] || item['id'] || '名称不明'
          puts "#{i}: saving #{name}"
          app_id = get "kintone_app_#{model_name.downcase}"
          @kntn.app(app_id).save(record)
        end
        params[:page] += 1 if params[:page]
        params[:offset] += items.count if params[:offset]
        return if params[:is_all]
        if next_page
          data = fetch(next_page)
          items = data['data']
          next_page = data['paging'].present? ? data['paging']['next'] : nil
        elsif self.class == Twitter
          # do nothing
        else
          items = self.send(model_name, params)
        end
      end
    end

    def item2record item
      record = {}
      item.to_hash.each do |key, val|
        begin
          if val.class == Hash
            val.each do |k, v|
              record["#{key}_#{k}"] = typed_val(k, v)
            end
          else
            record[key] = typed_val(key, val)
          end
        rescue=>e
          puts "key is below"
          puts key.inspect
          puts val.inspect
          raise e.inspect
        end
      end
      record
    end

    def typed_val key, val
      if key.match(/_at$/)
        if val.to_i > 0 # timecrowd
          val = Time.at(val.to_i)
        else
          val = val.to_datetime
        end
      elsif key.match(/_time$/) # facebook
        val = val.to_datetime
      elsif key.match(/^is_/)
        val = val == true ? 1 : 0
      end
      val
    end

    def item2type key, val
      if key.match(/_at$/) || key.match(/_time$/)
        'DATETIME'
      elsif key.match(/_on$/) || key == 'date'
        'DATE'
      elsif !key.match(/id$/) && (val.class == Fixnum || key == 'duration') # idを数値にするとtweet_idなどが桁数オーバーするので文字列にする
        'NUMBER'
      else
        'SINGLE_LINE_TEXT'
      end
    end

    def item2field_names item
      res = {}
      item.to_hash.each do |key, val|
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
          res[key][:unique] = true if key == :id
        end
      end
      res 
    end

    def sync(refresh=false)
      self.setting[:model_names].each do |model_name|
        unless self.exist?("kintone_app_#{model_name.underscore.pluralize}")
          id = Kntn.app_create!(
            "#{self.class.to_s.split('::').last}::#{model_name}", 
            field_names(model_name)
          )[:app]
          self.set "kintone_app_#{model_name.underscore.pluralize}", id
        end
        self.remove(model_name) if refresh
        self.sync_a_model(model_name)
      end
    end

    def sync_a_model model_name
      if self.class.instance_methods.include?(:sync_a_model)
        kntn_loop(model_name.underscore.pluralize)
      else
        super
      end
    end

    def remove
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

    def field_names model_name
      key = model_name.underscore.pluralize
      items = eval(key)
      items = items['data'] if self.class == Facebook
      return nil unless items.present?
      item = items.first
      item2field_names(item)
    end

    def exist? key
      File.exist?("tmp/#{self.class.to_s.split('::').last.downcase}_#{key}.txt")
    end

    def get key
      File.open("tmp/#{self.class.to_s.split('::').last.downcase}_#{key}.txt", 'r').read
    end

    def set key, val
      File.open("tmp/#{self.class.to_s.split('::').last.downcase}_#{key}.txt", 'w') { |file| file.write(val) }
    end
  end
end
