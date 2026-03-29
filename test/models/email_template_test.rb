require 'test_helper'

class EmailTemplateTest < ActiveSupport::TestCase
  test "should have a rich text message association" do
    email_template = EmailTemplate.new
    assert_respond_to email_template, :message
  end
end
