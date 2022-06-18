class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.string :ip
      t.string :origin
      t.string :url
      t.string :params
      t.string :payload
      t.timestamps
    end
  end
end
