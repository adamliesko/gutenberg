require "sinatra/base"
require "sinatra/reloader"
require "./book"
require 'pry'

module Gutenberg
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    configure do
      # Set your Google Analytics ID here if you have one:
      # set :google_analytics_id, 'UA-12345678-1'

      set :layouts_dir, 'views/_layouts'
      set :partials_dir, 'views/_partials'
    end

    helpers do
      def show_404
        status 404
        @page_name = '404'
        @page_title = '404'
        erb :'404', :layout => :with_sidebar,
            :layout_options => {:views => settings.layouts_dir}
      end
    end


    not_found do
      show_404
    end


# Redirect any URLs without a trailing slash to the version with.
    get %r{(/.*[^\/])$} do
      redirect "#{params[:captures].first}/"
    end

    get '/' do
      @page_name = 'gutenberg'
      @page_title = 'Gutenberg search and LDA'
      erb :index,
          :layout => :full_width,
          :layout_options => {:views => settings.layouts_dir}
    end


# Routes for pages that have unique things...

    get '/search/' do
      @page_name = 'search'
      @page_title = 'Search Gutenberg Books'
      @time = Time.now
      erb :search,
          :layout => :full_width,
          :layout_options => {:views => settings.layouts_dir}
    end

    post '/search/' do
      @page_name = 'search'
      @page_title = 'Search Gutenberg Books'
      query = params[:query]
      response = Book.search(query, params[:from]) if query
      @results, @total = response[:results], response[:total].to_i
      @query = query
      erb :search,
          :layout => :full_width,
          :layout_options => {:views => settings.layouts_dir}
    end

    get '/lda/' do
      @page_name = 'lda'
      @page_title = 'Latent Dirichlet Allocation'
      @time = Time.now
      erb :lda,
          :layout => :full_width,
          :layout_options => {:views => settings.layouts_dir}
    end


  end
end
