{
  title: "SuccessFactors",

  secure_tunnel: true,

  connection: {
    fields: [
      {
        name: "username",
        optional: false
      },
      {
        name: "password",
        control_type: "password",
        optional: false
      },
      {
        name: "company",
        label: "Company ID",
        optional: false
      },
      {
        name: "endpoint",
        label: "API endpoint",
        optional: false,
        hint: "Provide the endpoint of the API excluding /odata/v2 " \
          "e.g. for location USA, Arizona, Chandler " \
          "- <code>https://api4.successfactors.com</code>"
      }
    ],

    authorization: {
      type: "basic_auth",

      credentials: lambda do |connection|
        user(connection['username'] + "@" + connection['company'])
        password(connection['password'])
      end
    },

    base_uri: lambda do |connection|
      connection['endpoint']
    end
  },

  object_definitions: {
    object_output: {
      fields: lambda do |_connection, config|
        call("generate_schama", object_name: config['object_name'], type: "@visible")
      end
    },

    object_create: {
      fields: lambda do |_connection, config|
        call("generate_schama", object_name: config['object_name'], type: "@creatable")
      end
    },

    object_update: {
      fields: lambda do |_connection, config|
        call("generate_schama", object_name: config['object_name'], type: "@updatable")
      end
    },

    object_upsert: {
      fields: lambda do |_connection, config|
        call("generate_schama", object_name: config['object_name'], type: "@upsertable")
      end
    },

    object_filter: {
      fields: lambda do |_connection, config|
        call("generate_schama", object_name: config['object_name'], type: "@filterable")
      end
    },
    
    option_labels: {
      fields: lambda do
        [
          { name: "optionId" },
          { name: "locale" },
          { name: "id" },
          { name: "label" }
        ]
      end
    }
  },

  test: lambda { |_connection|
    get("/odata/v2/User?$top=1")
  },

  methods: {
    date_fields: lambda do |input|
      get("/odata/v2/" + input[:object_name] + "/$metadata").
        response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema",
         1, "EntityType", 0, "Property").
        select do |field|
          ["Edm.DateTime", "Edm.DateTimeOffset"].include?(field["@Type"])
        end.
        map { |e| e["@Name"] }
    end,

    object_key: lambda do |input|
      get("/odata/v2/" + input[:object_name]  + "/$metadata").
        response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
          "EntityType", 0, "Key", 0, "PropertyRef")[0]["@Name"]
    end,
    #generates pick list options for the given PicklistId
    get_pick_list_options: lambda do |input|
      get("/odata/v2/Picklist('" + input[:pick_list_id] + "')/picklistOptions").
      params("$format": "json").
      headers("Accept": "application/json",
        "Content-Type": "application/json").
      dig("d", "results")&.
      select {|o| o["status"] == "ACTIVE" }&. map do |option|
        option = get(get(option.dig("__metadata", "uri")).
          params("$format": "json").
          headers("Accept": "application/json",
            "Content-Type": "application/json").
          dig("d", "picklistLabels", "__deferred", "uri")).
        params("$format": "json").
        headers("Accept": "application/json",
          "Content-Type": "application/json").
        dig("d", "results")&.first || {}
          [option["label"], option["optionId"]]
        end
    end,
    #generates schema for the objects w.r.t operations.
    generate_schama: lambda do |input|
      key_column = call(:object_key, {object_name: input[:object_name]})
      get("/odata/v2/#{input[:object_name]}/$metadata").
      response_format_xml.
      dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
        "EntityType", 0, "Property").
      select { |field| field[input[:type]] == "true" }.
        map do |o|
          optional =
            if input[:type] == "@updatable" && o["@Name"] == key_column
              false
            elsif input[:type] == "@creatable" || input[:type] == "@updatable"
              o["@required"].include?("false") 
            else
              true
            end
          description = if ( input[:type] == "@upsertable" && o["@Name"] == key_column )
            if o["@Name"] == key_column
              "Key column, updates if exists othewise create new one"
            elsif o["@required"].include?("true")
              "Required "
            end
          end || nil
          sticky = if ( input[:type] == "@upsertable" && o["@required"].include?("true")  )
            true
          end || false
          
          case o["@Type"]
          when "Edm.String"
            if o["@picklist"].present?
              # switch if all the picklists are configured correctly in SF
              # options = call("get_pick_list_options", { pick_list_id: o["@picklist"] })&.presence || []
              # { name: o["@Name"], control_type: "select",
              #   pick_list: options,
              #   optional: optional,
              #   label:  o["@label"].labelize
                  # toggle_hint: "Select from list",
                  # toggle_field: {
                  #   toggle_hint: "Enter custom value",
                  #   name: o["@Name"], type: "string",
                  #   control_type: "text",
                  #   label: o["@label"].labelize,
                  #   optional: optional
                  # }
              # }
              { name: o["@Name"], type: "string",
                optional: optional,
                sticky: sticky,
                hint: description,
                label:  o["@label"].labelize,
                hint: "Pick list option id should be provided" }
            else
            { name: o["@Name"], type: "string",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
            end
          when "Edm.Boolean"
            { name: o["@Name"], type: "boolean",
              control_type: "checkbox",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Byte"
            { name: o["@Name"], type: "integer",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.DateTime"
            { name: o["@Name"], type: "date_time",
              control_type: "date_time",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize}
          when "Edm.Decimal"
            { name: o["@Name"], type: "number",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Double"
            { name: o["@Name"], type: "number",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Single"
            { name: o["@Name"], type: "number",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Guid"
            { name: o["@Name"], type: "string",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Int16"
            { name: o["@Name"], type: "integer",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Int32"
            { name: o["@Name"], type: "integer",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Int64"
            { name: o["@Name"], type: "integer",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.SByte"
            { name: o["@Name"], type: "integer",
              control_type: "number",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.Time"
            { name: o["@Name"], type: "string",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          when "Edm.DateTimeOffset"
            { name: o["@Name"], type: "timestamp",
              control_type: "date_time",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          else
            { name: o["@Name"], type: "string",
              optional: optional,
              sticky: sticky,
              hint: description,
              label:  o["@label"].labelize }
          end
        end&.presence || [{}]
    end
  },

  actions: {
    search_object: {
      description: "Search <span class='provider'>objects</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "Search objects",

      config_fields: [
        { name: "object_name", control_type: :select,
          pick_list: :entity_set,
          label: "Object",
          hint: "Select object to search for",
          optional: false }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["object_filter"]
      end,

      execute: lambda do |connection, input|
        object_name = input.delete("object_name")
        error("Provide at least one search criteria") if !input.present?
        date_fields = call("date_fields", { object_name: object_name })
        filter_string = ""
        filter_params = []
        input.map do |key, val|
          if date_fields.include?(key)
            filter_params <<
              (key + " eq '" + "/Date(" + val + ")/" + "'") unless !val.present?
          else
            filter_params << (key + " eq '" + val + "'") unless !val.present?
          end
        end
        filter_string = filter_params.smart_join(" and ")
        objects = get("/odata/v2/" + object_name + "?$filter=" + filter_string).
          headers("Accept": "application/json",
            "Content-Type": "application/json").
          dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time.utc.iso8601 }
              else
                { key => value }
              end

            else
              { key => value }
            end
          end.inject(:merge)
        end
        {
          objects: final_objects
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array", of: "object",
            properties: object_definitions["object_output"] }
        ]
      end,

      sample_output: lambda do |_connection, input|
        date_fields = call(:date_fields, object_name: input["object_name"])
        objects = get("/odata/v2/" + input["object_name"]).
                  params("$top": 1).
                  dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time.utc.iso8601 }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        final_objects&.first || {}
      end
    },

    create_object: {
      description: "Create <span class='provider'>Object</span> in " \
      "<span class='provider'>SuccessFactors</span>",
      subtitle: "Create object in SuccessFactors",

      config_fields: [
        {
          name: "object_name", label: "Object",
          control_type: "select",
          pick_list: "entity_set_create",
          hint: "Select object",
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["object_create"]
      end,

      execute: lambda do |_connection, input|
        object_name = input.delete("object_name")
        # set empployee id on User creation
        if object_name == "User" && !input["empId"].present?
          employee_id = post("/odata/v2/generateNextPersonID?$format=json").
                        dig("d", "GenerateNextPersonIDResponse", "personID")
          input["empId"] = employee_id
        end
        date_fields = call("date_fields", object_name: object_name)
        payload = input.map do |key, value|
          if date_fields.include?(key)
            if value.present?
              date_time = value.to_time.utc.iso8601.to_i * 1000 unless
              value.blank?
              { key => "\/Date(" + date_time + ")\/" }
            else
              { key => value }
            end
          else
            { key => value }
          end
        end.inject(:merge)

        post("/odata/v2/" + object_name).
          headers("Accept": "application/json",
                  "Content-Type": "application/json").
          payload(payload).
          after_response do |_code, body, _header, _message|
            body.dig("d")
          end.after_error_response(404) do |_code, body, _header, message|
            error("#{message}: #{body}")
          end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        date_fields = call(:date_fields, object_name: input["object_name"])
        objects = get("/odata/v2/" + input["object_name"]).
                  params("$top": 1).
                  dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_date }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        final_objects&.first || {}
      end
    },

    update_object: {
      description: "Update <span class='provider'>object</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "Update object in SuccessFactors",
      help: "All property values in the Entity either take the values "\
      "provided in the request body or are reset to their default value"\
      " if no data is provided in the request",

      config_fields: [
        {
          name: "object_name", label: "Object",
          control_type: "select",
          pick_list: "entity_set_update",
          hint: "Select object",
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["object_update"]
      end,

      execute: lambda do |_connection, input|
        object_name = input.delete("object_name")
        key_column = call(:object_key, object_name: object_name)
        date_fields = call(:date_fields, object_name: object_name)
        payload = input.map do |key, value|
          if date_fields.include?(key)
            if value.present?
              date_time = value.to_time.utc.iso8601.to_i * 1000 unless
              value.blank?
              { key => "\/Date(" + date_time + ")\/" }
            else
              { key => value }
            end
          else
            { key => value }
          end
        end.inject(:merge)

        put("/odata/v2/" + object_name + "('" +
            input.delete(key_column) + "')").
          params("$format": "JSON").
          headers("Content-Type": "application/json;charset=utf-8").
          payload(payload).
          after_response do |_code, body, _header, _message|
            body
          end.after_error_response(500) do |_code, body, _header, message|
            error("#{message}: #{body}")
          end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        date_fields = call(:date_fields, object_name: input["object_name"])
        objects = get("/odata/v2/" + input["object_name"]).
                  params("$top": 1).
                  dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        final_objects&.first || {}
      end
    },

    merge_object: {
      description: "Merge <span class='provider'>object</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "Merge object in SuccessFactors",
      help: "Merge updates only the properties provided in the request"\
      " body, and leaves the data not mentioned in the request body in"\
      " its current state",

      config_fields: [
        {
          name: "object_name", label: "Object",
          control_type: "select",
          pick_list: "entity_set_update",
          hint: "Select object",
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["object_update"]
      end,

      execute: lambda do |_connection, input|
        object_name = input.delete("object_name")
        key_column = call(:object_key, object_name: object_name)
        date_fields = call(:date_fields, object_name: object_name)
        payload = input.map do |key, value|
          if date_fields.include?(key)
            if value.present?
              date_time = value.to_time.utc.iso8601.to_i * 1000 unless
              value.blank?
              { key => "\/Date(" + date_time + ")\/" }
            else
              { key => value }
            end
          else
            { key => value }
          end
        end.inject(:merge)

        post("/odata/v2/" + object_name + "('" +
            input.delete(key_column) + "')").
          params("$format": "JSON").
          headers("Content-Type": "application/json;charset=utf-8",
            "x-http-method": "MERGE").
          payload(payload).
          after_response do |_code, body, _header, _message|
            body
          end.after_error_response(500) do |_code, body, _header, message|
            error("#{message}: #{body}")
          end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        date_fields = call(:date_fields, object_name: input["object_name"])
        objects = get("/odata/v2/" + input["object_name"]).
                  params("$top": 1).
                  dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        final_objects&.first || {}
      end
    },

    upsert_object: {
      description: "Upsert <span class='provider'>object</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "Upsert object in SuccessFactors",
      help: "The server updates the Entity for which an external id already exists ",

      config_fields: [
        {
          name: "object_name", label: "Object",
          control_type: "select",
          pick_list: "entity_set_upsert",
          hint: "Select object",
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array",
            of: "object",
            properties: object_definitions["object_upsert"] }
        ]
      end,

      execute: lambda do |_connection, input|
        object_name = input.delete("object_name")
        key_column = call(:object_key, object_name: object_name)
        date_fields = call(:date_fields, object_name: object_name)
        payload = input["objects"].map do |obj| 
          obj.map do |key, value|
            if key.include?(key_column)
              {
                "__metadata": {
                  "uri": "User('" + obj.delete(key) + "')"
                }
              }
            elsif date_fields.include?(key)
              if value.present?
                date_time = value.to_time.utc.iso8601.to_i * 1000 unless
                value.blank?
                { key => "\/Date(" + date_time + ")\/" }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        objects = post("/odata/v2/upsert", payload).
          params("$format": "JSON").
          headers("Content-Type": "application/json;charset=utf-8").
          after_response do |_code, body, _header, _message|
            body.dig("d")
          end.after_error_response(500) do |_code, body, _header, message|
            error("#{message}: #{body}")
          end
          {
            objects: objects
          }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array", of: "object",
            properties: [
              { name: "key", label: "User ID" },
              { name: "status" },
              { name: "editStatus" },
              { name: "message", label: "Error message" },
              { name: "index", type: "integer" },
              { name: "httpCode", type: "integer" },
              { name: "inlineResults" }
            ] }
        ]
      end,
      
      sample_output: lambda do
        {
          key: "31917",
          status: "OK",
          editStatus: "UPDATED",
          message: "Error message",
          index: "1",
          httpCode: "204",
          inlineResults: ""
        }
      end
    },
    
    get_option_labels_by_optionid: {
      description: "Get <span class='provider'>Option labels</span>  " \
        "<span class='provider'> by Option Id</span>",
      subtitle: "Get option label's by optionid",
      input_fields: lambda do |_|
        [
          { name: "optionid", label: "Option id",
            optional: false }
        ]
      end,
      execute: lambda do |connection, input|
        {
          option_labels: get("/odata/v2/PicklistOption(" +
              input["optionid"] + ")/picklistLabels").
          params("$format": "json").dig("d", "results")
        }
      end,
      output_fields: lambda do |object_definitions|
        [
          { name: "option_labels", type: "array", of: "object",
            properties: object_definitions["option_labels"] }
        ]
      end,
      sample_output: lambda do
        {
          optionId: "31917",
          locale: "en_US",
          id: "564749",
          label: "Low"
        }
      end
    }

  },

  triggers: {
    new_updated_object: {
      title: "New/Updated object",
      description: "New/Updated <span class='provider'>object</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "New/Updated object",

      config_fields: [
        { name: "object_name", control_type: :select,
          pick_list: "entity_set",
          label: "Object Name",
          hint: "Select object",
          optional: false,
          toggle_hint: "Select Entityset",
          toggle_field:
            { name: "object_name",
              type: "string",
              control_type: "text",
              label: "Object API name",
              toggle_hint: "Use Entityset name",
              hint: "EntitySet Internal name" } }
      ],

      input_fields: lambda do
        [
          { name: "since", type: "date_time",
            sticky: true,
            label: "From",
            hint: "Fetch objects from specified time" }
        ]
      end,

      poll: lambda do |_connection, input, last_updated_since|
        object_name = input.delete("object_name")
        key_column = call(:object_key, object_name: object_name)
        date_fields = call(:date_fields, object_name: object_name)
        last_updated_since ||= (input["since"].presence || 1.hour.ago).
                               to_time.utc.iso8601
        objects = get("/odata/v2/" + object_name).
          params("$filter": "lastModifiedDateTime gt datetimeoffset'" +
           last_updated_since + "'",
            "$orderby": "lastModifiedDateTime asc").
          headers("Accept": "application/json",
            "Content-Type": "application/json").
          dig("d", "results")

        # add custom column for dedup, timestamp conversion
        final_objects = objects.map do |obj|
          obj["object_id"] = obj[key_column] + "-" +
           obj["lastModifiedDateTime"].scan(/\d+/)[0].to_s
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time }
              else
                { key => value }
              end
            else
              { key => value }
            end
          end.inject(:merge)
        end
        last_updated_since = final_objects.last["lastModifiedDateTime"] unless
        final_objects.size == 0

        {
          events: final_objects,
          next_poll: last_updated_since,
          can_poll_more: objects.size > 0
        }
      end,

      dedup: lambda do |object|
        object["object_id"]
      end,

      output_fields: lambda do |object_defintions|
        object_defintions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        date_fields = call(:date_fields, object_name: input["object_name"])
        objects = get("/odata/v2/" + input["object_name"]).params("$top": 1).
          dig("d", "results")
        final_objects = objects.map do |obj|
          obj.map do |key, value|
            if date_fields.include?(key)
              if value.present?
                date_time = value.scan(/\d+/)[0] unless value.blank?
                { key => (date_time.to_i / 1000).to_i.to_time }
              else
                { key => value }
              end

            else
              { key => value }
            end
          end.inject(:merge)
        end
        final_objects&.first || {}
      end
    }
  },

  pick_lists: {
    entity_set: lambda do
      get("/odata/v2/$metadata").response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 0,
            "EntityContainer", 0, "EntitySet").map do |obj|
        [obj["@label"], obj["@Name"]]
      end
    end,
    
    entity_set_create: lambda do
      get("/odata/v2/$metadata").response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 0,
            "EntityContainer", 0, "EntitySet").
        select { |field| field["@creatable"] == "true" }.map do |obj|
        [obj["@label"], obj["@Name"]]
      end
    end,
    
    entity_set_update: lambda do
      get("/odata/v2/$metadata").response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 0,
            "EntityContainer", 0, "EntitySet").
        select { |field| field["@updatable"] == "true" }.map do |obj|
        [obj["@label"], obj["@Name"]]
      end
    end,
    entity_set_upsert: lambda do
      get("/odata/v2/$metadata").response_format_xml.
        dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 0,
            "EntityContainer", 0, "EntitySet").
        select { |field| field["@upsertable"] == "true" }.map do |obj|
        [obj["@label"], obj["@Name"]]
      end
    end
  }
}

