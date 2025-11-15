defmodule Workflows.WorkflowTest do
  use ExUnit.Case

  defmodule Workflow do
    use Ash.Resource,
      domain: Workflows.WorkflowTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table :workflows
    end

    code_interface do
      define :create, action: :create
    end

    actions do
      default_accept [:name, :description, :status]
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id
      attribute :name, :string, allow_nil?: false
      attribute :description, :string

      attribute :status, :atom do
        default :active
      end

      timestamps()
    end
  end

  defmodule WorkflowSteps do
    use Ash.Resource,
      domain: Workflows.WorkflowTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table :workflow_steps
    end

    actions do
      defaults [:read, :update, :destroy, create: :*]
    end

    attributes do
      uuid_primary_key :id
      attribute :step_order, :integer
      attribute :step_name, :string

      attribute :approver_type, :atom do
        constraints one_of: [:user, :group, :specific, :manager, :managers_manager]
        default :user
      end

      attribute :approver_id, :uuid

      attribute :approval_mode, :atom do
        constraints one_of: [:sequential, :paralle]
        default :sequential
      end

      attribute :conditions, :string
      attribute :timeout_days, :integer
      attribute :required, :boolean
    end

    relationships do
      belongs_to :template, Workflow, allow_nil?: false
    end
  end

  defmodule Requests do
    use Ash.Resource,
      domain: Workflows.WorkflowTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshApprovals]

    ets do
      table :requests
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id

      attribute :request_type, :atom do
        constraints one_of: [:initiate, :change]
      end

      attribute :status, :atom do
        constraints one_of: [:pending, :approved, :rejected, :in_progress, :completed]
      end

      attribute :request_data, :map
      create_timestamp :created_at
      update_timestamp :updated_at
    end

    relationships do
      belongs_to :template, Workflow, allow_nil?: false
      belongs_to :current_step, WorkflowSteps
    end
  end

  defmodule Approvals do
    use Ash.Resource,
      domain: Workflows.WorkflowTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table :approvals
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id

      attribute :status, :atom do
        constraints one_of: [:approved, :rejected, :pending]
        default :pending
      end

      attribute :comments, :string
      create_timestamp :approved_at
    end

    relationships do
      belongs_to :request, Requests, allow_nil?: false
      belongs_to :step, WorkflowSteps, allow_nil?: false
    end
  end

  # Update the domain to include the new resources
  defmodule Domain do
    use Ash.Domain, validate_config_inclusion?: false

    resources do
      resource Workflows.WorkflowTest.Workflow
      resource Workflows.WorkflowTest.WorkflowSteps
      resource Workflows.WorkflowTest.Requests
      resource Workflows.WorkflowTest.Approvals
    end
  end

  describe "Workflow testing" do
    test "it should create workflow" do
      Workflow.create!(%{
        name: "Expense Approval",
        description: "Workflow for approving expenses",
        status: :status
      })
      |> dbg()

      # Create Workflow Steps for the template
      # step1 = WorkflowSteps.create!(%{
      #   template_id: expense_template.id,
      #   step_order: 1,
      #   step_name: "Manager Approval",
      #   approver_type: "manager",
      #   approval_mode: "sequential",
      #   conditions: nil,
      #   timeout_days: 3,
      #   required: true
      # })

      # step2 = WorkflowSteps.create!(%{
      #   template_id: expense_template.id,
      #   step_order: 2,
      #   step_name: "Finance Group Approval",
      #   approver_type: "group",
      #   approver_id: finance_group.id,
      #   approval_mode: "parallel",
      #   conditions: "{\"amount_gt\": 1000}",
      #   timeout_days: 5,
      #   required: true
      # })

      # # Create a Request
      # request1 = Requests.create!(%{
      #   requester_id: user2.id,
      #   template_id: expense_template.id,
      #   request_type: "initiate",
      #   status: "pending",
      #   current_step_id: step1.id,
      #   request_data: %{"amount" => 1500, "description" => "Travel expenses"}
      # })

      # # Create Approvals for the request
      # approval1 = Approvals.create!(%{
      #   request_id: request1.id,
      #   step_id: step1.id,
      #   approver_id: user1.id,  # Alice as manager
      #   decision: "approved",
      #   comments: "Looks good"
      # })

      # approval2_bob = Approvals.create!(%{
      #   request_id: request1.id,
      #   step_id: step2.id,
      #   approver_id: user2.id,
      #   decision: "pending",
      #   comments: nil
      # })

      # approval2_charlie = Approvals.create!(%{
      #   request_id: request1.id,
      #   step_id: step2.id,
      #   approver_id: user3.id,
      #   decision: "approved",
      #   comments: "Approved by finance"
      # })
    end
  end
end
