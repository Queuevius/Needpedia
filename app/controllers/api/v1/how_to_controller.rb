class Api::V1::HowToController < ApplicationController
  resource_description do
    name 'API v1 - HowTo'
    short 'Public How-To listing'
    api_versions 'v1'
  end

  api :GET, '/api/v1/how_to', 'List How-To items'
  def index
    how_to = HowTo.all
    render json: how_to, status: :ok
  end
end
