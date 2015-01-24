require 'git'
# mix-in to the name space
module AssetsMapper
  # Handle pulling from git or github URL
  class Pull
    attr_accessor :app_name, :remote, :branch, :to, :update

    def initialize(app_name, to, opts = {})
      @app_name, @to = app_name, to
      @github = opts.extract_args(:github)
      @remote = File.join('https://github.com', @github) if @github
      @remote, @branch = (opts.extract_args git: @remote,
                                            branch: 'master').map(&:to_s)
      @update = opts.extract_args! update: true
      fail 'no remote server defined' unless @remote
    end

    # Implement dump/up interface
    # -------------------------------------
    def working_dir
      File.join File.expand_path(to.to_s), app_name.to_s
    end

    def update!
      if File.directory?(working_dir)
        return puts "SKIP update #{working_dir}" unless @update
        puts "Updating working directory #{working_dir}"
        git_update
      else
        puts "Pulling #{@app_name} (<- #{@remote})"
        git_clone!
      end
    end

    # Actual operations
    # --------------------
    def git_clone!
      FileUtils.mkdir_p to unless File.directory?(to)
      g = Git.clone(@remote.to_s, @app_name.to_s, path: @to)
      if g.branches.remote.map(&:name).include?(@branch)
        puts "Checkout branch #{@branch}"
        g.branch(@branch).checkout
        g.pull(@remote, @branch)
      else
        warn "Skip, no branch named #{@branch} on #{@remote}"
      end
    end

    def git_update
      g = Git.open(working_dir)
      if g.remotes.map(&:url).include?(@remote)
        g.branch(@branch).checkout
        g.pull(@remote, @branch)
      else
        warn "Seems the working directory for #{@app_name} was "\
             "not cloned from #{@remote}, skip"
      end
    end
  end
end
