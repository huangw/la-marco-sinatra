# [Class] OrderedList
#   (lib/mongoid/ordered_list.rb)
# vi: foldlevel=1
# created at: 2015-09-22
require 'active_support/concern'
require 'securerandom'
require 'forwardable'

# Mix-in Mongoid namespace
module Mongoid
  # Array fields with user modifiable order
  module OrderedList
    # implement save/retrieve methods
    class Proxy
      include Enumerable
      attr_reader :parent, :field_name

      def initialize(prt, fnm)
        @parent = prt
        @field_name = fnm
      end

      # Array access
      # ---------------
      # The raw array of hashes saved into the parent mongoid document
      def raw_field
        parent.send(@field_name)
      end

      # Load parent's field as a array of objects, nil field converts to
      # empty array. Use `decode` to convert hash to object
      def olist
        @olist ||= raw_field.blank? ? [] : raw_field.map { |h| decode(h) }
      end

      def flush
        parent.send "#{@field_name}=".to_sym,
                    olist.empty? ? nil : olist.map { |o| encode(o) }
      end

      # find the raw Hash block from the tid
      def raw_block(tid)
        return nil if raw_field.blank? # nil or empty
        return raw_field[tid] if tid.is_a?(Integer)
        # Array#find returns the first element meets the given condition
        raw_field.find { |h| h['tid'] == tid }
      end

      # Get a block from #olist with the given tid
      def block(tid)
        olist[offset(tid)]
      end
      alias [] block

      # Encode and Decode
      # --------------------------------------
      # These two methods are intended to be overloaded by child classes
      # Restore from hash to object, used by first time `olist` is called
      def decode(hsh)
        klass = hsh['_type'] || raise('unknown data type')
        Object.const_get(klass.to_s).from_hash(hsh)
      end

      # Encode object to hash. If object do not respond to tid, can assign
      # the preferred id as the second parameter
      def encode(obj)
        obj.is_a?(Hash) ? obj : obj.to_hash
      end

      def on_add(obj, tid = nil)
        obj.tid = unique_tid(tid || obj.tid) # determine the unique tid
        obj
      end

      def on_remove(obj) # add cleanup method on child classes
      end

      # Anchor id (tid) management
      # ----------------------------
      def tid_length
        3
      end

      def unique_tid(tid = nil)
        tid = SecureRandom.hex(tid_length) if tid.blank?
        while olist.map(&:tid).include?(tid)
          tid = tid.sub(/\.\w+\Z/, '') + '.' + SecureRandom.hex(1)
        end
        tid
      end

      # Modification mehtods
      # ----------------------
      # Add an object or an hash into th ordered list. Valid options are:
      # - `after: tid`: append after tid
      # - `append: true`: append to the list as the last block
      #
      # Note: do not use `append` option if you specified `after`
      def add(obj, opts = {})
        opts.symbolize_keys!
        obj = on_add(obj, opts[:tid]) # encode object into Hash structure
        raise 'do not use append with after' if opts[:after] && opts[:append]
        # raise "tid #{hsh['tid']} already exists" # TODO: if exists?

        offset = opts[:append] ? olist.size : offset_after(opts[:after])
        olist.insert offset, obj
        flush && obj.tid
      end
      alias insert add

      def <<(obj, opts = {})
        add(obj, opts.symbolize_keys.merge(append: true))
      end
      alias append <<

      # Moves an existing block by tid, after other tid. If after not defined
      # move the block to the head of the array. Options are:
      # - `after: tid`: append after tid
      # - `append: true`: append to the list as the last block
      def move(tid, opts = {})
        opts.symbolize_keys!
        raise 'do not use append with after' if opts[:after] && opts[:append]

        return if opts[:after] == tid
        keep = olist.delete_at(offset(tid))
        offset = opts[:append] ? olist.size : offset_after(opts[:after])
        raise "invalid after tid: #{tid}" unless offset
        olist.insert(offset, keep)
      end

      # Remove block from the list, but keep in the relationship
      def remove(tid)
        obj = block(tid)
        olist.delete_if { |o| o.tid == tid }
        flush
        on_remove(obj)
      end

      def change_order(tids)
        raise 'tids size not match blist size' unless tids.size == olist.size
        nlist = tids.map { |tid| block(tid) }
        @olist = nlist
        flush
      end

      # blist contains is map(&:to_hash)
      def to_hash
        flush || {}
      end

      def from_hash(ary)
        ary.each { |h| append(decode(h)) }
      end

      # Implements Enumerable methods
      # ------------------------------
      extend Forwardable
      def_delegators :olist, :each, :first, :last, :size, :count

      private

      # find the next offset after tid, 0 if tid not exits
      def offset_after(tid = nil)
        return 0 unless tid
        offset(tid) + 1
      end

      def offset(tid)
        idx = tid.is_a?(Integer) ? tid : olist.find_index { |o| o.tid == tid }
        raise("invalid tid: #{tid}") unless idx
        raise("invalid offset #{tid}") if idx >= olist.size
        idx
      end
    end # class Proxy

    extend ActiveSupport::Concern
    included do
      # set a proxy method `name` as the ordered list
      # rubocop:disable MethodLength,LineLength
      def self.ordered_list(field_name, opts = {})
        proxy_name = opts.delete(:as)
        proxy_klass = opts.delete(:proxy) || ::Mongoid::OrderedList::Proxy
        raise 'you should define :as for proxy name' unless proxy_name
        raise 'field name must differ to :as' if proxy_name == field_name

        field field_name, opts.merge(type: Array)

        # Return the proxy object to handle ordered list operations
        send(:define_method, proxy_name.to_sym) do
          instance_variable_get("@#{proxy_name}".to_sym) || instance_variable_set("@#{proxy_name}".to_sym, proxy_klass.new(self, field_name.to_sym))
        end

        send(:define_method, "#{proxy_name}=".to_sym) do |arry|
          self[field_name.to_sym] = nil
          arry.each { |e| send(proxy_name.to_sym).append(e) }
        end

        # flush back in memory list back to hash raw list
        before_save do
          send(proxy_name.to_sym).flush
        end
      end
    end # included
  end # ordered list
end
