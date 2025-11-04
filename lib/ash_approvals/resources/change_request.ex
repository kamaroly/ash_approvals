defmodule AshApprovals.Resources.ChangeRequest do
  use Ash.Resource,
    domain: AshApprovals.Domain,
    data_layer: Ash.DataLayer.Ets

  ets do
    table :change_requests
  end

  actions do
    default_accept [:changeset, :context, :opts, :status, :action, :action_type]
    defaults [:create, :read, :update, :destroy]

    update :approve do
      description "Approve an existing request and affect underlying datalayer"
      change set_attribute(:status, :approved)
      change AshApprovals.Changes.ProccessApproved
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :changeset, :string, allow_nil?: false
    attribute :context, :map, allow_nil?: false
    attribute :opts, :map, allow_nil?: false
    attribute :status, :atom, default: :pending
    attribute :action, :atom, allow_nil?: false
    attribute :action_type, :atom, allow_nil?: false
    timestamps()
  end
end
