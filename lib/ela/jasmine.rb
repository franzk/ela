require 'jasmine'

module ELA
  class Jasmine
    ELA_SRC_FILE_SPECS = [
      'vendor/webfontloader-*.js',
      'vendor/jquery-*.js',
      'vendor/hammer-*.js',
      'vendor/underscore-*.js',
      'vendor/backbone-*.js',
      'vendor/backbone.poised/underscore_ext.js',
      'vendor/backbone.poised/patches.js',
      'vendor/backbone.poised/view.js',
      'vendor/backbone.poised/**/*.js',
      'vendor/poised/**/*.js',
      'vendor/markup_text.js',
      'vendor/request_animation_frame.js',
      'vendor/js-yaml-*.js',
      'vendor/gaussianElimination.js',
      'lib/bootstrap_data.js',
      'lib/application.js',
      'lib/models/base_app_model.js',
      'lib/models/**/*.js',
      'lib/collections/**/*.js',
      'lib/views/canvas.js',
      'lib/views/base_graph.js',
      'lib/router.js'
    ]

    APP_SRC_FILE_SPECS = [
      '*/models/**/*.js',
      '*/collections/**/*.js'
    ]

    ELA_SPEC_HELPERS_PREFIX = '/__ela_spec_helpers__'
    ELA_SPEC_HELPERS_PATH = File.expand_path('../../dist/spec_helpers', __dir__)

    ELA_JS_PREFIX = '/__ela_src__'
    ELA_JS_PATH = File.expand_path('../../dist/app_js', __dir__)

    def self.configure
      ::Jasmine.configure do |config|
        config.src_dir = File.join(Dir.pwd, 'spec/app_js')
        config.spec_dir = File.join(Dir.pwd, 'spec/javascripts')
        config.spec_files = lambda { spec_files }
        config.src_files = lambda { src_files }
        config.add_rack_path(ELA_JS_PREFIX, lambda { Rack::File.new(ELA_JS_PATH) })
        config.add_rack_path(ELA_SPEC_HELPERS_PREFIX, lambda { Rack::File.new(ELA_SPEC_HELPERS_PATH) })
      end
    end
    private_class_method :configure

    def self.start_server
      configure
      ::Jasmine::Server.new(
        ::Jasmine.config.port(:server),
        ::Jasmine::Application.app(::Jasmine.config),
        ::Jasmine.config.rack_options
      ).start
    end

    def self.run
      configure
      ::Jasmine::CiRunner.new(::Jasmine.config).run
    end

    def self.src_files
      [
        expand_specs(ELA_SRC_FILE_SPECS, ELA_JS_PATH, ELA_JS_PREFIX),
        expand_specs(APP_SRC_FILE_SPECS, ::Jasmine.config.src_dir),
        expand_specs(['**/*.js'], ELA_SPEC_HELPERS_PATH, ELA_SPEC_HELPERS_PREFIX)
      ].flatten
    end

    def self.spec_files
      Dir.glob(File.join(Dir.pwd, 'spec/javascripts/**/*[sS]pec.js'))
    end

    def self.expand_specs(specs, path, prefix = '')
      specs.map do |spec|
        Dir[File.join(path, spec)].map do |file|
          file.gsub(path, prefix)
        end.sort
      end
    end
  end
end
