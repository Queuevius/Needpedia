class Api::V1::FaqsController < ApplicationController
  resource_description do
    name 'API v1 - FAQs'
    short 'Public FAQs listing'
    api_versions 'v1'
  end

  api :GET, '/api/v1/faqs', 'List FAQs'
  def index
    faqs = Faq.all
    render json: faqs, status: :ok
  end
end
