class CreateWalletables < ActiveRecord::Migration
  def change
    create_table :walletables do |t|
      t.string :name
      t.string :type
      t.references :bank, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
