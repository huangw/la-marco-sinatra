# encoding: utf-8
# Brought from: https://github.com/playround/rspec_api_blueprint
unless ''.respond_to?(:indent)
  class String
    def indent(count, char = ' ')
      gsub(/([^\n]*)(\n|$)/) do |_match|
        last_iteration = (Regexp.last_match[1] == '' && Regexp.last_match[2] == '')
        line = ''
        line << (char * count) unless last_iteration
        line << Regexp.last_match[1]
        line << Regexp.last_match[2]
        line
      end
    end
  end
end

# Hold request / response body from rspec rack test results
class RSpecApiDoc
  class << self
    def examples(key = nil)
      @examples ||= {} # example name => { req => rsp, ... }
      return @examples[key.to_s] ||= ''  if key
      @examples
    end

    def req_uris(key)
      @req_uris ||= {}
      @req_uris[key.to_s] ||= []
    end

    def get_binding
      binding
    end

    # create a factory girl model mock and dump as pretty JSON string
    def model(*args)
      jhash create(*args).to_hash
    end

    def jhash(hsh)
      JSON.pretty_generate(hsh).indent(4)
    end

    # `@examples` is an hash of `:req => :rsp` for a specific url endpoint
    # example_for dumps them in format of api-blue-print:
    #
    #     + Request _description_in_`it`_
    #
    #         + Headers
    #
    #              ...
    #
    #     + Response CODE (application/json)
    #
    #          + Headers
    #
    #               ....
    #
    #          + Body
    #
    #               ....
    def example_for(key)
      # format("# %s\n\n%s", key, examples(key))
      examples(key)
    end

    # example with resource heading
    def resource_for(key)
      format("# %s\n\n%s", key, examples(key))
    end
  end
end

if ENV['DOC']
  # Hook Rspec test process
  RSpec.configure do |config|
    config.after(:each) do
      response ||= last_response
      request ||= last_request
      meta = RSpec.current_example.metadata.dup
      # meta[:caller] = ''
      # meta[:example_group][:caller] = ''
      # meta[:example_group][:example_group][:caller] = ''
      example_name = meta[:example_group][:parent_example_group][:description]
      blueprint = RSpecApiDoc.examples(example_name)

      desc = meta[:example_group][:description]
      unless RSpecApiDoc.req_uris(example_name).include?(desc)
        blueprint << "## #{desc}\n\n"
        RSpecApiDoc.req_uris(example_name) << desc
      end

      request_body = request.body.read
      request.body.rewind
      authorization_header = request.env ? request.env['HTTP_AUTHORIZATION'] : request.headers['Authorization']

      # Request Headers
      if request_body.present? || authorization_header.present?
        blueprint << "+ Request #{meta[:description_args].first}\n\n"
        if authorization_header.present?
          blueprint << "+ Headers\n\n".indent(4)
          blueprint << "Authorization: #{authorization_header}\n\n".indent(12)
        end

        # Request Body
        if request_body.present?
          blueprint << "+ Body\n\n".indent(4) if authorization_header
          if request.media_type == 'application/json'
            req_data = JSON[request_body]
          else
            req_data = request.params
          end
          blueprint << "#{JSON.pretty_generate(req_data)}\n\n".indent(authorization_header ? 12 : 8)
        end
      end

      # Response
      blueprint << "+ Response #{response.status} (#{response.content_type})\n\n"
      if response.body.present? && response.content_type =~ /application\/json/
        blueprint << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(8)
      else
        blueprint << "...\n\n".indent(8)
      end
    end

    config.after(:suite) do
      Dir["#{ENV['DOC_SRC']}/*.api.md"].each do |md|
        render_md = md.sub(/\.md\Z/, '.render.md')
        File.open(render_md, 'wb') do |wfh|
          wfh.write ERB.new(File.read(md)).result(RSpecApiDoc.get_binding)
        end
      end
    end
  end
end
