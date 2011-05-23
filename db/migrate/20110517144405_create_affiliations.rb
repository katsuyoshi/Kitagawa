class CreateAffiliations < ActiveRecord::Migration
  def self.up
    create_table :affiliations do |t|
      t.string :title
      t.string :locale

      t.timestamps
    end
  end

  def self.down
    drop_table :affiliations
  end
end
