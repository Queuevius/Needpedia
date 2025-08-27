class Api::V1::FaqsController < ApplicationController
  def index
    faqs = Faq.all
    render json: faqs, status: :ok
  end
end
