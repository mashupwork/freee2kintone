class WalletTxn < ActiveRecord::Base
  self.inheritance_column = "_type"
  include FreeeSync
  belongs_to :walletable
end
