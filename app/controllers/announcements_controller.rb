class AnnouncementsController < ApplicationController
  before_filter :protect_admin_page, :except => :hide_announcement
  
  # GET /announcements
  # GET /announcements.xml
  def index
    @announcements = Announcement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @announcements }
    end
  end

  # GET /announcements/1
  # GET /announcements/1.xml
  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.xml
  def new
    @announcement = Announcement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/1/edit
  def edit
    @announcement = Announcement.find(params[:id])
  end

  # POST /announcements
  # POST /announcements.xml
  def create
    @announcement = Announcement.new(params[:announcement])

    respond_to do |format|
      if @announcement.save
        flash[:notice] = 'Announcement was successfully created.'
        format.html { redirect_to(@announcement) }
        format.xml  { render :xml => @announcement, :status => :created, :location => @announcement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /announcements/1
  # PUT /announcements/1.xml
  def update
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        flash[:notice] = 'Announcement was successfully updated.'
        format.html { redirect_to(@announcement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.xml
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to(announcements_url) }
      format.xml  { head :ok }
    end
  end
  
  def hide_announcement
    cookies[:hide_time] = { :value => Time.now.to_s, :expires => 4.years.from_now }
  end
end
