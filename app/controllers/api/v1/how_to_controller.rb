class Api::V1::HowToController < ApplicationController
  def index
    how_to = HowTo.all
    render json: how_to, status: :ok
  end
end
