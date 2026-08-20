module Api
  module V1
    class TranslationsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def translate
        text = params[:text]
        target = params[:target_lang]
        source = params[:source_lang] || 'en'

        if text.blank? || target.blank?
          render json: { error: 'text and target_lang required' }, status: 400 and return
        end

        service = TranslationService.new(source_lang: source, target_lang: target)
        translated = service.translate_text(text.to_s)
        render json: { translated_text: translated || text }
      end

      def batch_translate
        texts = params[:texts]
        target = params[:target_lang]
        source = params[:source_lang] || 'en'

        if texts.blank? || !texts.is_a?(Array) || target.blank?
          render json: { error: 'texts (array) and target_lang required' }, status: 400 and return
        end

        service = TranslationService.new(source_lang: source, target_lang: target)
        results = service.translate_texts(texts)
        render json: { translations: results }
      end

      # POST /api/v1/translations/save
      def save
        post = Post.find_by(id: params[:post_id])
        return render json: { error: 'Post not found' }, status: :not_found unless post

        translation = PostTranslation.find_or_initialize_by(post: post, language: params[:language])
        translation.content = params[:content]
        translation.user = current_user if current_user
        if translation.save
          render json: { status: 'ok', translation: { id: translation.id, language: translation.language, post_id: post.id } }
        else
          render json: { error: translation.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/translations/:post_id
      def index
        translations = PostTranslation.for_post(params[:post_id]).pluck(:language, :content)
        render json: { translations: translations.to_h }
      end
    end
  end
end
