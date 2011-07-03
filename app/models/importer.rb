# -*- coding: utf-8 -*-
require 'open-uri'

class Importer



private

  # yamlファイルの読み込み
  # 前回処理したデータと同じならnilを返す
  def self.load_yaml_file_with_key path, key
    return nil unless File.exist? path
    open(path) do |f|
      last_data = DataFile.find_or_create_by_key(key)
      context = f.read
      # 前回と同じなら更新しない
      if last_data.context == context
        return nil
      end
      last_data.context = context
      last_data.save
    end
    YAML.load_file path
  end


end
