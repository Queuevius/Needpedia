class HomeController < ApplicationController
  def index
    # @q = Post.ransack(params[:q])
  end

  def terms
  end

  def privacy
  end

  def time_bank
  end

  def chat
    @f = User.ransack(params[:q])
  end
end
