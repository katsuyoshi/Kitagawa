class DataFile < ActiveRecord::Base

  def self.last_updated_by_key key
    data_file = DataFile.find_by_key 'timetables'
    data_file ? data_file.updated_at : nil
  end
  
end
