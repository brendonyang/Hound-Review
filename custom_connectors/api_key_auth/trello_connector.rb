{
  title: "Trello SDK",

  connection: {
    fields: [
      {
        name: "application_key",
        control_type: "text",
        label: "Trello application key",
        hint: "Get key from https://trello.com/app-key"
      },
      {
        name: "user_token",
        control_type: "password",
        label: "User token",
        hint: "Click on Token link in https://trello.com/app-key"
      }
    ],

    authorization: {
      type: "api_key",

      credentials: lambda do |connection|
        # Authenticate using query param
        params(
          key: connection["application_key"],
          token: connection["user_token"]
        )
      end
    },

    base_uri: lambda do
      "https://api.trello.com/1"
    end
  },

  test: lambda do |connection|
    get("/tokens/#{connection['user_token']}")
  end,

  object_definitions: {
    board: {
      fields: lambda do |_connection|
        [
          { name: "id" },
          { name: "name" },
          { name: "desc" },
          { name: "descData" },
          { name: "closed", type: :boolean },
          { name: "idOrganization" },
          { name: "pinned", type: :boolean },
          { name: "url" },
          { name: "shortUrl" },
          { name: "prefs", type: :object, properties: [
            { name: "permissionLevel" },
            { name: "voting" },
            { name: "comments" },
            { name: "invitations" },
            { name: "selfJoin", type: :boolean },
            { name: "cardCovers", type: :boolean },
            { name: "cardAging" }
          ] },
          { name: "labelNames", type: :object, properties: [
            { name: "green" },
            { name: "yellow" },
            { name: "orange" },
            { name: "red" },
            { name: "purple" },
            { name: "blue" },
            { name: "sky" },
            { name: "lime" },
            { name: "pink" },
            { name: "black" }
          ] }
        ]
      end
    },

    list: {
      fields: lambda do |_connection|
        [
          { name: "id" },
          { name: "name" },
          { name: "cards", type: :object, properties: [
            { name: "id" },
            { name: "name" }
          ] }
        ]
      end
    },

    card: {
      fields: lambda do |_connection|
        [
          { name: "id" },
          { name: "name" },
          { name: "pos", type: :integer },
          { name: "idBoard" },
          { name: "idList" },
          { name: "idShort" },
          { name: "closed" },
          { name: "shortUrl" },
          { name: "url" },
          { name: "desc" },
          { name: "labels", type: :array, properties: [
            { name: "id" },
            { name: "idBoard" },
            { name: "name" },
            { name: "color" }
          ] },
          { name: "idMembers", label: "Assignees", type: :array }
        ]
      end
    },

    member: {
      fields: lambda do |_connection|
        [
          { name: "id" },
          { name: "email" },
          { name: "fullName" },
          { name: "url" },
          { name: "username" }
        ]
      end
    },

    webhook_event: {
      fields: lambda do |_connection|
        [
          { name: "model", type: :object, properties: [
            { name: "id" },
            { name: "name" },
            { name: "url" },
            { name: "shortUrl" }
          ] },
          { name: "action", type: :object, properties: [
            { name: "id" },
            { name: "idMemberCreator" },
            { name: "data", type: :object, properties: [
              # If a new item is created, the corresponding section will be filled with values.
              # e.g. new list created: board and list will be filled, but not card
              { name: "board", type: :object, properties: [
                { name: "name" },
                { name: "id" },
                { name: "shortLink" }
              ] },
              { name: "list", type: :object, properties: [
                { name: "name" },
                { name: "id" }
              ] },
              { name: "card", type: :object, properties: [
                { name: "name" },
                { name: "id" },
                { name: "shortLink" },
                { name: "idShort", type: :integer },
                { name: "idList" },
                { name: "pos", type: :integer }
              ] },
              # checklist on card
              { name: "checklist", type: :object, properties: [
                { name: "name" },
                { name: "id" }
              ] },
              # action = comments on a card
              { name: "action", type: :object, properties: [
                { name: "text" },
                { name: "id" }
              ] },
              # label on card
              { name: "label", type: :object, properties: [
                { name: "color" },
                { name: "name" },
                { name: "id" }
              ] },
              # listBefore and listAfter only has values when a card changes lists
              { name: "listBefore", type: :object, properties: [
                { name: "name" },
                { name: "id" }
              ] },
              { name: "listAfter", type: :object, properties: [
                { name: "name" },
                { name: "id" }
              ] },
              { name: "checkItem", type: :object, properties: [
                { name: "name" },
                { name: "id" },
                { name: "textData" },
                { name: "state" }
              ] },
              { name: "old", type: :object, properties: [
                # This section appears if something is updated
                { name: "idList" }, # card changes list
                { name: "pos", type: :integer }, # card changes position in a list
                { name: "desc" },  # card description
                { name: "name" },  # item in checklist on card
                { name: "text" } # comment
              ] },
              { name: "text" }, # is present when a comment is added to card or label is added to card
              { name: "value" } # for label
            ] },
            { name: "type" },
            { name: "date", type: :date_time },
            { name: "memberCreator", type: :object, properties: [
              { name: "id" },
              { name: "fullName" },
              { name: "username" },
              { name: "initials" },
              { name: "avatarHash" }
            ] }
          ] }
        ]
      end
    }
  },

  actions: {
    get_board_details: {
      input_fields: lambda do
        [
          { name: "board",
            control_type: "select",
            pick_list: "board",
            optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        get("/boards/#{input['board']}").
          params(token: connection["user_token"])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["board"]
      end
    },

    get_card_by_id_or_shortlink: {
      input_fields: lambda do
        [
          { name: "id", hint: "Card ID or short link", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        get("/cards/#{input['id']}").
          params(token: connection["user_token"])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["card"]
      end
    },

    move_card: {
      input_fields: lambda do
        [
          { name: "board",
            control_type: "select",
            pick_list: "board",
            optional: false },
          { name: "list_id", hint: "List to move card to", optional: false },
          { name: "card_id", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        put("/cards/#{input['card_id']}/idList", value: input["list_id"]).
          params(token: connection["user_token"])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["card"]
      end
    },

    get_cards_in_list: {
      input_fields: lambda do
        [
          { name: "list_id", optional: false }
        ]
      end,

      execute: lambda do |_connection, input|
        {
          cards: get("/lists/#{input['list_id']}/cards")
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "cards",
            type: "array",
            of: "object",
            properties: object_definitions["card"] }
        ]
      end
    },

    search_cards: {
      description: "Search <span class='provider'>cards</span> in " \
        "<span class='provider'>Trello</span>",
      help: "At least one search parameter must be specified.",

      input_fields: lambda do
        [
          { name: "board",
            label: "Board Name",
            hint: "Search only cards on boards with this name",
            sticky: true },
          { name: "list",
            label: "List Name",
            hint: "Search only cards in lists with this name",
            sticky: true },
          { name: "name",
            label: "Card Name",
            hint: "Search only cards with this name" },
          { name: "label",
            label: "Label Name",
            hint: "Search only cards with this label" },
          { name: "member",
            label: "Assigned To",
            hint: "Search only cards that are assigned to the member " \
              "with this name" },
          { name: "closed",
            label: "Archived",
            control_type: "checkbox",
            type: "boolean",
            hint: "If set to yes, will only search cards that are archived." }
        ]
      end,

      execute: lambda do |_connection, input|
        query_string = input.map { |k, v| (k + ":\"" + v + "\"").to_s }.join(" ")
        get("/search").
          params(query: query_string,
                 modelTypes: "cards",
                 cards_limit: 200)
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: "cards",
            type: "array",
            of: "object",
            properties: object_definitions["card"]
          }
        ]
      end
    },

    get_member: {
      description: "Get <span class='provider'>member</span> details in " \
        "<span class='provider'>Trello</span>",

      input_fields: lambda do
        [
          { name: "member",
            label: "Member username",
            type: "string",
            hint: "Get details of member with this username",
            toggle_hint: "Use member username",
            optional: false,
            toggle_field: {
              name: "member",
              label: "Member ID",
              type: "string",
              hint: "Get details of member with this ID",
              toggle_hint: "Use member ID",
              optional: false
            } }
        ]
      end,

      execute: lambda do |_connection, input|
        get("/members/#{input['member']}")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["member"]
      end
    },

    update_card: {
      description: "Update <span class='provider'>card</span> in " \
        "<span class='provider'>Trello</span>",
      help: "This action can be used to move cards within and between lists " \
        "and boards, assign members to a card, and update other fields in " \
        "the Trello card.",

      input_fields: lambda do
        [
          { name: "id",
            label: "Card ID",
            sticky: true,
            optional: false },
          { name: "name",
            label: "Card name" },
          { name: "desc",
            label: "Description" },
          { name: "closed",
            label: "Archive card",
            control_type: "checkbox",
            type: "boolean",
            hint: "Setting this field to yes will archive the card." },
          { name: "idMembers",
            label: "Assignee member IDs",
            hint: "Comma separated IDs of members this card will be assigned " \
              "to." },
          { name: "idList",
            label: "List ID",
            hint: "The ID of the list that this card should be moved to." },
          { name: "idLabels",
            label: "Label IDs",
            hint: "Comma separated IDs of the labels that will be put on " \
              "this card." },
          { name: "idBoard",
            label: "Board ID",
            hint: "The ID of the board that this card should be moved to." },
          { name: "pos",
            label: "Position",
            hint: "The position of the card in the list. Can be 'top', " \
              "'bottom', or any positive float." },
          { name: "due",
            label: "Due date",
            type: "date" },
          { name: "dueComplete",
            label: "Mark due date as complete",
            control_type: "checkbox",
            type: "boolean",
            hint: "Setting this field to yes will mark the due date as " \
              "complete." }
        ]
      end,

      execute: lambda do |connection, input|
        put(
          "/cards/#{input['id']}",
          name: input["name"],
          desc: input["desc"],
          closed: input["closed"],
          idMembers: input["idMembers"],
          idList: input["idList"],
          idLabels: input["idLabels"],
          idBoard: input["idBoard"],
          pos: input["pos"],
          due: input["due"],
          dueComplete: input["dueComplete"]
        ).
          params(token: connection["user_token"])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["card"]
      end
    }
  },

  triggers: {
    updated_board: {
      input_fields: lambda do
        [
          { name: "board",
            control_type: "select",
            pick_list: "board",
            optional: false }
        ]
      end,

      webhook_subscribe: lambda do |callback_url, connection, input, _|
        data = post(
          "/tokens/#{connection['user_token']}/webhooks/",
          description: "Webhook registered by Workato recipe",
          callbackURL: callback_url,
          idModel: input["board"]
        )
        {
          id: data["id"],
          active: data["active"]
        }
      end,

      webhook_unsubscribe: lambda do |subscription, connection|
        delete(
          "/webhooks/#{subscription['id']}"
        ).params(key: connection["user_token"])
      end,

      webhook_notification: lambda do |_input, payload|
        payload
      end,

      dedup: lambda do |_event|
        rand + "@" + Time.now.utc
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["webhook_event"]
      end
    }
  },

  pick_lists: {
    board: lambda do |connection|
      get("/organizations/workatoteam/boards").
        params(token: connection["user_token"]).
        pluck("name", "id")
    end
  }
}
