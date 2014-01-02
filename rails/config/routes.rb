Mongo::Application.routes.draw do

#  scope "/scat" do
    match 'stats/' => 'stats#index'
    match 'stats/:interval/' => 'stats#index'
    match 'stats/:interval/range/:_from/:_to' => 'stats#range'
    match "auth/:token" => 'auth#set_profile'
    match "events/" => 'events#index'
    match "events/show/:id" => 'events#show'
    match "events/search" => 'events#search'
    root :to => "stats#index"
#  end

end
