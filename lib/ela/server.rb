require 'socket'

require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/backbone'
require 'stylus'
require 'haml'
require 'coffee_script'
require 'stylus/tilt'
require 'haml_coffee_assets'

module ELA
  class Server < Sinatra::Base
     set :root,          '/'
     set :views,         File.expand_path('../../app/views', __dir__)
     set :public_folder, 'public'
     set :static,        false

     register Sinatra::JstPages
     serve_jst '/ela/js/templates.js'

     register Sinatra::AssetPack

     assets do
       serve '/ela/js',    from: File.expand_path('../../app/js', __dir__)
       serve '/ela/css',   from: File.expand_path('../../app/css', __dir__)
       serve '/ela/fonts', from: File.expand_path('../../app/fonts', __dir__)

       serve '/js',     from: File.join(Dir.pwd, 'apps')
       serve '/images', from: File.join(Dir.pwd, 'images')

       # Make sure to include assets relatively to the including file
       asset_hosts ['.']

       js :app, '/js/app.js', [
         '/ela/js/vendor/webfontloader-*.js',
         '/ela/js/vendor/modernizr-*.js',
         '/ela/js/vendor/three-*.js',
         '/ela/js/vendor/jquery-*.js',
         '/ela/js/vendor/hammer-*.js',
         '/ela/js/vendor/underscore-*.js',
         '/ela/js/vendor/backbone-*.js',
         '/ela/js/vendor/jquery.backbone-hammer.js',
         '/ela/js/vendor/jquery.keyboard-modifiers.js',
         '/ela/js/vendor/request_animation_frame.js',
         '/ela/js/vendor/jquery.scrollTo-*.js',
         '/ela/js/vendor/jquery.after-transition.js',
         '/ela/js/vendor/Markdown.Converter.js',
         '/ela/js/vendor/Markdown.Extra.js',
         '/ela/js/vendor/Markdown.Toc.js',
         '/ela/js/vendor/persistjs-*.js',
         '/ela/js/vendor/js-yaml-*.js',
         '/ela/js/vendor/jquery.mark-*.js',
         '/ela/js/vendor/poised/*.js',
         '/ela/js/vendor/markup_text.js',
         '/ela/js/vendor/backbone.poised/underscore_ext.js',
         '/ela/js/vendor/backbone.poised/patches.js',
         '/ela/js/vendor/backbone.poised/view.js',
         '/ela/js/vendor/backbone.poised/**/*.js',
         '/ela/js/vendor/gaussianElimination.js',
         '/ela/js/lib/mathjaxConfig.js',
         '/ela/js/templates.js',
         '/ela/js/lib/application.js',
         '/ela/js/lib/router.js',
         '/ela/js/lib/bootstrap_data.js',
         '/ela/js/lib/models/base_app_model.js',
         '/ela/js/lib/models/**/*.js',
         '/ela/js/lib/views/canvas.js',
         '/ela/js/lib/views/**/*.js',
         '/ela/js/lib/collections/**/*.js',
         '/js/*/models/**/*.js',
         '/js/*/views/**/*.js',
         '/js/*/collections/**/*.js'
       ]
       css :app, '/ela/css/app.css', ['/ela/css/screen.css']

       js_compression :uglify
       css_compression :simple
     end

     configure do
       # TODO: make sure nib and stylus node modules are installed
       Stylus.use :nib
       Stylus.use :poised
       enable :raise_errors, :logging
       mime_type :md, 'text/markdown'
     end

     configure :development do
       enable :show_exceptions
       Stylus.debug = true
     end

     get '/' do
       haml :index
     end

     get '/settings.default.yml' do
       content_type :yaml
       ELA.settings
     end

     get '/labels.default.yml' do
       content_type :yaml
       ELA.labels
     end

     get '/images/icons/:app.svg' do |app|
       path = File.join(Dir.pwd, "apps/#{app}/icon.svg")
       if File.exists?(path)
         send_file(path)
       else
         status(404)
       end
     end

     get '/help/:app.md' do |app|
       path = File.join(Dir.pwd, "apps/#{app}/help.md")
       if File.exists?(path)
         send_file(path)
       else
         status(404)
       end
     end

     def page_title
       ELA.page_title
     end

   end

   ENV['NODE_PATH'] = [
     File.expand_path('../../node_modules', __dir__),
     ENV['NODE_PATH']
   ].join(File::PATH_SEPARATOR)
end
