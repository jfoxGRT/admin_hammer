class Heartbeats
  include Mongoid::Document
  self.collection_name = "heartbeats"
  field :a, :class => Integer
end
