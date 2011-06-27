class ImportController < ApplicationController

  def rubykaigi2011
    Rubykaigi2011Importer.import
    render :text => "updated : #{DataFile.updated}"
  end
  
  def jrubykaigi2011
    Conference.transaction do
      Importer.import_jrubykaigi2011
    end
    render :text => "updated : #{DataFile.updated}"
  end
  
end
