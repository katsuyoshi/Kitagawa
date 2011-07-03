class ImportController < ApplicationController

  def rubykaigi2011
    Conference.transaction do
      Rubykaigi2011Importer.import
    end
    render :text => "updated : #{DataFile.updated}"
  end
  
  def jrubykaigi2011
    Conference.transaction do
      Jrubykaigi2011Importer.import
    end
    render :text => "updated : #{DataFile.updated}"
  end
  
end
