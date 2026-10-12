require 'test_helper'

class WelcomeResourcesViewTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def resources_style
    css_select('#np-resources style').first.text
  end

  test "guest homepage renders hidden resources menu with default content" do
    get root_path
    assert_response :success
    assert_select '#np-resources[hidden]', count: 1
    assert_select '#np-resources a[href="/how_tos/index"]'
    assert_select '#np-resources a[href="/about_us"]'
    assert_select '#np-resources a[href="/careers"]'
    assert_select '#np-resources [data-np-resources-close]'
    assert_match(/aspect-ratio: 1024 \/ 724/, resources_style)
    assert_match(/Welcome Menu - Blank/, resources_style)
  end

  test "welcome menu serves lowest-id row as singleton" do
    WelcomeMenu.delete_all
    menu = WelcomeMenu.instance
    assert menu.persisted?
    assert_equal WelcomeMenu::DEFAULT_CONTENT, menu.content

    other = WelcomeMenu.create!(content: '<p>edited</p>')
    assert_equal 2, WelcomeMenu.count
    assert_not_equal other.id, WelcomeMenu.instance.id
    assert_equal WelcomeMenu::DEFAULT_CONTENT, WelcomeMenu.instance.content_or_default
  end

  test "aspect ratio uses blob metadata when available" do
    menu = WelcomeMenu.instance
    assert_equal '1024 / 724', menu.aspect_ratio

    menu.bg_image.attach(io: StringIO.new('fake-image'), filename: 'menu.jpg', content_type: 'image/jpeg')
    menu.bg_image.blob.update_columns(metadata: { 'width' => 500, 'height' => 800 })
    assert_equal '500 / 800', menu.reload.aspect_ratio

    menu.bg_image.blob.update_columns(metadata: {})
    assert_equal '1024 / 724', menu.reload.aspect_ratio
  end

  test "attached background image renders blob path instead of default asset" do
    menu = WelcomeMenu.instance
    menu.bg_image.attach(io: StringIO.new('fake-image'), filename: 'menu.jpg', content_type: 'image/jpeg')

    get root_path
    assert_response :success
    assert_match(%r{rails/active_storage/blobs}, resources_style)
    assert_no_match(/Welcome Menu - Blank/, resources_style)
  end

  test "master admin edit persists and changes rendered menu content" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: '<p class="np-edited">edited</p>' } }
    assert_response :redirect
    assert_match %r{/master_admin/welcome_menus/\d+}, response.location

    get root_path
    assert_response :success
    assert_select '#np-resources .np-edited', text: 'edited'
  end

  test "master admin can open the edit form" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user

    get edit_master_admin_welcome_menu_path(WelcomeMenu.instance)
    assert_response :success
  end

  test "authed user with completed onboarding does not get resources menu" do
    user = users(:two)
    user.update_columns(onboarding_choice: 'ai', onboarding_completed_at: Time.current)
    sign_in user

    get root_path
    assert_response :success
    assert_select '#np-onboarding', count: 0
    assert_select '#np-resources', count: 0
  end

  test "guest cannot access welcome menu admin" do
    get master_admin_welcome_menus_path
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test "signed-in non master admin cannot access welcome menu admin" do
    sign_in users(:one)
    get master_admin_welcome_menus_path
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test "master admin can list welcome menus" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user

    get master_admin_welcome_menus_path
    assert_response :success
  end

  test "singleton create and destroy routes are not exposed" do
    assert_raises(ActionController::RoutingError) { post '/master_admin/welcome_menus', params: {} }
    assert_raises(ActionController::RoutingError) { delete '/master_admin/welcome_menus/1' }
  end
end
