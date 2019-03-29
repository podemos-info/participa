class AddPriorityToPage < ActiveRecord::Migration
  def change
    add_column :pages, :priority, :integer, default: 0, null:false
  end
end
