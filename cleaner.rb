module Cleaner
  def self.clean_file(filename)
    File.open(filename).map(&:chomp).join(' ')
  end
end
