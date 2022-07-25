Role.destroy_all
Role.create!([
  id: 1,
  name: 'admin'
])

ActiveRecord::Base.connection.reset_pk_sequence!('roles')