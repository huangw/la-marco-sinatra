# for slim helper test
module Slimmer
  # for slim helper path test
  class CheckPathPage < WebApplication
    get '/' do
      File.join(template_dir, template_id)
    end

    get '/any-page' do
      File.join(template_dir, template_id)
    end

    get '/specifies/:me' do
      @me = params[:me]
      rsp :spec
    end

    get '/multi-tone' do
      rsp :i18n, locales: [:en, :zh]
    end

    Route.mount(self, '/slim-test')
  end
end
