#!/usr/bin/env ruby
require 'rubygems'
require 'gollum/app'

MEDIASCAPE_WIKI_GIT_REPO_PATH = "/home/marketron/wiki"  # CHANGE THIS TO POINT TO THE WIKI REPO
MEDIASCAPE_WIKI_GIT_REPO_REF = "mediascape-integration" # CHANGE THIS TO REFERENCE THE GIT BRANCH  
AUTHOR_SESSION_TIMEOUT =  86400 # 24 hours by default. 

#File.expand_path(File.join(File.dirname(__FILE__), MEDIASCAPE_WIKI_GIT_REPO_PATH)) 

gollum_path = MEDIASCAPE_WIKI_GIT_REPO_PATH 
puts "gollum_path: #{gollum_path}"

Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown)
Precious::App.set(:wiki_options, {
  :allow_uploads => 'dir',
  :show_all => true,
  :live_preview => false,   #! live preview must be set to false initially in order for the auth identity to work ;(
  :ref => MEDIASCAPE_WIKI_GIT_REPO_REF}
)

Precious::App.set(:bind, '0.0.0.0') 

module Precious
  class App < Sinatra::Base
    ['/create/*','/edit/*', '/delete/*'].each do |path|
      before path do
        session['time'] ||= Time.now
        if session['gollum.author'].nil? || session['gollum.author'].empty?
          redirect '/author/set'
        end
        settings.wiki_options[:live_preview] = session['author.live_preview'] unless session['author.live_preview'].nil?
        settings.wiki_options[:universal_toc] = session['author.universal_toc'] unless session['author.universal_toc'].nil?

      end
    end
  end
end

class AuthorApp < Sinatra::Base
  get '/' do
    redirect '/author/set'
  end

  get '/set' do
    if session['gollum.author'].nil? || session['gollum.author'].empty?
      form = "The author is not set: <a href=\"/author/set\">Set Author</a></br></br>"
    else
      form = "Author is set to <b>#{session['gollum.author'][:name]}</b> (<b>#{session['gollum.author'][:email]}</b>) with live markdown editor set to <b>#{session['author.live_preview']}</b> and TOC to  <b>#{session['author.universal_toc']}</b>.</br></br>"
    end
    form << "To set up your author identity, use your Marketron's user name and email. Optionally, you can also set preferences for Wiki<br/>
    <form name=\"input\" action=\"set\" method=\"post\">
    Name: <input type=\"text\" name=\"name\" value=\"#{session['gollum.author'][:name] unless session['gollum.author'].nil? || session['gollum.author'].empty? || session['gollum.author'][:name].nil?}\"><br/>
    Email: <input type=\"text\" name=\"email\" value=\"#{session['gollum.author'][:email] unless session['gollum.author'].nil? || session['gollum.author'].empty? || session['gollum.author'][:email].nil?}\"><br/>
    Live Editor (side by side live editor for markdown): <input type=\"checkbox\" name=\"live_preview\"#{' checked="checked"' if session['author.live_preview']}><br/>
    Universal TOC (table of contents): <input type=\"checkbox\" name=\"universal_toc\"#{' checked="checked"' if session['author.universal_toc']}><br/>
    <input type=\"hidden\" name=\"referrer\" value=\"#{request.referrer}\"><br/>
    <input type=\"submit\" value=\"Submit\"> or <a href=\"/author/clear\">Clear Author/Preferences</a>
    </form>"
  end

  post '/set' do
    session['gollum.author'] = { :name => params['name'], :email => params['email'] }
    session['author.live_preview'] = params['live_preview'].nil? ? false : true
    session['author.universal_toc'] = params['universal_toc'].nil? ? false : true
    redirect params['referrer'] || '/'
  end

  get '/clear' do
    session['gollum.author'] = {}
    session['author.live_preview'] = nil
    session['author.universal_toc'] = nil
    redirect '/author/set'
  end
end

use Rack::Session::Cookie, { :key => 'rack.session', :secret => "**********", :expire_after => AUTHOR_SESSION_TIMEOUT }
                                                                  
# Boot apps
run Rack::URLMap.new("/help" => Precious::App.new,
                     "/author" => AuthorApp.new)
