module KntnSync
  extend ActiveSupport::Concern
  included do
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
  end
end
