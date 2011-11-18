class LikeController < ApplicationController
  before_filter :protect, :only => :new
  
  def new
    redirect_back_or_default('/', params[:redirect])
  end
  
  def create
    e = Event.find_by_id(params[:event])
    like = Like.new(:user => current_user, :event => e, :acted_on => Time.now)
    like.save!
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('like_#{e.id}').className = 'like disabled'"
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
          page << "$('like_#{e.id}').className = 'like'"
          page.replace_html "like_#{e.id}", link_to_remote("Like this", { :url => "/like/?event=#{e.id}", :method => :post })
        end
      end
    end
  end

end
