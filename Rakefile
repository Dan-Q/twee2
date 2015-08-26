require "bundler/gem_tasks"

namespace :web do
  # Yields to a block after chdir'ing to the specified
  # path (relative to the app root), then chdir's back
  def run_from_directory(path)
    old_dir = Dir::pwd
    Dir::chdir("#{File::dirname(__FILE__)}/#{path}")
    yield
    Dir::chdir(old_dir)
  end
  
  desc 'Build the website from source'
  task :build do
    run_from_directory('web') do
      system("middleman build --clean")
    end
  end

  desc "Preview the website at http://localhost:4567"
  task :preview do
    run_from_directory('web') do
      system("middleman server")
    end
  end
end
