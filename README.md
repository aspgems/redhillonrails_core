= Disclaimer

redhillonrails_core was originally created by http://github.com/harukizaemon but it was retired and is no longer supported.

That fork is intended to make redhillonrails_core compatible with edge rails and introduce some new features.

= RedHill on Rails Core

Goal of redhillonrails_core is to provided missing ActiveRecord support for database specific features:

* foreign_keys
* case-insensitive and partial indexes (pgsql only)
* views

== Installation

As a gem

  gem install aspgems-redhillonrails_core

== Compatibility

* Ruby - 1.8, 1.9
* ActiveRecord - 2.X, 3.X
* Databases - PostgreSQL, MySQL, SQLite3 (most features should also run on others)

=== Foreign Key Support

The plugin provides two mechanisms for adding foreign keys as well as
preserving foreign keys when performing a schema dump. (Using SQL-92 syntax and
as such should be compatible with most databases that support foreign-key
constraints.)

The first mechanism for creating foreign-keys allows you to add a foreign key
when defining a table. For example:

```ruby
  create_table :orders do |t|
    ...
    t.foreign_key :customer_id, :customers, :id
  end
```

You also have the option of specifying what to do on delete/update using
<code>:on_delete</code>/<code>:on_update</code>, respectively to one of: <code>:cascade</code>; <code>:restrict</code>; and <code>:set_null</code>:

```ruby
  create_table :orders do |t|
    ...
    t.foreign_key :customer_id, :customers, :id, :on_delete => :set_null, :on_update => :cascade
  end
```

The second method allows you to create arbitrary foreign-keys at any time:

```ruby
  add_foreign_key(:orders, :customer_id, :customers, :id, :on_delete => :set_null, :on_update => :cascade)
```

In either case, if your database supports deferred foreign keys (for example PostgreSQL) you can specify this as well:

```ruby
  t.foreign_key :customer_id, :customers, :id, :deferrable => true
  add_foreign_key(:orders, :customer_id, :customers, :id, :deferrable => true)
```

By default, the foreign key will be assigned a name by the underlying database. However, if this doesn't suit
your needs, you can override the default assignment using the <code>:name</code> option:

```ruby
  add_foreign_key(:orders, :customer_id, :customers, :id, :on_delete => :set_null, :on_update => :cascade, <strong>:name => :orders_customer_id_foreign_key<strong>)
```

You can also query the foreign keys for a model yourself by calling <code>foreign_keys()</code>:

```ruby
  Order.foreign_keys
```

Or for an arbitrary table by calling <code>foreign_keys(table_name)</code> on a database adapter.

Either method returns an array of the following meta-data:

* +name+ - The name of the foreign key constraint;
* +table_name+ - The table for which the foreign-key was generated;
* +column_names+ - The column names in the table;
* +references_table_name+ - The table referenced by the foreign-key; and
* +references_column_names+ - The columns names in the referenced table.

If you need to drop a foreign-key, use:

```ruby
  remove_foreign_key :orders, :orders_ordered_by_id_fkey
```

The plugin also ensures that all foreign keys are output when performing a
schema dump. This happens automatically when running <code>rake migrate</code> or
<code>rake db:schema:dump</code>. This has particular implications when running
unit tests that contain fixtures. To ensure the test data is correctly reset after
each test, you should list your fixtures in order of parent->child. For example:

```ruby
  fixtures :customers, :products, :orders, :order_lines
```

Rails will then set-up and tear-down the fixtures in the correct sequence.

Some databases (PostgreSQL and MySQL for example) allow you to set a comment for a
table. You can do this for existing tables by using:

```ruby
  set_table_comment :orders, "All pending and processed orders"
```

or even at the time of creation:

```ruby
  create_table :orders, :comment => "All pending and processed orders" do |t|
    ...
  end
```

You can clear table comments using:

```ruby
  clear_table_comment :orders
```

There is also a rake tasks to show all database tables and their comments:

  rake db:comments

The plugin fully supports and understands the following active-record
configuration properties:

* <code>config.active_record.pluralize_table_names</code>
* <code>config.active_record.table_name_prefix</code>
* <code>config.active_record.table_name_suffix</code>

=== View Support

The plugin provides a mechanism for creating and dropping views as well as
preserving views when performing a schema dump:

```ruby
  create_view :normal_customers, "SELECT * FROM customers WHERE status = 'normal'"
  drop_view :normal_customers
```

=== Model Indexes

ActiveRecord::Base already provides a method on connection for obtaining the
indexes for a given table. This plugin now makes it possible to obtain the
indexes for a given model--<code>ActiveRecord::Base</code>--class. For example:

```ruby
  Invoice.indexes
```

Would return all the indexes for the +invoices+ table.

=== Schema Defining

The plugin also adds a method--<code>defining?()</code>--to
<code>ActiveRecord::Schema</code> to indicate when <code>define()</code> is running. This is necessary
as some migration plugins must change their behaviour accordingly.

=== Case-insensitive Indexes

For PostgreSQL, you can add an option <code>:case_sensitive => false</code> to <code>add_index</code>
which will generate an expression index of the form:

  LOWER(column_name)

This means finder queries of the form:

  WHERE LOWER(column_name) = LOWER(?)

are able to use the indexes rather require, in the worst case, full-table scans.

Note also that this ties in well with Rails built-in support for case-insensitive searching:

```ruby
  validates_uniqueness_of :name, :case_sensitive => false
```

=== See Also

* Foreign Key Migrations (foreign_key_migrations)
