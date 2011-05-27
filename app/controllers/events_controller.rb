class EventsController < ApplicationController

  def index
    respond_to do |format|
      format.json  { render :json => Event.all_for_json }
    end
  end
  
  def import
    Event.import_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
  end
  
end
