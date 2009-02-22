require 'test_helper'

class Thing < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3', :database => ":memory:"

  named_scope :foo, lambda {|foo| {:conditions => {:foo => foo}}}
end

class ParamsScopeTest < ActiveSupport::TestCase
  test "params_scope" do
    params = {:foo => "foo", :bar => 1}
    sql = Thing.params_scope(params).send(:construct_finder_sql, {})
    assert_equal "SELECT * FROM \"things\" WHERE (\"things\".\"foo\" = 'foo') ", sql
  end
end
