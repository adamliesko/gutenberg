module Cleaner
  def self.clean_file(filename)
    File.open(filename).map(&:chomp).map do |line|
      line.strip.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end.join(' ')
  end
end
