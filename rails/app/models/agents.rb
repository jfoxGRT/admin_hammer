class Agents
  include Mongoid::Document
  self.collection_name = "agents"
  field :_id, :class => Integer
end
