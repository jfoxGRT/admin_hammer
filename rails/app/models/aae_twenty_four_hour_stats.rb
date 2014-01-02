class AaeTwentyFourHourStats
  include Mongoid::Document
  self.collection_name = "aae_twenty_four_hour_stats"
  embeds_one :value
end
