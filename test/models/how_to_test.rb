require 'test_helper'

class HowToTest < ActiveSupport::TestCase
  test "should have one attached question_picture" do
    how_to = HowTo.new
    how_to.question_picture.attach(io: File.open('test/fixtures/sample_image.jpg'), filename: 'sample_image.jpg', content_type: 'image/jpeg')

    assert how_to.valid?
  end

  test "should have one attached answer_picture" do
    how_to = HowTo.new
    how_to.answer_picture.attach(io: File.open('test/fixtures/sample_image.jpg'), filename: 'sample_image.jpg', content_type: 'image/jpeg')

    assert how_to.valid?
  end
end
