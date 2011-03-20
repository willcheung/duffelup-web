class StampsController < ApplicationController
  before_filter :protect
  
  # GET /stamps
  # GET /stamps.xml
  def index
    @stamps = Stamp.find(:all)

    respond_to do |format|
      format.xml  { render :xml => @stamps }
    end
  end

end
