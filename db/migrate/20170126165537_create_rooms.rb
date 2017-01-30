class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :class_id
      t.string :mon
      t.string :tue
      t.string :wed
      t.string :thr
      t.string :fri

      t.timestamps
    end
  end
end
