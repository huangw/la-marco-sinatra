# [Class] Paginator (lib/mongoid/paginator.rb)
# vim: foldlevel=1
# created at: 2015-01-29
require 'active_support/concern'

# mixin into mongoid
# rubocop:disable LineLength, MethodLength
module Mongoid
  # add paginate function to mongoid
  class Criteria
    # Return a hash, include pager information hash and
    # criteria with skip and limit set.
    #
    # #paginate can (while #page can not) receive page number like
    # -1 for backward indexing.
    def paginate(pg = 1, opts = {})
      opts[:count] = count
      opts[:per_page] ||= 20

      opts[:total_pages], rmdr = opts[:count].divmod(opts[:per_page].to_i)
      opts[:total_pages] += 1 if rmdr > 0

      opts[:current_page] = pg.to_i > opts[:total_pages] ? opts[:total_pages] : pg.to_i
      opts[:current_page] = opts[:total_pages] + opts[:current_page] + 1 if opts[:current_page] < 0 # for zero or negative (backward) index
      opts[:current_page] = 1 if opts[:current_page] < 1
      opts[:criteria] = page(opts[:current_page], opts)

      rdo = (opts[:count] - opts[:skip]).to_i
      opts[:ipp] = rdo > opts[:per_page].to_i ? opts[:per_page].to_i : rdo

      opts
    end

    # Return a criteria with skip and limit set
    # Use this method like:
    #
    #    SomeObject.where(name: 'something').page(2, per_page: 10)
    def page(pg = 1, opts = {})
      opts[:per_page] ||= 20
      opts[:skip] = (pg.to_i - 1) * opts[:per_page].to_i
      skip(opts[:skip]).limit(opts[:per_page])
    end
  end
end
