class TrackingPolicy < ApplicationPolicy

  def show?
    true
  end

  def update?
    true
  end

  def index?
    true
  end

  def create?
    true
  end
end