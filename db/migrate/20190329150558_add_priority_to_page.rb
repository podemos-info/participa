class AddPriorityToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :priority, :integer, default: 0, null:false
  end
end
