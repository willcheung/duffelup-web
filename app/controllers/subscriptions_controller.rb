class SubscriptionsController < ApplicationController
  before_filter :protect
  
  def create
    @user = current_user
    redirect = params[:redirect] ? params[:redirect] : dashboard_path
    
    if params[:subscription] # if submitted from subscription form
      escaped_location =  params[:subscription][:city].gsub ('%', '\%').gsub ('_', '\_')
      city = City.find (:first, :conditions=> ["city_country like ?", escaped_location + "%"], :order => ["rank"])
      #city = City.find_by_city_country(params[:subscription][:city])
      
      if @user.cities.exists?(city) or city.nil?
        city = nil
      else
        @user.cities << city
      end
    else # if submitted from link
      city = City.find_by_id(params[:city])
      @user.cities << city
    end

    respond_to do |format|
      if city.nil?
        flash[:error] = "We can't find the city, or you're already following it."
        format.html { redirect_to(redirect) }
      else
        flash[:notice] = "You're now following travel deals for #{city.city_country}."
        format.html { redirect_to(redirect) }
      end
    end
  end
  
  def destroy
    @user = current_user
    city = @user.cities.find(params[:city])
    @user.cities.delete(city)
    redirect = params[:redirect] ? params[:redirect] : dashboard_path

    respond_to do |format|
      flash[:notice] = "Don't like #{city.city}? Find another city to follow."
      format.html { redirect_to(redirect) }
    end
  end
  
end
