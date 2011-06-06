class ConferencesController < ApplicationController

  def index
    h = {
      :conferences => Conference.all.map{|c| c.hash_for_json}
    }
    respond_to do |format|
      format.json  { render :json => h }
    end
  end

end
