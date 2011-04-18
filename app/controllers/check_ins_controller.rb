class CheckInsController < ApplicationController
  before_filter :protect
  before_filter :protect_admin_page, :only => [:new]
  before_filter :load_trip_users, :only => [:create, :destroy, :update]
  before_filter :is_user_invited_to_trip, :only => [:create, :destroy, :update]
  
  layout "simple", :only => :new
  
  # GET /check_ins
  # GET /check_ins.xml
  def index
    @check_ins = CheckIn.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @check_ins }
    end
  end

  # GET /check_ins/1
  # GET /check_ins/1.xml
  def show
    @check_in = CheckIn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @check_in }
    end
  end

  # GET /check_ins/new
  # GET /check_ins/new.xml
  def new
    @check_in = CheckIn.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @check_in }
    end
  end

  # GET /check_ins/1/edit
  def edit
    @check_in = CheckIn.find(params[:id])
  end

  # POST /check_ins
  # POST /check_ins.xml
  def create
    @check_in = CheckIn.new(params[:check_in])
    @check_in.build_event(params[:event])
    @check_in.event.user = current_user
    @check_in.event.bookmarklet = 0
    
    # Landmark search goes here.  
    # We also need to respond with a landmark id that has been awarded

    respond_to do |format|
      if @check_in.save
        flash[:notice] = 'CheckIn was successfully created.'
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_CHECK_IN, @check_in.event.trip, "", @check_in.event, @check_in.is_public)
        
        if current_user.facebook_user? and @check_in.is_public
          attachment = WebApp.setup_fb_check_in_attachments(@check_in.event.title, trip_url(:id => @check_in.event.trip), @check_in.event.note, @check_in.event.photo.url(:thumb))
          WebApp.post_stream_on_fb(current_user.fb_user_id, 
                                  trip_url(:id => @check_in.event.trip),
                                  @check_in.event.title,
                                  "See more photos",
                                  attachment)
        end
        
        format.html { redirect_to(new_check_in_path) }
        format.xml  { render :xml => @check_in, :status => :created, :location => @check_in }
      else
        flash[:notice] = "There are errors checking in."
        format.html { render :action => "new" }
        format.xml  { render :xml => @check_in.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /check_ins/1
  # PUT /check_ins/1.xml
  def update
    @check_in = CheckIn.find(params[:id])

    respond_to do |format|
      if @check_in.update_attributes(params[:check_in])
        flash[:notice] = 'CheckIn was successfully updated.'
        format.html { redirect_to(@check_in) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @check_in.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1
  # DELETE /check_ins/1.xml
  def destroy
    @check_in = CheckIn.find(params[:id])
    @check_in.destroy

    respond_to do |format|
      format.html { redirect_to(check_ins_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /check_ins/near_by
  # GET /check_ins/near_by.xml
  def near_by
    @check_ins = CheckIn.paginate(:all, :origin => [params[:lat], params[:lng]], :within => 2, :page => params[:page],
      :conditions => ["is_public = ?", true],
      :order => "FLOOR(distance / 0.5), created_at DESC")
    respond_to do |format|
      format.xml { render :text => @check_ins.to_xml { |xml| xml.tag! 'next-page', @check_ins.next_page } }
    end
  end
  
  private 
  
  def load_trip_users
    @users = User.new
    
    if !fragment_exist?("#{params[:event][:trip_id]}-users", :time_to_live => 1.day)
      @users = User.load_trip_users(params[:event][:trip_id])
      write_fragment("#{params[:event][:trip_id]}-users", @users)
    else
      @users = read_fragment("#{params[:event][:trip_id]}-users")
    end
  end
end
