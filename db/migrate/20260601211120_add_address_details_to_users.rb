class AddAddressDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :street, :string
    add_column :users, :city, :string
    add_column :users, :postal_code, :string
  end
end
