class AaeFiveMinuteStats
  include Mongoid::Document
  self.collection_name = "aae_five_minute_stats"
  embeds_one :value
end
