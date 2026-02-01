class AddUniqueIndexToRestaurantsNameCity < ActiveRecord::Migration[8.1]
  def change
    add_index :restaurants, [:name, :city], unique: true
  end
end