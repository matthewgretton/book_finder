class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.decimal :atos_book_level, precision: 2, scale: 1
      t.decimal :ar_points, precision: 3, scale: 1
      t.string :interest_level
      t.integer :word_count

      t.timestamps
    end
  end
end
