Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES
# limit to one format
Gollum::Page::FORMAT_NAMES = { :markdown  => "Markdown" }


# Specify the path to the Wiki. You can use a relative or absolute path.
#
# Clone https://github.com/Marketron/wiki 
# Clone https://github.com/Marketron/gollum
# Set path  
gollum_path = "../wiki"

Precious::App.set(:gollum_path, gollum_path)

wiki_options = {
  :ref => "develop",         # The git branch of Mediascape wiki repo this instance of gollum will serve
  :universal_toc => false, 
  :live_preview => true,
  :allow_uploads => false,
  :allow_editing => true,
  :per_page_uploads => true,
  :mathjax => true,
  :h1_title => false,
  :show_all => false,
  :css => true,
  :js => true,
  :collapse_tree => false,
  :user_icons => [:gravatar, :identicon]
}

Precious::App.set(:wiki_options, wiki_options)

# Set as Sinatra environment as production (no stack traces)
Precious::App.set(:environment, :development)

# Setup Omniauth via Omnigollum.
require 'omnigollum'


require 'omniauth-marketron'

omniOptions = {

=begin 

  Gollum authenticates to the Marketron SSO on behalf of the resource owner. 
  

  1) SSO 
     
    TODO:

     - Create a new client identity (a tenant) in Marketron SSO that will represent the gollum app. What we need?
     - Client_Secret:   
     - Client_ID:            
     - Site:  Marketron SSO URL where OAUTH will be sending authentication requests to. TBD: 'http://wiki.lvh.me:3000'  

    For now it just provides a fake client just to see that we are at least redirected to SSO.  
  
  2) Gollum 
     In addition to omniauth need Device to manage authentication redirects?   
     Sinatra app - add custom routes? 


=end

  # OmniAuth::Builder block is passed as a proc
  :providers => Proc.new do
    binding.pry 
      provider :marketron, :client_id=>"6b3d79b2068e6110a946b6632cd17fd91f72234eb24edf0499cf4b14a30c7ed5", :client_secret=>"f19fc7c70181ad2a41b0fb896c32dbaa794feb6ba766f5bec0886fe4817cfcf4", :client_options=>{:site=>"http://buyer.lvh.me:3000"}
  end,

  :dummy_auth => false,

  # Make the entire wiki private
  :protected_routes => ['/*'],
  # Specify committer name as just the user name
  :author_format => Proc.new { |user| user.name },
  # Specify committer e-mail as just the user e-mail
  :author_email => Proc.new { |user| user.email }

}
 
Precious::App.set(:omnigollum, omniOptions)
Precious::App.register Omnigollum::Sinatra