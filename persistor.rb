class Persistor
  def initialize(outpath)
    @filepath = outpath
  end

  def persist(book)
    open(@filepath, 'a') do |f|
      f << book
    end
  end
end
