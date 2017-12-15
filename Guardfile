group :development do
  options = {
    input: 'app/js',
    output: 'dist/app_js',
    all_on_start: true,
    patterns: [/^app\/js\/(.+)\.coffee$/]
  }
  guard 'coffeescript', options do
    options[:patterns].each { |pattern| watch(pattern) }
  end

  options = {
    input: 'spec/coffeescripts/helpers',
    output: 'dist/spec_helpers',
    all_on_start: true,
    patterns: [/^spec\/coffeescripts\/helpers\/(.+)\.coffee$/]
  }
  guard 'coffeescript', options do
    options[:patterns].each { |pattern| watch(pattern) }
  end

  guard :copy3, from: 'app/js', to: 'dist/app_js' do
    watch(%r{^app\/js\/.+\.js$})
  end
end
