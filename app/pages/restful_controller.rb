module API
  # Controller base for Restful API pages
  class RestfulController < Sinatra::Base
    use Rack::JsonResponse

    configure do
      set :logging, nil
      set :show_exceptions, false # true if development?
      set :raise_errors, true # let exceptions pass through (to responser)
    end # configure

    not_found { fail RouteError, :not_found }

    helpers do
      # this hash will merged into JsonResponse
      def common_rsp
        env['response_hash'] ||= {}
      end
    end

    # allow client to specify locale via parameter
    before { I18n.locale = params[:locale] if params[:locale] }
  end
end
