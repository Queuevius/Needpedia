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
    assert_select 'textarea#summernote_content'
    assert_select 'textarea#summernote_onboarding_text'
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

  test "overlay shows default onboarding text when column is blank" do
    WelcomeMenu.instance.update!(onboarding_text: nil)

    get root_path
    assert_response :success
    assert_select '#np-onboarding .np-onboarding__text', text: WelcomeMenu::ONBOARDING_DEFAULT_TEXT
  end

  test "master admin edit persists and changes rendered onboarding text" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: menu.content, onboarding_text: 'CUSTOM_ONBOARDING_XYZ' } }
    assert_response :redirect
    assert_equal 'CUSTOM_ONBOARDING_XYZ', menu.reload.onboarding_text

    get root_path
    assert_response :success
    assert_select '#np-onboarding .np-onboarding__text', text: 'CUSTOM_ONBOARDING_XYZ'
  end

  test "blank onboarding_text from admin falls back to default" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: menu.content, onboarding_text: '' } }
    assert_response :redirect
    assert_nil menu.reload.onboarding_text
  end

  test "overlay renders HTML in onboarding text" do
    WelcomeMenu.instance.update!(onboarding_text: '<strong>bold_intro</strong> and more')

    get root_path
    assert_response :success
    assert_select '#np-onboarding .np-onboarding__text strong', text: 'bold_intro'
  end

  test "master admin show page renders content as HTML not escaped text" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance

    get master_admin_welcome_menu_path(menu)
    assert_response :success
    assert_select 'a[href="/how_tos/index"]'
    assert_select 'a[href="/about_us"]'
    assert_select 'a[href="/careers"]'
    assert_no_match(/&lt;p&gt;Here are some places/, response.body)
  end

  test "master admin index page renders content as HTML not escaped text" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user

    get master_admin_welcome_menus_path
    assert_response :success
    assert_no_match(/&lt;p&gt;Here are some places/, response.body)
  end

  # --- P0: authz edge cases ---

  test "guest cannot open welcome menu edit form" do
    get edit_master_admin_welcome_menu_path(WelcomeMenu.instance)
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test "signed-in non master admin cannot open welcome menu edit form" do
    sign_in users(:one)
    get edit_master_admin_welcome_menu_path(WelcomeMenu.instance)
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test "signed-in non master admin cannot PATCH welcome menu" do
    user = users(:one)
    sign_in user
    menu = WelcomeMenu.instance
    original = menu.content

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: '<p>hacked</p>' } }
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
    assert_equal original, menu.reload.content
  end

  test "master admin PATCH keeps singleton invariant (no second row)" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance
    assert_equal 1, WelcomeMenu.count

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: '<p>still one</p>' } }
    assert_response :redirect

    assert_equal 1, WelcomeMenu.count
    assert_equal '<p>still one</p>', WelcomeMenu.instance.reload.content
    assert_equal menu.id, WelcomeMenu.instance.id
  end

  test "master admin update with blank onboarding_text cannot null out content" do
    user = users(:one)
    user.update_columns(master_admin: true)
    sign_in user
    menu = WelcomeMenu.instance

    patch master_admin_welcome_menu_path(menu), params: { welcome_menu: { content: '', onboarding_text: 'keep_me' } }
    assert_response :redirect

    # content falls back to default (never blank), onboarding_text persists
    assert_equal WelcomeMenu::DEFAULT_CONTENT, menu.reload.content_or_default
    assert_equal 'keep_me', menu.onboarding_text
  end
end
