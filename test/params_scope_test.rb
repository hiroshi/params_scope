require 'test_helper'

class Thing < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3', :database => ":memory:"

  named_scope :foo, lambda {|foo| {:conditions => {:foo => foo}}}
  named_order_scope :order
end

class ParamsScopeTest < ActiveSupport::TestCase
  test "params_scope" do
    params = {:foo => "foo", :bar => 1} # bar should be ignored
    sql = Thing.params_scope(params).send(:construct_finder_sql, {})
    assert_equal "SELECT * FROM \"things\" WHERE (\"things\".\"foo\" = 'foo') ", sql
  end

  test "named_order_scope" do
    params = {:order => ["updated_at", "desc", "id", "asc"]}
    sql = Thing.params_scope(params).send(:construct_finder_sql, {})
    assert_equal "SELECT * FROM \"things\"  ORDER BY things.updated_at DESC, things.id ASC", sql

#     params = {:order => [:order_by_bar, :order_by_foo]}
#     sql = Thing.params_scope(params).send(:construct_finder_sql, {})
#     assert_equal "SELECT * FROM \"things\" ORDER BY bar, foo", sql
  end
end
