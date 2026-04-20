require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    announcement = Announcement.new(
      announcement_type: "new",
      description: "A new announcement",
      name: "New Feature",
      published_at: Time.zone.now
    )
    assert announcement.valid?
  end

  test "should set default values for published_at and announcement_type" do
    announcement = Announcement.new
    assert_equal Time.zone.now, announcement.published_at
    assert_equal "new", announcement.announcement_type
  end

  test "should validate presence of required attributes" do
    announcement = Announcement.new
    assert_not announcement.valid?
    assert_includes announcement.errors[:announcement_type], "can't be blank"
    assert_includes announcement.errors[:description], "can't be blank"
    assert_includes announcement.errors[:name], "can't be blank"
    assert_includes announcement.errors[:published_at], "can't be blank"
  end

  test "should validate announcement_type inclusion" do
    announcement = Announcement.new(announcement_type: "invalid_type")
    assert_not announcement.valid?
    assert_includes announcement.errors[:announcement_type], "is not included in the list"
  end
end
