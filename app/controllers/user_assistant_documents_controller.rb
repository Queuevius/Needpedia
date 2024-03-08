class UserAssistantDocumentsController < ApplicationController
  before_action :authenticate_token

  def pdf_links
    begin
      documents = UserAssistantDocument.all
      links = documents.map { |document| pdf_link(document) }
      render json: { links: links }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  def pdf_file
    begin
      document = UserAssistantDocument.find(params[:id])
      pdf = document.file
      render_json_with_url(pdf)
    rescue ActiveRecord::RecordNotFound
      render json: {error: "PDF not found with id=#{params[:id]}"}, status: :not_found
    end
  end

  private

  def authenticate_token
    unless ENV['PDF_TOKEN'].present? && ENV['PDF_TOKEN'] == request.headers["HTTP_PDF_TOKEN"]
      render json: {error: 'The provided authorization token is not valid'}, status: :unauthorized
    end
  end

  def render_json_with_url(pdf)
    domain = ENV['DOMAIN']
    render json: {url: "#{domain}#{url_for(pdf)}"}, status: :ok
  end

  def pdf_link(document)
    domain = ENV['DOMAIN']
    { id: document.id, url: "#{domain}#{url_for(document.file)}" }
  end
end
