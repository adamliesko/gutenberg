require 'json'
module Scraper
  module Persistor
    FILE_PATH = '../data/es_data.json'

    def self.store_to_file(book)
      open(FILE_PATH, 'a') do |f|
        f << book_row(book)
      end
    end

    private

    def self.es_index_row
      "{ 'index' : { '_index' : 'gutenberg', '_type' : 'books'}"
    end

    def self.book_row(book)
      es_index_row + "\n" + book.to_es_hash.to_json
    end
  end
end
