require 'sequel'

Sequel.migration do
  up do
    add_column(:cached_requests, :created_at, Time)
    from(:cached_requests).update(created_at: Time.now)
    alter_table(:cached_requests) do
      set_column_not_null :created_at
    end
  end
end
