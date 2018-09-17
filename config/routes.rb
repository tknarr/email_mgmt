# == Route Map
#
#                Prefix Verb   URI Pattern                                                  Controller#Action
#          passwd_users GET    /email-management/1.0/users/passwd(.:format)                 user#passwd {:format=>:json}
#                 users GET    /email-management/1.0/users(.:format)                        user#index {:format=>:json}
#                       POST   /email-management/1.0/users(.:format)                        user#create {:format=>:json}
#                  user PATCH  /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_.]+/}
#                       PUT    /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_.]+/}
#                       DELETE /email-management/1.0/user/:id(.:format)                     user#destroy {:format=>:json, :id=>/[[:alnum:]_.]+/}
#          current_user GET    /email-management/1.0/user(.:format)                         user#current {:format=>:json}
#       update_password POST   /email-management/1.0/password(.:format)                     user#update_password {:format=>:json}
#                routes GET    /email-management/1.0/routes(.:format)                       route#index {:format=>:json}
#                       POST   /email-management/1.0/routes(.:format)                       route#create {:format=>:json}
#                 route PATCH  /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                       PUT    /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                       DELETE /email-management/1.0/route/:username/:domain_name(.:format) route#destroy {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#       routing_domains GET    /email-management/1.0/domains/routing(.:format)              domain#routing {:format=>:json}
#               domains GET    /email-management/1.0/domains(.:format)                      domain#index {:format=>:json}
#                       POST   /email-management/1.0/domains(.:format)                      domain#create {:format=>:json}
#                domain PATCH  /email-management/1.0/domain/:id(.:format)                   domain#update {:format=>:json, :id=>/[[:graph:]]+/}
#                       PUT    /email-management/1.0/domain/:id(.:format)                   domain#update {:format=>:json, :id=>/[[:graph:]]+/}
#                       DELETE /email-management/1.0/domain/:id(.:format)                   domain#destroy {:format=>:json, :id=>/[[:graph:]]+/}
#         account_types GET    /email-management/1.0/account_types(.:format)                account_type#index {:format=>:json}
#   system_aliases_sync GET    /email-management/1.0/system_aliases/sync(.:format)          system_alias#sync {:format=>:json}
# system_aliases_merged GET    /email-management/1.0/system_aliases/merged(.:format)        system_alias#merged_index {:format=>:json}
#        system_aliases GET    /email-management/1.0/system_aliases(.:format)               system_alias#index {:format=>:json}
#         relay_domains GET    /email-management/1.0/relay_map/domains(.:format)            relay_map#domains
#      relay_recipients GET    /email-management/1.0/relay_map/recipients(.:format)         relay_map#recipients

Rails.application.routes.draw do

    scope '/email-management/1.0' do
        defaults format: :json do

            # User mappings
            resources :users, only: [:index, :create], controller: 'user' do
                collection do
                    get 'passwd'
                end
            end
            resources :user, only: [:update, :destroy], controller: 'user', constraints: {id: /[[:alnum:]_.]+/}
            # Regular user operations
            get 'user', action: :current, controller: 'user', as: :current_user
            post 'password', action: :update_password, controller: 'user', as: :update_password

            # Route mappings
            resources :routes, only: [:index, :create], controller: 'route'
            # Have to do this manually since the "id" is two parts not just one
            patch 'route/:username/:domain_name', action: :update, controller: 'route', constraints: {username: /([[:alnum:]_.]+|\*)/, domain_name: /[[:graph:]]+/}, as: :route
            put 'route/:username/:domain_name', action: :update, controller: 'route', constraints: {username: /([[:alnum:]_.]+|\*)/, domain_name: /[[:graph:]]+/}
            delete 'route/:username/:domain_name', action: :destroy, controller: 'route', constraints: {username: /([[:alnum:]_.]+|\*)/, domain_name: /[[:graph:]]+/}

            # Domain mappings
            resources :domains, only: [:index, :create], controller: 'domain' do
                collection do
                    get 'routing'
                end
            end
            resources :domain, only: [:update, :destroy], controller: 'domain', constraints: {id: /[[:graph:]]+/}

            # Account types
            get 'account_types', action: :index, controller: 'account_type'

            # System aliases
            get 'system_aliases/sync', action: :sync, controller: 'system_alias', as: :system_aliases_sync
            get 'system_aliases/merged', action: :merged_index, controller: 'system_alias', as: :system_aliases_merged
            get 'system_aliases', action: :index, controller: 'system_alias'

        end

        get 'relay_map/domains', controller: 'relay_map', as: :relay_domains
        get 'relay_map/recipients', controller: 'relay_map', as: :relay_recipients

    end

end
