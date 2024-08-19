class GigsController < ApplicationController
  include OtpVerifiable

  before_action :authenticate_user!
  before_action :set_tutorial, except: [:destroy, :create, :disable]
  before_action :check_otp

  # GET /gigs
  # GET /gigs.json
  def index
    posted_gigs = current_user.posted_gigs
    work_gig = current_user.gigs
    gigs = posted_gigs + work_gig
    @gigs = gigs.uniq
  end


  # GET /gigs/1
  # GET /gigs/1.json
  def show
    @gig = Gig.find(params[:id])
  end

  # GET /gigs/new
  def new
    unless current_user.credit_hours.positive?
      flash[:alert] = 'You dont have enough credit hours to Post a gig'
      redirect_to time_bank_path and return
    end
    @gig = Gig.new()
  end

  # GET /gigs/1/edit
  def edit
    @gig = Gig.find(params[:id])
  end

  # POST /gigs
  # POST /gigs.json
  def create
    unless current_user.credit_hours.positive?
      flash[:alert] = 'You dont have enough credit hours to Post a gig'
      redirect_to time_bank_path and return
    end
    @gig = Gig.new(gig_params)

    respond_to do |format|
      if @gig.save
        format.html { redirect_to gigs_url, notice: 'Gig was successfully created.' }
        format.json { render :show, status: :created, location: @gig }
        create_activity(@gig, 'gig.create')
      else
        flash[:alert] = @gig.errors.full_messages.join(',')
        format.html { render :new }
        format.json { render json: @gig.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gigs/1
  # PATCH/PUT /gigs/1.json
  def update
    @gig = Gig.find(params[:id])

    respond_to do |format|
      if @gig.update(gig_params)
        if params[:gig][:images].present?
          params[:gig][:images].each do |image|
            @gig.images.attach(image)
          end
        end
        format.html { redirect_to gigs_url, notice: 'Gig was successfully updated.' }
        format.json { render :show, status: :ok, location: @gig }
        create_activity(@gig, 'gig.update')
      else
        flash[:alert] = @gig.errors.full_messages.join(',')
        format.html { render :edit }
        format.json { render json: @gig.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gigs/1
  # DELETE /gigs/1.json
  def destroy
    begin
      @gig = Gig.find(params[:id])
      create_activity(@gig, 'gig.destroy')
      @gig.destroy
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    respond_to do |format|
      format.html { redirect_to gigs_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def disable
    @gig = Gig.find(params[:gig_id])
    if @gig.update(status: Gig::GIG_STATUS_DISABLE)
      flash[:notice] = 'Gig is disabled and wont be available in search anymore.'
    else
      flash[:alert] = 'Something went wrong'
    end
    redirect_to @gig
  end

  def search
    @q = Gig.ransack(params[:q])
  end

  def search_result
    @keywords = params[:q]
    @q = Gig.ransack(@keywords)
    @gigs = @q.result(distinct: true).where(status: Gig::GIG_STATUS_ACTIVE)
  end

  def accept
    begin
      gig_id = params.require(:gig_id)
      gig = Gig.find(gig_id)
      recipient = gig.user

      gig.status = Gig::GIG_STATUS_PROGRESS
      gig.users << current_user

      notification = Notification.post(from: current_user, notifiable: current_user, to: recipient, action: Notification::NOTIFICATION_TYPE_ACCEPTED)

      if gig.save!(validate: false) && notification
        flash[:notice] = 'Gig Accepted successfully.'
      else
        flash[:alert] = 'Your request could not be completed, please try again'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_to gig_path(gig)
  end

  # def my_accepted
  #   @gigs = current_user.gigs
  # end

  private

  # Only allow a list of trusted parameters through.
  def gig_params
    params.require(:gig).permit(:title, :area_tag, :user_id, :body, :amount, images: [])
  end

  def set_tutorial
    @url = "#{params[:controller]}"
    @url += "/#{params[:action]}" if params[:action] != "index"
    @user_tutorial = current_user.user_tutorials.where(link: @url).last if current_user.present?
  end

  def create_activity(gig, event)
    ActivityService.new(object: gig, event: event, owner: current_user, ip: request.remote_ip).call
  end
end
