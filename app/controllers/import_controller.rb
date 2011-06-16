class ImportController < ApplicationController

  def rubykaigi2011
    Importer.import_rubykaigi2011_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
    Importer.import_lightning_talks_of_rubykaigi2011
    render :text => "updated : #{DataFile.updated}"
  end
  
  def jrubykaigi2011
  end
  
end
