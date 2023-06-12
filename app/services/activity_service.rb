class ActivityService
  def initialize(object:, event:, owner:, ip:)
    @object = object
    @event = event
    @owner = owner
    @ip = ip
  end

  attr_accessor :object, :event, :owner, :ip

  def call
    object.create_activity key: event.to_s, owner: owner, ip: ip
  end
end
