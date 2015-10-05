module Topic
  def self.load_topics
    topics = []
    file = open('./lda/topics.txt', 'r')
    file.each_line do |topic|
      mark, score, *words = topic.split(' ')
      topics << { mark: mark.to_i > 0, score: score, words: words }
    end
    topics
  end
end
