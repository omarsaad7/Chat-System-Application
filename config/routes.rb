Rails.application.routes.draw do

  post '/applications', to: 'applications#create'
  get '/applications', to: 'applications#index'
  get '/applications/:appToken', to: 'applications#show'
  put '/applications/:appToken', to: 'applications#update'
  post '/applications/:application_token/chats', to: 'chats#create'
  get '/applications/:application_token/chats', to: 'chats#index'
  get '/applications/:application_token/chats/:number', to: 'chats#show'
  get '/applications/:appToken/chats/:chatNumber/messages', to: 'messages#index'
  get '/applications/:appToken/chats/:chatNumber/messages/:number', to: 'messages#show'
  post '/applications/:appToken/chats/:chatNumber/messages', to: 'messages#create'
  get '/applications/chats/messages/app-token/:appToken/chat-number/:chatNumber/elastic-search', to: 'messages#search'
  put '/applications/:appToken/chats/:chatNumber/messages/:number', to: 'messages#update'
end
