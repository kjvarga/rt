require 'rake'
require 'spec/rake/spectask'

# 'rake gemspec' will generate the gemspec using Jeweler
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "yaml_db"
    gem.summary = "Dumps and loads database contents in a database-agnostic YAML format."
    gem.description = "Data is written and read from db/data.yml, or to file of your choosing.  Records are written " +
      "in batches making this perfect for dumping very large databases or on systems with " +
      "limited memory resources, such as shared hosting.  A modest 250 records are read at " +
      "a time though this can be customized by passing an argument to the rake tasks."
    gem.email = "kjvarga@gmail.com"
    gem.homepage = "http://github.com/kjvarga/yaml_db"
    gem.authors = ["Orion Henry", "Adam Wiggins"]
    gem.add_dependency "activerecord"
    gem.version = '1.0.0'
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
	t.spec_files = FileList['spec/*_spec.rb']
end

task :default => :spec

