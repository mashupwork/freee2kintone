module KntnSync
  extend ActiveSupport::Concern
  included do
    def initialize
      setting = self.class.setting
      upcase = self.to_s.upcase
      @client = OAuth2::Client.new(
        ENV["#{upcase}_KEY"],
        ENV["#{upcase}_SECRET"],
        site: setting[:site],
        authorize_url: setting[:authorize_url],
        token_url: setting[:token_url]
      )
      id = ENV["#{self.to_s.upcase}_KINTONE_APP"]
      @kntn = Kntn.new(id)
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

    def self.get key
      File.open("tmp/#{self.to_s.downcase}_#{key}.txt", 'r').read
    end

    def self.set key, val
      File.open("tmp/#{self.to_s.downcase}_#{key}.txt", 'w') { |file| file.write(val) }
    end
  end
end
