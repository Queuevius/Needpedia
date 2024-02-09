module GroupsHelper
  def group_request(group_id, actor_id)
    group = Group.find(group_id)
    request = group.requests.where(user_id: actor_id).last

    return request
  end

end
