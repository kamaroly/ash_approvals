defmodule AshApprovals.Transformers.AddSubmitForApprovalChange do
  use Spark.Dsl.Transformer

  @impl Spark.Dsl.Transformer
  def transform(dsl_state) do
    Ash.Resource.Builder.add_change(dsl_state, AshApprovals.Changes.SubmitForApproval,
      on: [:create, :update, :destroy]
    )
  end
end
