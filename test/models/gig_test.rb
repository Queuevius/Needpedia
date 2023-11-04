require 'test_helper'

class GigTest < ActiveSupport::TestCase
  test "should have title, area_tag, body, and amount" do
    gig = Gig.new(title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    assert gig.valid?
  end

  test "should belong to a user (optional)" do
    user = User.create(name: "Test User")
    gig = Gig.new(user: user, title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    assert gig.valid?
  end

  test "should have many user_gigs with dependent destroy" do
    gig = Gig.create(title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    user = User.create(name: "Test User")
    user_gig = UserGig.create(user: user, gig: gig)

    assert_includes gig.user_gigs, user_gig

    assert_difference 'UserGig.count', -1 do
      gig.destroy
    end
  end

  test "should have a one-to-one credit_transaction (Transaction)" do
    gig = Gig.create(title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    transaction = Transaction.create(gig: gig, amount: 100)

    assert_equal transaction, gig.credit_transaction
  end

  test "should have a rich text body association" do
    gig = Gig.new(title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    assert gig.valid?
  end

  test "should have many attached images with specified content types and size range" do
    gig = Gig.new(title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 100)
    gig.images.attach(io: File.open('test/fixtures/sample_image.jpg'), filename: 'sample_image.jpg', content_type: 'image/jpeg')
    assert gig.valid?
  end

  test "should validate that amount is not greater than available credit" do
    user = User.create(name: "Test User", credit_hours: 200)
    gig = Gig.new(user: user, title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 250)

    assert_not gig.valid?
    assert_includes gig.errors[:amount], "can not be greater than available credit"
  end

  test "should activate gig if user has positive credit hours" do
    user = User.create(name: "Test User", credit_hours: 100)
    gig = Gig.create(user: user, title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 50)

    assert_equal Gig::GIG_STATUS_ACTIVE, gig.status
  end

  test "should not activate gig if user has zero credit hours" do
    user = User.create(name: "Test User", credit_hours: 0)
    gig = Gig.create(user: user, title: "Sample Gig", area_tag: "Technology", body: ActionText::Content.new("Gig description"), amount: 50)

    assert_equal Gig::GIG_STATUS_PENDING, gig.status
  end
end
