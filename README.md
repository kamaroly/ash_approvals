# AshApprovals

Extension to add four eye principles, two-man rule, dual control or what is known as maker-checker to you Ash Resources


## How It works

If added to the extension, this extension will block create, update and destroy actions on your resources, until those actions are approved 
by someone else in your application.
Steps:

1. Initiate a create, update, or destroy action type.
2. Intercept it, then serialises changeset with its data, opts and context.
3. Store the serialized changeset in the database table `change_requests`
4. Get next approver from the table `change_approvers`(user_id, step, approveable, status)
5. Send email requesting approval with the link details to the approver.
6. If all the approvers have approved the request, then effect the actual change
7. If one of the approvers reject the change request, then stop there
8. Notify the initiator


## Entity Relationship Diagram

### change_requests

| Field                   | Type      | Description                          | Key       |
|-------------------------|-----------|--------------------------------------|-----------|
| id                      | Integer   | The id of the request                | Primary   |
| change_request_type_id  | Integer   | one of create, update, or destroy    | Foreign (references change_request_types.id) |
| initiated_by_user_id    | Integer   | Actor who initiated the requests     | Foreign (references users.id, assumed) |
| requested_change        | Text      | serialised requested change          |           |
| status                  | Enum      | One of: Pending, Approved, Rejected, Expired |           |
| inserted_at             | Timestamp | date and time of request creation    |           |
| updated_at              | Timestamp | date and time of request update      |           |

### change_request_types

| Field                       | Type      | Description                                      | Key       |
|-----------------------------|-----------|--------------------------------------------------|-----------|
| id                          | Integer   | The ID of the change request type                | Primary   |
| name                        | String    | The name describing the change request           |           |
| description                 | Text      | Addition details for this change request         |           |
| request_approval_message    | Text      | The message for requesting approval              |           |
| request_approved_message    | Text      | The message to send to the initiator on request approval |           |
| request_rejected_message    | Text      | The message to send to the initiator on request rejected |           |

### change_request_type_workflows

| Field                   | Type      | Description                                      | Key       |
|-------------------------|-----------|--------------------------------------------------|-----------|
| id                      | Integer   | The ID of the workflow                           | Primary   |
| change_request_type_id  | Integer   | The Resource name of the change request          | Foreign (references change_request_types.id) |
| status                  | Enum      | The status of this approval requests             |           |
| step                    | Integer   | Order number of the step to change               |           |
| approver_id             | Integer   | The actor ID Of the user approving               | Foreign (references users.id, assumed) |
| approver_type           | Enum      | The type of the approver(User, Group or others)  |           |
| inserted_at             | Timestamp | date and time of request creation                |           |
| updated_at              | Timestamp | date and time of request update                  |           |

### Relationships

- **change_requests** (many) → **change_request_types** (one): Via change_request_type_id (one-to-many)
- **change_request_type_workflows** (many) → **change_request_types** (one): Via change_request_type_id (one-to-many)
- Assumed external references to a users table for initiated_by_user_id and approver_id (not detailed in provided schema)

## Requirements

For this to work effectively, the following resources must be available

1. `User` representing actor who initiate or approve requests.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ash_approvals` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ash_approvals, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ash_approvals>.

