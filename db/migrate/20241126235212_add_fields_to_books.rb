class AddFieldsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :series, :string, null: false
    add_column :books, :published, :integer, null: false
    add_column :books, :isbn, :string, null: false

    add_index :books, :isbn, unique: true
  end
end
