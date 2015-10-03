require 'json'
class Book
  attr_accessor :metadata, :content

  BOOK_URL_START = 'https://www.gutenberg.org/ebooks/'
  TEXT_URL_START = 'https://www.gutenberg.org/ebooks/1.txt.utf-8'
  TEXT_URL_END = '.txt.utf-8'
  CACHED_TEXT_URL_START = 'http://www.gutenberg.org/cache/epub/1'
  CACHED_TEXT_URL_END = '/pg1.txt'

  def initialize(options)
    @metadata = options[:metadata]
    @content  = options[:content]
  end

  def to_es_hash
    puts @content
    @metadata.to_hash.merge(content: @content)
  end

  def self.book_url(id)
    BOOK_URL_START + id.to_s
  end

  def self.text_url(id)
    TEXT_URL_START + id.to_s + TEXT_URL_END
  end

  def self.cached_text_url(id)
    CACHED_TEXT_URL_START + id.to_s + CACHED_TEXT_URL_END
  end
end
