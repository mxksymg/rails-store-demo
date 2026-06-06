# plik migracji (np. db/migrate/xxxxxx_add_published_to_products.rb)
class AddPublishedToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :published, :boolean, default: false
  end
end
class SetDefaultAdminToFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :admin, false
  end
end
