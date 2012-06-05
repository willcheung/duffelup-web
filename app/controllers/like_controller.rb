class LikeController < ApplicationController
  before_filter :protect, :only => :new
  
  def new
    redirect_back_or_default('/', params[:redirect])
  end
  
  def create
    e = Event.find_by_id(params[:event])
    like = Like.new(:user => current_user, :event => e, :acted_on => Time.now)
    like.save!
    
    Postoffice.deliver_like_notification(:event_creator => e.user,
                                            :liker => current_user,
                                            :event_title => e.title,
                                            :liker_url => "http://duffelup.com/#{current_user.username}",
                                            :event_url => trip_idea_url(:permalink => e.trip.permalink, :id => e.id))
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('#like_#{e.id}').attr('class','like disabled')"
          page.replace_html "like_#{e.id}", link_to_remote("Unlike", { :url => "/like/111/?event=#{e.id}", :method => :delete })
        end
      end
    end
  end
  
  def destroy
    e = Event.find_by_id(params[:event])
    like = Like.find_by_user_id_and_event_id(current_user, e)
    like.destroy
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('#like_#{e.id}').attr('class','like')"
          page.replace_html "like_#{e.id}", link_to_remote("<span style=\"padding:0 0 2px 31px;background:url(/images/icon-favorite.png) no-repeat 10px -7px;z-index:3\">Like this</span", { :url => "/like/?event=#{e.id}", :method => :post }, :style => "padding-left:0")
        end
      end
    end
  end

end
