require './persistor'
require './cleaner'
require 'json'
module Parser
  OUT_PATH = './data/es_data_offline.json'

  def self.extract_data_to_es_json(path)
    @persistor = Persistor.new(OUT_PATH)
    idx = 0

    Dir.foreach(path) do |file_name|
      idx += 1
      next if file_name == '.' || file_name == '..'
      basename = File.basename(file_name)
      process_file(idx, File.join(path, file_name), basename)
    end
  end

  private

  def self.process_file(id, file_path, basename)
    author, title = basename.split('___')
    content = Cleaner.clean_file(file_path)
    @persistor.persist(book_row(id, author, title[0..-5], content))
  end

  def self.es_index_row(id)
    {index: {_index: :gutenberg, _type: :books, _id: id.to_s}}.to_json
  end

  def self.book_row(id, author, title, content)
    es_index_row(id) + "\n" + {author: author, title: title, content: content}.to_json + "\n"
  end
end

Parser.extract_data_to_es_json('./dataset/')
