class Value
  include Mongoid::Document
  self.collection_name = "values"
  embedded_in :aae_five_minute_stats, :inverse_of => :value
  field :commands, :type => Hash
  field :summary, :type => Hash
end
