# test/models/button_image_test.rb

require 'test_helper'

class ButtonImageTest < ActiveSupport::TestCase
  test "should be valid with an attached avatar" do
    button_image = ButtonImage.new
    file = fixture_file_upload('files/avatar.jpg', 'image/jpeg')
    button_image.avatar.attach(file)
    assert button_image.valid?
  end

  test "should destroy the attached avatar when the record is destroyed" do
    button_image = ButtonImage.new
    file = fixture_file_upload('files/avatar.jpg', 'image/jpeg')
    button_image.avatar.attach(file)

    assert_difference 'ActiveStorage::Attachment.count', -1 do
      button_image.destroy
    end
  end
end
