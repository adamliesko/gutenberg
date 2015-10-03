module Scraper
  module Extractor
    EXTRACTABLE_ATTRS = %w(author translator illustrator title language date_published subject loc_class)

    SELECTORS = { author: { type: :value, selector: "//a[@rel='marcrel:aut']" },
                  translator: { type: :value, selector: "a[@rel='marcrel:ill']" },
                  illustrator: { type: :value, selector: "a[@rel='marcrel:ill']" },
                  title: { type: :value, selector: "td[@itemprop='headline']" },
                  language: { type: :value, selector: "tr[@itemprop='inLanguage']/td" },
                  date_published: { type: :date, selector: "td[@itemprop='datePublished']" },
                  subject: { type: :array, selector: "td[@datatype='dcterms:LCSH']/a[@class='block']" },
                  loc_class: { type: :value, selector: "//a[@href^='https://www.gutenberg.org/browse/loccs/']" }
    }

    def self.extract_attrs(doc)
      attrs = {}
      SELECTORS.each do |key, attribute|
        attrs[key] = send("selector_#{attribute[:type]}", doc.css(attribute[:selector]))
      end
      attrs
    end

    private

    def self.selector_value(selector)
      selector.map { |ele| ele.children.text.strip }.first
    end

    def self.selector_array(selector)
      selector.map { |ele| ele.children.text.strip }
    end

    def self.selector_date(selector)
      date = selector.map { |ele| ele.children.text.strip }.first
      Date.parse(date).strftime('%Y-%m-%d') # ES format date
    end
  end
end
