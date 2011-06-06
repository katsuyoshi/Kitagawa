class ConferencesController < ApplicationController

  def index
    h = {
      :conferences => Conference.all.map{|c| c.hash_for_json}
    }
    respond_to do |format|
      format.json  { render :json => h }
    end
  end

  def import_rubykaigi2011
    Conference.import_rubykaigi2011_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
    render :text => "updated : #{DataFile.updated}"
  end

  def updated
    respond_to do |format|
      format.json { render :json => { :updated => DataFile.updated } }
    end
  end
  
end
