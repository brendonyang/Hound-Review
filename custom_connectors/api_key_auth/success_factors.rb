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
        user("#{connection['username']}@#{connection['company']}")
        password("#{connection['password']}")
      end
    },

    base_uri: lambda do |connection|
      "#{connection['endpoint']}"
    end
  },

  object_definitions: {
    object_output: {
      fields: lambda do |_connection, config|
        columns = get("/odata/v2/#{config['object_name']}/$metadata").
                  response_format_xml.
                  dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
                    "EntityType", 0, "Property").
                  select { |field| field["@visible"] == "true" }.
                  map do |o|
                    case o["@Type"]
                    when "Edm.String"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Boolean"
                      { name: o["@Name"], type: "boolean",
                        control_type: "checkbox",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Byte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTime"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Decimal"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Double"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Single"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Guid"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int16"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int32"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int64"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.SByte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Time"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTimeOffset"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    else
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    end
                  end
        columns
      end
    },

    object_create: {
      fields: lambda do |_connection, config|
        columns = get("/odata/v2/#{config['object_name']}/$metadata").
                  response_format_xml.
                  dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
                    "EntityType", 0, "Property").
                  select { |field| field["@creatable"] == "true" }.
                  map do |o|
                    case o["@Type"]
                    when "Edm.String"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Boolean"
                      { name: o["@Name"], type: "boolean",
                        control_type: "checkbox",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Byte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTime"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Decimal"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Double"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Single"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Guid"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int16"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int32"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int64"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.SByte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Time"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTimeOffset"
                      { name: o["@Name"], type: "timestamp",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    else
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    end
                  end
        columns
      end
    },

    object_update: {
      fields: lambda do |_connection, config|
        key_column = call(:object_key, {object_name: config['object_name']})
        columns = get("/odata/v2/#{config['object_name']}/$metadata").
                  response_format_xml.
                  dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
                    "EntityType", 0, "Property").
                  select{ |field| field["@updatable"] == "true" }.
                  map do |o|
                    optional =
                      if o["@Name"] == key_column
                        false
                      else
                        o["@required"].include?("false")
                      end
                    case o["@Type"]
                    when "Edm.String"
                      { name: o["@Name"], type: "string",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Boolean"
                      { name: o["@Name"], type: "boolean",
                        control_type: "checkbox",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Byte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.DateTime"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        optional: optional,
                        label:  o["@label"].labelize}
                    when "Edm.Decimal"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Double"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Single"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Guid"
                      { name: o["@Name"], type: "string",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Int16"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Int32"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Int64"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.SByte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.Time"
                      { name: o["@Name"], type: "string",
                        optional: optional,
                        label:  o["@label"].labelize }
                    when "Edm.DateTimeOffset"
                      { name: o["@Name"], type: "timestamp",
                        control_type: "date_time",
                        optional: optional,
                        label:  o["@label"].labelize }
                    else
                      { name: o["@Name"], type: "string",
                        optional: optional,
                        label:  o["@label"].labelize }
                    end
                  end
        columns
      end
    },

    object_upsert: {
      fields: lambda do |_connection, config|
        columns = get("/odata/v2/#{config['object_name']}/$metadata").
                  response_format_xml.
                  dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
                    "EntityType", 0, "Property").
                  select { |field| field["@upsertable"] == "true" }.
                  map do |o|
                    case o["@Type"]
                    when "Edm.String"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Boolean"
                      { name: o["@Name"], type: "boolean",
                        control_type: "checkbox",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Byte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTime"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Decimal"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Double"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Single"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Guid"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int16"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int32"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Int64"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.SByte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.Time"
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    when "Edm.DateTimeOffset"
                      { name: o["@Name"], type: "timestamp",
                        control_type: "date_time",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    else
                      { name: o["@Name"], type: "string",
                        optional: o["@required"].include?("false"),
                        label:  o["@label"].labelize }
                    end
                  end
        columns
      end
    },

    object_filter: {
      fields: lambda do |_connection, config|
        columns = get("/odata/v2/#{config['object_name']}/$metadata").
                  response_format_xml.
                  dig("edmx:Edmx", 0, "edmx:DataServices", 0, "Schema", 1,
                    "EntityType", 0, "Property").
                  select { |field| field["@filterable"] == "true" }.
                  map do |o|
                    case o["@Type"]
                    when "Edm.String"
                      { name: o["@Name"], type: "string",
                        label:  o["@label"].labelize }
                    when "Edm.Boolean"
                      { name: o["@Name"], type: "boolean",
                        control_type: "checkbox",
                        label:  o["@label"].labelize }
                    when "Edm.Byte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.DateTime"
                      { name: o["@Name"], type: "date_time",
                        control_type: "date_time",
                        parse_output: "",
                        label:  o["@label"].labelize }
                    when "Edm.Decimal"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Double"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Single"
                      { name: o["@Name"], type: "number",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Guid"
                      { name: o["@Name"], type: "string",
                        label:  o["@label"].labelize }
                    when "Edm.Int16"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Int32"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Int64"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.SByte"
                      { name: o["@Name"], type: "integer",
                        control_type: "number",
                        label:  o["@label"].labelize }
                    when "Edm.Time"
                      { name: o["@Name"], type: "string",
                        label:  o["@label"].labelize }
                    when "Edm.DateTimeOffset"
                      { name: o["@Name"], type: "timestamp",
                        control_type: "date_time",
                        label:  o["@label"].labelize }
                    else
                      { name: o["@Name"], type: "string",
                        label:  o["@label"].labelize }
                    end
                  end
        columns
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
        error("Provide at least one search criteria") if input.blank?
        date_fields = call("date_fields", { object_name: object_name })
        filter_string = ""
        filter_params = []
        input.map do |key, val|
          if date_fields.include?(key)
            filter_params <<
              (key + " eq '" + "/Date(" + val + ")/" + "'") unless val.blank?
          else
            filter_params << (key + " eq '" + val + "'") unless val.blank?
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
              if !value.blank?
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
              if !value.blank?
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
          pick_list: "entity_set",
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
        if object_name == "User" && input["empId"].blank?
          employee_id = post("/odata/v2/generateNextPersonID?$format=json").
                        dig("d", "GenerateNextPersonIDResponse", "personID")
          input["empId"] = employee_id
        end
        date_fields = call("date_fields", object_name: object_name)
        payload = input.map do |key, value|
          if date_fields.include?(key)
            if !value.blank?
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
              if !value.blank?
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

    update_object: {
      description: "Update <span class='provider'>object</span> in " \
        "<span class='provider'>SuccessFactors</span>",
      subtitle: "Update object in SuccessFactors",
      help: "Merges only data fields which are passed in input",

      config_fields: [
        {
          name: "object_name", label: "Object",
          control_type: "select",
          pick_list: "entity_set",
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
            if !value.blank?
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
              if !value.blank?
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
              if !value.blank?
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
              if !value.blank?
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
    end
  }
}
