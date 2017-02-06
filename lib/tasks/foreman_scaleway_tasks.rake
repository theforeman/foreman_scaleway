require 'rake/testtask'

# Tests
namespace :test do
  desc 'Test ForemanScaleway'
  Rake::TestTask.new(:foreman_scaleway) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_scaleway do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_scaleway) do |task|
        task.patterns = ["#{ForemanScaleway::Engine.root}/app/**/*.rb",
                         "#{ForemanScaleway::Engine.root}/lib/**/*.rb",
                         "#{ForemanScaleway::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_scaleway'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_scaleway']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_scaleway', 'foreman_scaleway:rubocop']
end
