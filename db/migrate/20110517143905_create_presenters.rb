class CreatePresenters < ActiveRecord::Migration
  def self.up
    create_table :presenters do |t|
      t.string :code
      t.string :name
      t.text :bio
      t.string :locale
      t.string :affiliation

      t.timestamps
    end
  end

  def self.down
    drop_table :presenters
  end
end
