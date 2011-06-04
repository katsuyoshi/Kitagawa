class EventsController < ApplicationController

  def index
    respond_to do |format|
      format.json  { render :json => Event.all_for_json }
    end
  end
  
  def import
    Event.import_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
    event = Event.order("updated_at desc").first
    render :text => "last updated : #{event.updated_at}"
  end
  
  def last_updated
    data_file = DataFile.find_by_key 'timetables'
    respond_to do |format|
      format.json { render :json => { :last_updated => data_file.updated_at } }
    end
  end
  
end
