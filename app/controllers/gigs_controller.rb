class GigsController < ApplicationController
  before_action :authenticate_user!

  # GET /gigs
  # GET /gigs.json
  def index
    @gigs = current_user.gigs
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
    @gig = Gig.find(params[:id])
    @gig.destroy
    respond_to do |format|
      format.html { redirect_to gigs_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
  end

  def search_result
    keywords = params[:q]
    @q = Gig.ransack(keywords)
    @gigs = @q.result(distinct: true).where(status: Gig::GIG_STATUS_ACTIVE)
  end

  private

  # Only allow a list of trusted parameters through.
  def gig_params
    params.require(:gig).permit(:title, :area_tag, :user_id, :body, :amount)
  end
end
