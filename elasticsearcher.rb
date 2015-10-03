module Elasticsearcher
  require 'elasticsearch'

  def self.client
    @@client ||= Elasticsearch::Client.new log: false
  end
end
