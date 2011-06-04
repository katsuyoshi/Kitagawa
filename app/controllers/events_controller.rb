class EventsController < ApplicationController

  def index
    respond_to do |format|
      format.json  { render :json => Event.all_for_json }
    end
  end
  
  def import
    Event.import_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
    render :text => "last updated : #{DataFile.last_updated_by_key('timetables')}"
  end
  
  def last_updated
    respond_to do |format|
      format.json { render :json => { :last_updated => DataFile.last_updated_by_key('timetables') } }
    end
  end
  
end
