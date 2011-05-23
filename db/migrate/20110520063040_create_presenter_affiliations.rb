class CreatePresenterAffiliations < ActiveRecord::Migration
  def self.up
    create_table :presenter_affiliations do |t|
      t.integer :presenter_id
      t.integer :affiliation_id
      t.integer :affiliation_position

      t.timestamps
    end
  end

  def self.down
    drop_table :presenter_affiliations
  end
end
