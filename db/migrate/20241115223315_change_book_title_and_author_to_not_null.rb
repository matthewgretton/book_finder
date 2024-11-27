class ChangeBookTitleAndAuthorToNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :books, :title, false
    change_column_null :books, :author, false
  end
end
