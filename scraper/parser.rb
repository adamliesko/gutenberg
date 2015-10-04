module Scraper
  module Parser
    require 'nokogiri'
    require 'open-uri'
    require '../book'
    require '../scraper/extractor'
    require '../scraper/cleaner'
    require '../scraper/persistor'

    BOOK_URL_START = 'https://www.gutenberg.org/ebooks/'
    BOOKS_COUNT = 50_000
    TEXT_URL_START = 'https://www.gutenberg.org/ebooks/1.txt.utf-8'
    TEXT_URL_END = '.txt.utf-8'
    CACHED_TEXT_URL_START = 'http://www.gutenberg.org/cache/epub/1'
    CACHED_TEXT_URL_END = '/pg1.txt'

    ITEM_PROPERTIES = { author: 'creator', language: 'inLanguage', title: 'headline' }

    def self.download_books
      (1..BOOKS_COUNT).each do |book_id|
        book = parse_book(book_id)
        Scraper::Persistor.store_to_file(book) if book
      end
    end

    def self.parse_book(book_id)
      metadata = parse_metadata(book_id)
      content = parse_body(book_id)
      Book.new(metadata: metadata, content: content)
    rescue StandardError
      false
    end

    def self.parse_metadata(book_id)
      doc = Nokogiri::HTML(open(Parser.book_url(book_id)))
      Scraper::Extractor.extract_attrs(doc)
    end

    def self.parse_body(book_id)
      content = open(Book.cached_text_url(book_id)).read
      Scraper::Cleaner.clean(content)
    end
  end
end
