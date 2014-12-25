class AddScopeToElection < ActiveRecord::Migration
  def up
    add_column :elections, :scope, :int

    # Hasta este momento todas las elecciones habían sido Estatales
    Election.update_all(scope: 0) 
  end

  def down
    remove_column :elections, :scope, :int
  end
end
