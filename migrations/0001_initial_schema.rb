require 'sequel'

Sequel.migration do
  up do
    create_table(:cached_requests) do
      primary_key :id

      String :path, null: false
      String :params_hash, null: false
      String :auth, null: false
      String :response_body, null: false

      index [:path, :params_hash], unique: true
    end
  end

  down do
    drop_table(:cached_requests)
  end
end

