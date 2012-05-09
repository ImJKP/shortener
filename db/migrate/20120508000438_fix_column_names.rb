class FixColumnNames < ActiveRecord::Migration
  def up
  	rename_column :links, :out_url, :original_url
  	rename_column :links, :in_url, :short_path
  end

  def down
  end
end
