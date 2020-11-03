class ActivityService
  def initialize(object:, event:, owner:)
    @object = object
    @event = event
    @owner = owner
  end

  attr_accessor :object, :event, :owner

  def call
    object.create_activity key: event.to_s, owner: owner
  end
end
