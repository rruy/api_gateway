class AddStatusCodeToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :status_code, :integer
  end
end
