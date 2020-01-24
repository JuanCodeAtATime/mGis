class AddUuidInProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :uuid, :string
    add_index :projects, :uuid, unique: true
  end
end
