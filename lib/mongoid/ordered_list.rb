# [Class] OrderedList
#   (lib/mongoid/ordered_list.rb)
# vi: foldlevel=1
# created at: 2015-09-22
require 'active_support/concern'
require 'securerandom'

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

      # The raw array of hashes saved into the parent mongoid document
      def blist
        parent.send(@field_name) || []
      end

      # Reuturn { tid => block_hash } hash
      def blist_hash
        blist.each_with_object({}) { |a, rslt| rslt[a['tid']] = a }
      end

      # Get the block (as hash) from tid
      def block(tid)
        blist.find { |h| h['tid'] == tid }
      end
      alias :"tid_exists?" block

      # Get a block from #block and convert into object use #decode
      def [](tid)
        tid = blist[tid]['tid'] if tid.is_a?(Integer)
        blk = block(tid)
        return nil unless blk
        obj = decode(blk)
        obj.parent = parent if obj.respond_to?(:'parent=')
        obj
      end

      def each
        blist.each { |blk| yield decode(blk) }
      end

      def last
        decode blist.last
      end

      def size
        blist.size
      end
      alias count size

      # Modification mehtods
      # ----------------------
      # Add an object or an hash into th ordered list. Valid options are:
      # - `after: tid`: append after tid
      # - `append: true`: append to the list as the last block
      #
      # Note: do not use `append` option if you specified `after`
      # rubocop:disable CyclomaticComplexity
      def add(obj, opts = {})
        hsh = encode(obj) # encode object into Hash structure

        opts.symbolize_keys!
        raise 'tid already exists' if hsh['tid'] && tid_exists?(hsh['tid'])
        raise 'do not use append with after' if opts[:after] && opts[:append]
        # initialize field with [] if it still nil
        parent.send("#{@field_name}=", []) unless parent.send(@field_name)

        offset = opts[:append] ? blist.size : offset_after(opts[:after])
        blist.insert offset, hsh
        hsh['tid']
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
        keep = block(tid)
        raise "invalid tid: #{tid}" unless keep
        return false if tid == opts[:after]
        remove(tid)
        offset = offset_after(opts[:after])
        opts[:append] ? append(keep) : blist.insert(offset, keep)
      end

      # Remove block from the list, but keep in the relationship
      def remove(tid)
        blist.delete_if { |b| b['tid'] == tid }
      end

      # Partially update the already existing block hash
      def update(tid, obj)
        hsh = obj.is_a?(Hash) ? obj.dup : encode(obj, tid)
        blist[offset_after(tid) - 1].merge!(hsh)
      end

      def change_order(tids)
        bh = blist_hash
        raise 'tids size not match blist size' unless tids.size == bh.keys.size
        tids.each { |tid| raise "invalid tid: #{tid}" unless bh[tid] }
        parent.send "#{field_name}=".to_sym, tids.map { |id| bh[id] }
      end

      # blist contains is map(&:to_hash)
      def to_hash
        blist
      end

      # Method for overloading by child class
      # --------------------------------------
      # Restore from hash to object
      def decode(hsh)
        # if symbol, get from relationship, then call from_hash
        klass = hsh['_type'] || raise('unknown data type')
        Object.const_get(klass.to_s).from_hash(hsh)
      end

      # Encode object to hash
      def encode(obj, tid = nil)
        obj.parent = parent if obj.respond_to?(:'parent=')
        hsh = obj.is_a?(Hash) ? obj.dup : obj.to_hash
        hsh['tid'] = unique_tid(hsh['tid'] || tid)
        obj.tid = hsh['tid'] if obj.respond_to?(:'tid=')
        hsh
      end

      def tid_length
        3
      end

      def unique_tid(tid = nil)
        id_ = tid || SecureRandom.hex(tid_length)
        while blist.map { |h| h['tid'] }.include?(id_)
          srhex = SecureRandom.hex(tid_length)
          id_ = tid.blank? ? srhex : tid + '.' + srhex
        end
        id_
      end

      private

      # find the next offset after tid, 0 if tid not exits
      def offset_after(tid = nil)
        return 0 unless tid
        offset = nil
        blist.each_with_index { |b, i| offset = i + 1 if b['tid'] == tid }
        offset || raise("invalid tid: #{tid}")
      end
    end # class Proxy

    extend ActiveSupport::Concern
    included do
      # set a proxy method `name` as the ordered list
      # rubocop:disable MethodLength,LineLength
      def self.ordered_list(field_name, opts = {})
        proxy_name = opts.delete(:as)
        proxy_klass = opts.delete(:proxy) || Proxy
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
      end
    end # included
  end # ordered list
end
