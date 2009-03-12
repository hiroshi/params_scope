# Chaining up named scopes with the params hash.
# Usage example: 
#   class User < ActiveRecord::Base
#     named_scope :age, lambda{|age| {:conditions => ["age = ?", age]}}
#     named_scope :city, lambda{|city| {:conditions => ["city = ?", city]}}
#     named_scope :closed, lambda{|closed| {:conditions => ["closed = ?", closed]}}
#   end
# 
#   class UsersController < ApplicationController
#     def index
#       # params may be {:age => 30, :city => "Tokyo"}
#       @users = User.params_scope(params).find(:all, :defaults => {:closed => false})
#       # => User.closed(false).closed(false).age(30).city("Tokyo").find(:all)

module ParamsScope
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Defines a named_scope to deal with a param like that :order => ["updated_at", "desc", "id", "asc"].
    # You can use this with like following view:
    #   <%= select_tag "order[]", options_for_select([:id, :updated_at]) %>
    #   <%= select_tag "order[]", options_for_select([:asc, :desc]) %><br/>
    #   <%= select_tag "order[]", options_for_select([:id, :updated_at]) %>
    #   <%= select_tag "order[]", options_for_select([:asc, :desc]) %>
    def named_order_scope(name)
      named_scope name, lambda {|orders|
        {
          :order => orders.in_groups_of(2).map do |key, order|
            case order
            when /asc/i
              "#{self.table_name}.#{key} ASC"
            when /desc/i
              "#{self.table_name}.#{key} DESC"
            end
          end.join(", ")
        }
      }
    end

    # optins:
    #  defaults: specify default value for keys if there are no value for the keys
    def params_scope(params, options={})
      params = params.symbolize_keys.reverse_merge(options[:defaults] || {})
      # chaining params scopes
      self.scopes.keys.inject(self) do |ret, scope_name|
        if (value = params[scope_name]) && !value.blank?
          ret.send(scope_name, value)
        else
          ret
        end
      end
    end
  end
end
