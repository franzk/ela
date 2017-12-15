require "bundler/gem_tasks"
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

ENV['RACK_ENV'] = 'production'
APP_FILE  = 'lib/ela/server.rb'
APP_CLASS = 'ELA::Server'
require 'sinatra/assetpack/rake'

require './lib/ela/ela'

def compile_custom(path, target_file)
  response = app.assets.send(:build_get, path)
  File.open(File.join(app.settings.public_folder, target_file), 'w+') do |f|
    f.puts response.body
  end
  puts "Precompiling #{path} to #{target_file} ..."
end

def write_yml(path)
  ELA.write_settings_yml(File.join(path, 'settings.default.yml'))
  ELA.write_labels_yml(File.join(path, 'labels.default.yml'))
end

task :clean do
  rm_rf 'dist'
  rm_rf 'doc'
  rm_f 'CHANGELOG.md'
end

task :build => :clean do
  mkdir 'dist'
  compile_custom('/', 'index.html')
  Rake::Task['assetpack:precompile:packages'].invoke
  cp_r(File.join(app.settings.root, 'app', 'fonts'), File.join(app.settings.public_folder, 'fonts'))
  cp_r(File.join(app.settings.root, 'app', 'images'), File.join(app.settings.public_folder, 'images'))
  cp(File.join(app.settings.root, 'app', 'images', 'favicons', 'favicon.ico'), File.join(app.settings.public_folder, 'favicon.ico'))
  write_yml(app.settings.public_folder)
  mkdir 'public/js/vendor'
  cp_r(Dir[File.join(app.settings.root, 'app', 'js', 'vendor', 'mathjax')], File.join(app.settings.public_folder, 'js', 'vendor'))
end

task :doc do
  File.open('CHANGELOG.md', 'w') do |f|
    f << `git-changelog`
  end
  system('codo')
  cp_r(File.join(app.settings.root, 'screenshots'), File.join(app.settings.root, 'doc', 'extra'))
end

require 'coffee-script'
require 'fileutils'
def coffee_compile(source_dir, target_dir)
  glob = File.join(source_dir, '**/*.coffee')
  Dir[glob].each do |file|
    target_file = file.
                  gsub(/^#{source_dir}/, target_dir).
                  gsub(/\.coffee$/, '.js')
    target_file_dir = File.dirname(target_file)
    puts " #{file} to #{target_file}"
    FileUtils.mkdir_p(target_file_dir)
    File.open(target_file, "w") do |f|
      f.puts CoffeeScript.compile(File.read(file))
    end
  end
end

namespace :test do
  desc "Compile app and spec coffeescripts."
  task :compile do
    puts "Compiling app coffeescripts for testing ..."
    coffee_compile('./app/js', './spec/app_js')

    puts "Compiling spec coffeescripts for testing ..."
    coffee_compile('./spec/coffeescripts', './spec/javascripts')

    puts "Copying vendored javascript for testing ..."
    cp(Dir["./app/js/vendor/*.js"], "./spec/app_js/vendor/")

    puts "Building config files for testing ..."
    write_yml('./spec/app_js')
  end

  desc "Run jasmine specs."
  task :run => 'jasmine:ci'

  desc "Clean all untracked and ignored files on ./spec folder."
  task :clean do
    sh 'git clean -f -d -x -- ./spec'
  end
end

desc "Compile, run and clean specs."
task :test => ['test:compile', 'test:run']

task default: :test
