class CreateFreepbxMonitors < ActiveRecord::Migration
  def change
    create_table :freepbx_monitors do |t|
      t.string :uniqueid
      t.string :path

      t.timestamps
    end
  end
end
