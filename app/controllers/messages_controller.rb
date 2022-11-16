
class MessagesController < ApplicationController
  
  def index
    chat = Chat.find_by(number: params[:chatNumber], application_token: params[:appToken])
    if chat
      messages = chat.messages
      render json: messages.as_json(:except => [:id,:chat_id])
    else
      render json: { error: 'No Chat Found' }, status: 404
    end
  end

  def create
    if params[:body] and params[:body] != ""
      chat = Chat.find_by(number: params[:chatNumber], application_token: params[:appToken])
      if chat
        message = chat.messages.build(params.require(:message).permit(:body))
        redis = RedisService.new
        message.number = redis.increment_counter("message_number_for_app_#{params[:appToken]}_chat#{chat.number}")
        if message.valid?
          MessageWorker.perform_async(chat.application_token, chat.id, chat.number, message.number, message.body)
          render json: message.as_json(only: [:number,:body]), status: :created
        else
          render json: message.errors, status: :unprocessable_entity
        end
      else
        render json: { error: 'No Chat Found' }, status: 404
      end
    else
      render json: { error: 'Missing or invalid body' }, status: 400
    end

  end

  def search
    chat = Chat.find_by(number: params[:chatNumber], application_token: params[:appToken])
    if chat
      messages = Message.partial_search(params['message'], chat).results.to_a
      if messages.empty?
        render json: { error: 'No Messages Found' }, status: 404
      else
        messages.each do |item|
          item.delete("_id")
          item.delete("_type")
          item.delete("_index")
          item['_source'].delete("id")
          item['_source'].delete("chat_id") 
        end
        render json: messages.as_json
      end
    else
      render json: { error: 'No Chat Found' }, status: 404
    end
  end

  def show
    chat = Chat.find_by(number: params[:chatNumber], application_token: params[:appToken])
    if chat
      message = chat.messages.find_by(number: params[:number])
      if message
        render json: message.as_json(:except => [:id,:chat_id])
      else
        render json: { error: 'No Message Found' }, status: 404
      end
    else
      render json: { error: 'No Chat Found' }, status: 404
    end
  end

  def update
    if params[:body] and params[:body] != ""
      chat = Chat.find_by(number: params[:chatNumber], application_token: params[:appToken])
      if chat
        message = chat.messages.find_by(number: params[:number])
        if message
          if message.update(params.require(:message).permit(:body))
            render json: message.as_json(:except => [:id,:chat_id])
          else
            render json: message.errors, status: :unprocessable_entity
          end
        else
          render json: { error: 'No Message Found' }, status: 404
        end
      else
        render json: { error: 'No Chat Found' }, status: 404
      end
    else
      render json: { error: 'Missing or invalid body' }, status: 400
    end
  end
end
