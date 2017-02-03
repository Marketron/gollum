=begin
You should use this file, if you wish to:
- launch Gollum as a Rack app,
- alter certain startup behaviour of Gollum.

For more information and examples:
- https://github.com/gollum/gollum/wiki/Gollum-via-Rack
- https://github.com/gollum/gollum#config-file

=end

# enter your Ruby code here ...

require 'rubygems'
require 'gollum/app'
require 'pry'

 # CHANGE THIS TO POINT TO THE WIKI REPO
gollum_path = File.expand_path(File.join(File.dirname(__FILE__), '../mediascape-wiki/')) 

options      = {
  :port => 4567,      
  :bind => '0.0.0.0',
}
 

Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES
Gollum::Page::FORMAT_NAMES = { :markdown  => "Markdown" }


wiki_options = {:ref => "develop",:universal_toc => false}
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown)  
Precious::App.set(:wiki_options, wiki_options)

class MapGollum
  def initialize  
      @mg = Rack::Builder.new do
          map "/" do
            run Precious::App
          end
      end
  end

  def call(env)
      @mg.call(env)
  end
end


Rack::Server.new(:app => MapGollum.new(), :Port => options[:port], :Host => options[:bind]).start

# Run: bundle exec rackup config.ru