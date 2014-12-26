require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'

class Model
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id

#  link :self do
#    "/#{id}"
#  end
end

