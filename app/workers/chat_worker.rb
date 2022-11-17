class ChatWorker
  include Sidekiq::Worker

  def perform( application_token, chat_number,application_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Chat.create!( 
        application_token: application_token,
        number: chat_number,
        application_id: application_id,
      )
    end
  end
end
