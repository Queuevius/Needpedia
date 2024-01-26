class GroupsController < ApplicationController
  before_action :set_group, only: %i[ layers show edit update destroy join request_to_join ]
  before_action :authenticate_user!

  # GET /groups or /groups.json
  def index
    if params[:user].present?
      @groups = current_user.groups.where("group_type IS NULL OR group_type != ?", Group::GROUP_TYPE_LAYER)
    else
      groups = Group.where.not(user_id: current_user.id).includes(:requests, :user).all
      @groups = groups.where("group_type IS NULL OR group_type != ?", Group::GROUP_TYPE_LAYER)
    end
  end

  # GET /groups/1 or /groups/1.json
  def show
    @requests = @group.requests
    @members = @group.members
    @posts = Post.where(group_id: @group.id)
    @invitations = Invitation.where(group_id: @group.id)
    @users_not_in_group = User.where.not(id: @members.pluck(:id)).where.not(id: @requests.pluck(:user_id)).where.not(id: @invitations.pluck(:id))
    @invitations = Invitation.where(group_id: @group.id)
    @current_user_invitation = @invitations.where(user_id: current_user.id).first
  end

  def layers
    @groups = Group.layer_groups.where(group_id: @group.id)
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  def request_to_join
    @request = @group.requests.new(user_id: current_user.id)

    if @request.save
      redirect_back(fallback_location: root_path, notice: "Request has been sent successfully.")
    else
      redirect_back(fallback_location: root_path, alert: "Unable to send the request.")
    end
  end

  def leave_group
    @group = Group.find(params[:id])
    @membership = @group.memberships.find_by(user_id: current_user.id) # Assuming memberships belong to groups

    if @membership
      @membership.destroy
      redirect_back(fallback_location: root_path, notice: "You have left the group.")
    else
      redirect_back(fallback_location: root_path, alert: "You are not a member of this group.")
    end
  end

  # POST /groups or /groups.json
  def create
    begin
      @group = Group.new(group_params)

      respond_to do |format|
        if @group.save
          create_membership(@group, current_user)
          format.html {redirect_to group_url(@group), notice: "Group was successfully created."}
          format.json {render :show, status: :created, location: @group}
        else
          format.html {render :new, status: :unprocessable_entity}
          format.json {render json: @group.errors, status: :unprocessable_entity}
        end
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
      redirect_to new_group_path(@group)
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html {redirect_to group_url(@group), notice: "Group was successfully updated."}
        format.json {render :show, status: :ok, location: @group}
      else
        format.html {render :edit, status: :unprocessable_entity}
        format.json {render json: @group.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html {redirect_to groups_url, notice: "Group was successfully destroyed."}
      format.json {head :no_content}
    end
  end

  def join
    @membership = Membership.new(user: current_user, group: @group, role: "member")
    @invitation = Invitation.find(params[:invitation_id])
    @invitation.destroy!
    if @membership.save
      redirect_to @group, notice: "You have joined the group as a member."
    else
      redirect_to @group, alert: "Unable to join the group."
    end
  end

  def update_default_group
    group_id = params[:group_id]
    # 0 means update to current user id
    group = Group.find(group_id) unless group_id&.to_i == 0
    current_user.default_group_id = group_id.in?([nil, 0]) ? nil : group_id
    if current_user.save
      flash[:notice] = "You are now logged in as #{group.present? ? group.name : "#{current_user.name.titleize} (as individual)"}"
    else
      flash[:alert] = 'Failed to update default group'
    end
    render js: "window.location.reload();"
  end

  def accept_request
    @group = Group.find(params[:id])
    @request = @group.requests.find(params[:request_id])

    if @request
      @membership = Membership.create(user: @request.user, group: @group, role: "member")
      if @membership.save
        @request.destroy # Remove the accepted request after adding the user to the group
        redirect_to @group, notice: "Request accepted."
      else
        redirect_to @group, alert: "Unable to accept the request."
      end
    else
      redirect_to @group, alert: "Request not found."
    end
  end

  def reject_request
    @group = Group.find(params[:id])
    @request = @group.requests.find(params[:request_id]) # Assuming a request belongs to a group

    if @request
      @request.destroy # Simply delete the request upon rejection
      redirect_to @group, notice: "Request rejected."
    else
      redirect_to @group, alert: "Request not found."
    end
  end

  def invite_user
    @group = Group.find(params[:group_id])
    user_to_invite = User.find(params[:user_id])

    if @group && user_to_invite
      existing_membership = @group.memberships.find_by(user_id: user_to_invite.id)

      existing_invitation = @group.invitations.find_by(user_id: user_to_invite.id)

      if existing_membership
        redirect_to @group, alert: "User is already a member of this group."
      elsif existing_invitation
        redirect_to @group, alert: "User is already invited to this group."
      else
        invitation = Invitation.create(user: user_to_invite, group: @group)

        if invitation.save
          Notification.post(from: current_user, notifiable: current_user, to: user_to_invite, group_id: @group.id, action: Notification::NOTIFICATION_TYPE_INVITE)
          redirect_to @group, notice: "Invitation sent to #{user_to_invite.email}."
        else
          redirect_to @group, alert: "Unable to send invitation."
        end
      end
    else
      redirect_to @group, alert: "Group or user not found."
    end
  end

  def accept_invitation
    invitation = current_user.invitations.find_by(group_id: params[:group_id])

    if invitation
      membership = Membership.create(user: current_user, group: invitation.group, role: "member")
      if membership.save
        invitation.update(status: "accepted") # Update invitation status upon acceptance
        redirect_to invitation.group, notice: "You have joined the group."
      else
        redirect_to invitation.group, alert: "Unable to join the group."
      end
    else
      redirect_to root_path, alert: "Invitation not found."
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :user_id, :logo, :content, :group_id, :group_type)
  end

  def create_membership(group, user)
    Membership.create!(user: user, group: group, role: "admin")
  end
end
