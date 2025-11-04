defmodule AshApprovals.Transformers.DisableAtomicUpdate do
  use Spark.Dsl.Transformer

  @impl Spark.Dsl.Transformer
  def transform(dsl_state) do
    # Get update actions
    # Set `require_atomic?` to `false`
    # Return updated dsl state
    actions_path = [:actions]
    actions = Map.get(dsl_state, actions_path, %{entities: []})
    entities = actions.entities

    updated_entities =
      Enum.map(entities, fn
        %{type: :update} = action ->
          %{action | require_atomic?: false}

        other ->
          other
      end)

    updated_actions = %{actions | entities: updated_entities}
    updated_dsl_state = %{dsl_state | actions_path => updated_actions}

    {:ok, updated_dsl_state}
  end
end
