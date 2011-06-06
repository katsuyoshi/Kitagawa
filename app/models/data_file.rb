class DataFile < ActiveRecord::Base

  def self.updated
    data_file = DataFile.find(:all, :limit => 1, :order => 'updated_at desc').first
    data_file ? data_file.updated_at : nil
  end
  
end
