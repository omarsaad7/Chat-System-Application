
class ChatsController < ApplicationController

  def index
    application = Application.find_by(token: params[:application_token])
    chats = application.chats
    render json: chats.as_json(:except => [:id,:application_id])
  end

  def show
    chat = Chat.find_by(number: params[:number], application_token: params[:application_token])
    if chat
      render json: chat.as_json(:except => [:id,:application_id])
    else
      render json: { error: 'No Chat Found' }, status: 404
    end
    
  end

  def create
    application = Application.find_by(token: params[:application_token])
    chat = application.chats.build
    redis = RedisService.new
    chat.number = redis.increment_counter("chat_number_for_app_#{application.token}")
    if chat.valid?
      ChatWorker.perform_async( application.token, chat.number,application.id)
      render json: chat.as_json(only: [:number]), status: :created
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  end
    
end
