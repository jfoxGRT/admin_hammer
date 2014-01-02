class AgentAuditEvent
  include Mongoid::Document
  self.collection_name = "agent_audit_event"
  field :timestamp   # should be embeds_one
  field :eventType
  field :agentId #, type => Integer
  field :agentIp
  field :tokenDirection
  field :tokenMachineGuid
  field :tokenAgentCookie
  field :tokenPluginId
  field :tokenSuccess
  field :tokenErrors # should be embeds_one
  field :tokenParams # should be embeds_one
end
