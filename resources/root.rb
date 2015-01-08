require 'resources/base'

class RootResource < BaseResource

  let(:allowed_methods) { %w{GET} }

# resources = %w{ product user session }

  def response_body
    result = {
      _links: {
        self: {
          href: '/'
        },
        curies: [
          {
            name: curie_name,
            href: "http://#{request.host}:#{request.port}/rels/{rel}",
            templated: true
          }
        ],
        "#{curie_name}:products" =>  {
          href: '/products'
        },
        "#{curie_name}:users" =>  {
          href: '/users'
        }
      },
      welcome: 'Welcome to Kiffin\'s Demo HAL Server.',
      hint_1:  'This is the first hint.',
      hint_2:  'This is the second hint.',
      hint_3:  'This is the third hint.',
      hint_4:  'This is the fourth hint.',
      hint_5:  'This is the last hint.'
    }
    puts "Resource::Root[#{request.method}] response_body_resource => #{result.inspect}"
    result
  end
end

