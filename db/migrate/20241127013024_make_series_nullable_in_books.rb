class MakeSeriesNullableInBooks < ActiveRecord::Migration[8.0]
  def change
    change_column_null :books, :series, true
  end
end
