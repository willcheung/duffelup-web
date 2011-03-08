class LandmarksController < ApplicationController
  layout "simple_without_js"
  
  before_filter :protect_admin_page
  before_filter :find_city
  
  def find_city
    @city = City.find(params[:city_id])
  end
  
  # GET /landmarks
  # GET /landmarks.xml
  def index
    @landmarks = @city.landmarks.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @landmarks }
      format.json  { render :json => @landmarks }
    end
  end

  # GET /landmarks/1
  # GET /landmarks/1.xml
  def show
    @landmark = @city.landmarks.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @landmark }
    end
  end

  # GET /landmarks/new
  # GET /landmarks/new.xml
  def new
    @landmark = @city.landmarks.new
    @landmark.build_stamp

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @landmark }
    end
  end

  # GET /landmarks/1/edit
  def edit
    @landmark = @city.landmarks.find(params[:id])
  end

  # POST /landmarks
  # POST /landmarks.xml
  def create
    @landmark = @city.landmarks.new(params[:landmark])
    @landmark.build_stamp(params[:stamp])
    respond_to do |format|
      if @landmark.valid? && @landmark.stamp.valid? && @landmark.save && @landmark.stamp.save
        flash[:notice] = 'Landmark was successfully created.'
        format.html { redirect_to([@city, @landmark]) }
        format.xml  { render :xml => @landmark, :status => :created, :location => @landmark }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @landmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /landmarks/1
  # PUT /landmarks/1.xml
  def update
    @landmark = @city.landmarks.find(params[:id])
    @landmark.attributes=(params[:landmark])
    @landmark.stamp.attributes=(params[:stamp])
    respond_to do |format|
      if @landmark.valid? && @landmark.stamp.valid? && @landmark.save && @landmark.stamp.save
        flash[:notice] = 'Landmark was successfully updated.'
        format.html { redirect_to([@city, @landmark]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @landmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /landmarks/1
  # DELETE /landmarks/1.xml
  def destroy
    @landmark = @city.landmarks.find(params[:id])
    @landmark.destroy

    respond_to do |format|
      format.html { redirect_to(city_landmarks_url(@city)) }
      format.xml  { head :ok }
    end
  end
end
