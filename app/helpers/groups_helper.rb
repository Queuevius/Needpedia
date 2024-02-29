module GroupsHelper
  def group_request(group_id, actor_id)
    group = Group.find(group_id)
    request = group.requests.where(user_id: actor_id).last

    return request
  end

  def group_invitation(group_id, actor_id)
    group = Group.find(group_id)
    invitation = group.invitations.where(user_id: actor_id)

    return invitation
  end
end
