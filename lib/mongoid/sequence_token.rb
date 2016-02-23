# [Class] SequenceToken (lib/mongoid/sequence_token.rb)
# vim: foldlevel=1
# created at: 2015-05-08
require 'active_support/concern'

# Sequence keeper for each model
class Sequence
  include Mongoid::Document
  store_in collection: '__sequence'

  field :name, type: String # this should be a collection name
  field :seq, type: Integer, default: 10_000
end

# Mixin Mongoid
module Mongoid
  # Sequential id token support
  module SequenceToken
    extend ActiveSupport::Concern

    included do
      field :sid, type: String
      index({ sid: 1 }, unique: true)

      def self.seq_field
        "#{collection.name}_sid"
      end

      # initialize the sequence field
      Sequence.find_or_create_by(name: seq_field)

      set_callback :save, :before, :set_sequence_token, unless: :persisted?
      def set_sequence_token
        nseq = Sequence.where(name: self.class.seq_field).find_one_and_update(
          { '$inc' => { seq: 1 } }, return_document: :after)
        self.sid = nseq.seq.to_s(36).reverse
      end

      def sequence_id
        sid && sid.reverse.to_i(36)
      end

      def self.s_find(str)
        where(sid: str).last || raise('not_found')
      end
    end # included
  end
end
