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
    # optins:
    #  defaults: specify default value for keys if there are no value for the keys
    def params_scope(params, options={})
      params = params.symbolize_keys.reverse_merge(options[:defaults] || {})
      self.scopes.keys.inject(self) do |ret, scope_name|
        if (value = params[scope_name]) && !value.blank?
          ret.send(scope_name, *value)
        else
          ret
        end
      end
    end
  end
end
