# [Class] TokenId (lib/mongoid/token_id.rb)
# vim: foldlevel=1
# created at: 2015-01-29
require 'active_support/concern'

# Mixin BSON module
module BSON
  # Mixin Object id, add token id generator and de-serialize
  class ObjectId
    def to_token_id
      id = to_s.to_i(16).to_s(36)
      id[9..-1] + id[0..8]
    end

    def self.from_token_id(str)
      from_string((str[-9..-1] + str[0..-10]).to_i(36).to_s(16))
    end

    def to_splits
      tid = to_token_id
      [tid[0..4], tid[5..9], tid[10..-1]]
    end

    def self.from_splits(tm, mp, remain)
      from_token_id([tm, mp, remain].join)
    end
  end
end

# Mixin Mongoid module
module Mongoid
  # Create a shorter 19 digits representer of object id,
  # based on radix
  module TokenId
    extend ActiveSupport::Concern

    included do
      def token_id
        _id.to_token_id
      end

      def token_id=(str)
        self._id = BSON::ObjectId.from_token_id(str)
      end

      alias_method :tid, :token_id
      alias_method :tid=, :token_id=

      def self.t2id(str)
        BSON::ObjectId.from_token_id(str)
      end

      def self.t_find(tid)
        find(t2id(tid))
      end

      def self.by_tid(tid)
        where(_id: t2id(tid))
      end
    end
  end
end
