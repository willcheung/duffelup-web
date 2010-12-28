class LandmarksController < ApplicationController
  layout "simple_without_js"
  
  before_filter :protect_admin_page
  before_filter :find_guide
  
  def find_guide
    @guide = Guide.find(params[:guide_id])
  end
  
  # GET /landmarks
  # GET /landmarks.xml
  def index
    @landmarks = @guide.landmarks.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @landmarks }
      format.json  { render :json => @landmarks }
    end
  end

  # GET /landmarks/1
  # GET /landmarks/1.xml
  def show
    @landmark = @guide.landmarks.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @landmark }
    end
  end

  # GET /landmarks/new
  # GET /landmarks/new.xml
  def new
    @landmark = @guide.landmarks.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @landmark }
    end
  end

  # GET /landmarks/1/edit
  def edit
    @landmark = @guide.landmarks.find(params[:id])
  end

  # POST /landmarks
  # POST /landmarks.xml
  def create
    @landmark = @guide.landmarks.new(params[:landmark])

    respond_to do |format|
      if @landmark.save
        flash[:notice] = 'Landmark was successfully created.'
        format.html { redirect_to([@guide, @landmark]) }
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
    @landmark = @guide.landmarks.find(params[:id])

    respond_to do |format|
      if @landmark.update_attributes(params[:landmark])
        flash[:notice] = 'Landmark was successfully updated.'
        format.html { redirect_to([@guide, @landmark]) }
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
    @landmark = @guide.landmarks.find(params[:id])
    @landmark.destroy

    respond_to do |format|
      format.html { redirect_to(guide_landmarks_url(@guide)) }
      format.xml  { head :ok }
    end
  end
end
