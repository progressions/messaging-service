module Api
  module V1
    class ConversationsController < ApplicationController
    def index
      page, per_page, offset = pagination_params(default_per: 20, max: 100)
      scope = Conversation.order(Arel.sql("COALESCE(last_message_at, updated_at) DESC, id DESC"))
      total_count = scope.count
      conversations = scope.limit(per_page).offset(offset)

      set_pagination_headers(total_count: total_count, page: page, per_page: per_page)
      set_link_header(base_scope: scope, page: page, per_page: per_page)

      render json: conversations, each_serializer: ::ConversationSerializer
    end

    def messages
      page, per_page, offset = pagination_params(default_per: 50, max: 200)
      conversation = Conversation.find(params[:id])
      scope = conversation.messages.order(Arel.sql("COALESCE(sent_at, created_at) ASC"))
      total_count = scope.count
      msgs = scope.limit(per_page).offset(offset)

      set_pagination_headers(total_count: total_count, page: page, per_page: per_page)
      set_link_header(base_scope: scope, page: page, per_page: per_page)

      render json: msgs, each_serializer: ::MessageSerializer
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Conversation not found" }, status: :not_found
    end

    private

    def pagination_params(default_per:, max:)
      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page].to_i
      per_page = default_per if per_page <= 0
      per_page = max if per_page > max
      offset = (page - 1) * per_page
      [page, per_page, offset]
    end

    def set_pagination_headers(total_count:, page:, per_page:)
      total_pages = (total_count.to_f / per_page).ceil
      response.set_header('X-Total-Count', total_count)
      response.set_header('X-Total-Pages', total_pages)
      response.set_header('X-Page', page)
      response.set_header('X-Per-Page', per_page)
    end

    def set_link_header(base_scope:, page:, per_page:)
      total_count = response.get_header('X-Total-Count').to_i
      return if total_count.zero?

      last_page = (total_count.to_f / per_page).ceil
      links = []
      if page < last_page
        links << %(<#{build_page_url(page + 1, per_page)}>; rel="next")
      end
      if page > 1
        links << %(<#{build_page_url(page - 1, per_page)}>; rel="prev")
      end
      response.set_header('Link', links.join(', ')) unless links.empty?
    end

    def build_page_url(page, per_page)
      query = request.query_parameters.merge('page' => page, 'per_page' => per_page)
      uri = URI.parse(request.url)
      uri.query = query.to_query
      uri.to_s
    end

    # Presentation handled by ActiveModelSerializers
    end
  end
end
