class AddTimeTotalToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :time_total, :string
  end
end
