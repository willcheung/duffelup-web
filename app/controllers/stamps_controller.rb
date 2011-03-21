class StampsController < ApplicationController
  before_filter :protect
  
  # GET /stamps
  # GET /stamps.xml
  def index
    @stamps = Stamp.find(:all)
    if current_user
      achievement_map = Hash.new(false)
      Achievement.find_all_by_user_id(current_user.id).each { |a| achievement_map[a.stamp_id] = true }
      @stamps.each { |s| s.awarded_to_current_user = achievement_map[s.id] }
    end

    respond_to do |format|
      format.xml { render :text => @stamps.to_xml(:methods => [:awarded_to_current_user]) }
    end
  end

end
