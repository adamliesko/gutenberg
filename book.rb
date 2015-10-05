require 'json'
require './elasticsearcher'

class Book
  attr_accessor :metadata, :content

  BOOK_URL_START = 'https://www.gutenberg.org/ebooks/'
  TEXT_URL_START = 'https://www.gutenberg.org/ebooks/1.txt.utf-8'
  TEXT_URL_END = '.txt.utf-8'
  CACHED_TEXT_URL_START = 'http://www.gutenberg.org/cache/epub/1'
  CACHED_TEXT_URL_END = '/pg1.txt'

  def initialize(options)
    @metadata = options[:metadata]
    @content = options[:content]
  end

  def to_es_hash
    @metadata.to_hash.merge(content: @content)
  end

  def self.search(query, from)
    x = build_query(query, from)
    puts x
    response = Elasticsearcher.client.search index: 'gutenberg', body: x
    { results: parse_es_books(response), total: response['hits']['total'] }
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

  def self.index_documents(path)
    f = open(path, 'r')
    i = 0
    actions_and_documents = []
    content = f.read
    lines_count = content.lines.count.to_i
    content.each_line do |line|
      i += 1
      actions_and_documents << line.strip
      if i % 100 == 0 || i == lines_count
        Elasticsearcher.client.bulk(body: actions_and_documents)
        actions_and_documents = []
      end
    end
  end

  def self.build_query(query, from = nil)
    {
      "query": {
        "multi_match": {
          "query": query,
          "fields": ['title^10', 'author^10', 'content']
        }
      },
      "from": from,

      "highlight": {
        "pre_tags": ['<mark>'],
        "post_tags": ['</mark>'],
        "fields": {
          "content": {}
        }
      }
    }.to_json
  end

  def self.parse_es_books(response)
    response['hits']['hits'].map { |hit| { content_highlight: hit['highlight']['content'].join(' '), title: hit['_source']['title'], author: hit['_source']['author'], content: hit['_source']['content'][0..160] } }
  end
end
