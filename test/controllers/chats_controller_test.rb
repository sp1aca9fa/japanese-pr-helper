require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user = User.create!(email: "test@example.com", password: "password")
    app = UserApplication.create!(title: "App", user: user)
    @chat = Chat.create!(title: "Hello", user_application: app)
  end

  test "show existing chat" do
    get chat_url(@chat)
    assert_response :success
    assert_select "h1", /Chat ##{@chat.id}/
  end

  test "missing chat redirects" do
    get chat_url(id: 0)
    assert_redirected_to root_path
    assert_equal "Chat not found", flash[:alert]
  end
end
