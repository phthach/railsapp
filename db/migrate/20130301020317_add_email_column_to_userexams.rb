class AddEmailColumnToUserexams < ActiveRecord::Migration
  def change
    add_column :userexams, :email, :string
  end
end
