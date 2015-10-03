module Cleaner
  def self.clean_file(filename)
    File.open(filename).map(&:chomp).map { |line| line.strip.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    }.join(' ')
  end
end
