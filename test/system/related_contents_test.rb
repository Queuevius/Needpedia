require "application_system_test_case"

class RelatedContentsTest < ApplicationSystemTestCase
  setup do
    @related_content = related_contents(:one)
  end

  test "visiting the index" do
    visit related_contents_url
    assert_selector "h1", text: "Related Contents"
  end

  test "creating a Related content" do
    visit related_contents_url
    click_on "New Related Content"

    click_on "Create Related content"

    assert_text "Related content was successfully created"
    click_on "Back"
  end

  test "updating a Related content" do
    visit related_contents_url
    click_on "Edit", match: :first

    click_on "Update Related content"

    assert_text "Related content was successfully updated"
    click_on "Back"
  end

  test "destroying a Related content" do
    visit related_contents_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Related content was successfully destroyed"
  end
end
