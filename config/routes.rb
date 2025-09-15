Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "messages/sms", to: "messages#sms"
      post "messages/email", to: "messages#email"
      post "webhooks/sms", to: "webhooks#sms"
      post "webhooks/email", to: "webhooks#email"
      get "conversations", to: "conversations#index"
      get "conversations/:id/messages", to: "conversations#messages"
      get :health, to: "health#show"
    end
  end
end
