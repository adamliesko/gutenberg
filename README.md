## Idea

Parse metadata and full texts from [Project Gutenberg](http://www.gutenberg.org/wiki/Main_Page) - an archive of books. These books were made avialable public through a license agreement or by the fact that they age is older than 80 years or their authors are dead. Implement in-memory search over parsed data and analyze texts with Latent Dirichlet Allocation in order to discover topics within the books.

## Dataset

In our assignment we have worked with three datasets from different sources.

*   [Gutenberg Dataset](http://web.eecs.umich.edu/~lahiri/gutenberg_dataset.html) - This is a collection of 3,036 English books written by 142 authors. This collection is a small subset of the Project Gutenberg corpus, on which we have performed the actual implementation of the assignment.

*   [Project Gutenberg DVD (2010)](https://www.google.sk/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=project%20gutenberg%20dvd%202010) - Compilation of almost 30,000 books with all the file formats like epub, html or txt.

*   [Project Gutenberg live site scraping](http://www.gutenberg.org/ebooks/50131) - By scraping the live site, we would have been able to parse all the necessary metadata and raw books' content. Unfortunately, Gutenberg is not a very happy with this approach and we would have to rapidly limit our download rate. On this assignment we have not used data from this source, but we have fully implemented the scraper/parser which might be setup as a scheduled CRON job in order to obtain the Gutenberg data over a longer period of time (1 month or so).

## Implementation

#### Scraper aka parser

We have implemented two similar parsers. One is really simple and it works on the offline data, where we take a `txt` file as a input and extr `title`, `author` and book `content` into a json. These jsons are afterwards printed into one large text file for further interaction with Elasticsearch.

We have utilized similar approach for scraping live site of Project Gutenberg. Unfortunately, they banned our parser almost immediately for the next 24 hours. Project Gutenberg recommends to use either `rsync` or offline datasets as a way to obtain the data. One possible approach might be to use scheduled scraping in intervals. We have decided to stick with the offline datasets, although we have fully implemented the live site scraper, which resided in the `scraper` directory. Below we are presenting some small interesting parts of our code.

Extracting attributes from live site:
```ruby
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
```

Method for stripping header and footer from book text file:

```ruby
def self.strip_headers(text)
      lines_count = text.lines.count.to_i
      start_index = HEADER_MARKERS.map { |marker| text.index(marker) }.max || 0
      end_index = HEADER_MARKERS.map { |marker| text.index(marker) }.min || lines_count

      clean_text = ''
      text.lines.each_with_index do |line, index|
        if index > start_index && index < end_index
          clean_text << line.gsub(/\r\n?/, "\n")
        end
      end
    end
```

#### In-memory search

As described previously, output of the parsers consists of a single large text file containing data to be indexed for elasticsearch in format. We are simply telling Elasticsearch to index following json into the `gutenberg` index as a `books` type. By using `index` action we are creating (or updating existing document) in Elasticsearch database. For the actual indexation we have uploaded the data to Elasticsearch through the `BULK` api.

<pre>    1st line: Elasticsearch action
    2nd line: Elasticsearch data</pre>

This is how would the json output look from our online parser.

<pre>  `{
    "index": {
      "_index": "gutenberg",
      "_type": "books"
    }

    {
      "author": "Gilman, Charlotte Perkins, 1860-1935",
      "translator": null,
      "illustrator": null,
      "title": "The Yellow Wallpaper",
      "language": "English",
      "date_published": "1999-11-01",
      "subject": [
        "Psychological fiction",
        "Mentally ill women -- Fiction",
        "Feminist fiction",
        "Married women -- Psychology -- Fiction",
        "Sex role -- Fiction"
      ],
      "loc_class": "PS: Language and Literatures: American and Canadian literature",
      "content": {"Book content"}
      ]
    }` 
    </pre>

The output of our offline parser is kind of simpler json structure (e.g.).

<pre> 
{
  "author": "Gilman, Charlotte Perkins, 1860-1935",
  "title": "The Yellow Wallpaper",
  "content": "Book content"
}
</pre>

For Elasticsearch mapping we stuck to the standard string format, which results into the usage of standard analyzer. The query the we are running is as follows.

<pre>{"query":{"multi_match":{"query":"john","fields":["title^10","author^10","content"]}},"from":null,"highlight":{"pre_tags":["mark"],"post_tags":["/mark"],"fields":{"content":{}}}}
</pre>

We are boosting the `title` and `author` fields and highlight `content`. We implemented a lightweight "frontend" application above the backend written in Ruby running on Sinatra.

#### Topic Estimation

Our aim was to cluster documents and find out the main topics of our dataset described by most frequently used keywords. One of the most popular approaches for such a task is Latent Dirichlet Allocation. I have tried implementing LDA in [Apache Spark](http://spark.apache.org/) and [Apache Mahout](https://mahout.apache.org/users/clustering/latent-dirichlet-allocation.html), both using some variant of `Collapsed Variational Bayes`. Both provide built in examples which seemed suitable for our dataset, at least on the first sight. We were not able to get any results from Spark and Mahout mainly because of the heaviness of task (limited single node resources) even for a small dataset - 3000 books.

After further research we have stumbled upon open source solution [Mallet](http://mallet.cs.umass.edu/) which is a MAchine Learning for LanguagE Toolkit developed by Andrew McCallum. It uses [Gibbs Sampling](https://en.wikipedia.org/wiki/Gibbs_sampling) - a statistical technique meant to quickly construct a sample distribution, to create its topic models.

##### Dataset preprocessing

As a first step, we needed to preprocess our dataset into a Mallet-understandable file format. This processing included removal of stopwords defined by mallet text file. This reduced our 1.2 GB large input directory of text files into 344 MB large file.

<pre>
./bin/mallet import-dir --input $GUTENBERG_DIR/input --output $GUTENBERG_DIR/out --keep-sequence
  --remove-stopwords
</pre>

##### LDA topic estimation

With the mallet data prepared in our file, we can now run `train-topics` algorithm. For this specific assignment we have used `2000` iterations with `15` topics and `15` descriptive keywords. All of this and much more can be configured with the simple cmdline parameters. Additional options include also actual output of the trained model, trained topics and their distribution within the documents.

<pre>
.bin/mallet train-topics --$GUTENBERG_DIR/lda/dataset_one_line/out --num-topics 20 --optimize-interval 20
  --output-state $GUTENBERG_DIR/topic-state.gz --output-topic-keys $GUTENBERG_DIR/gutenberg_keys.txt --output-doc-topics
  $GUTENBERG_DIR/gutenberg_composition.txt
</pre>

##### LDA topics output

As you can see some of the topics do not really make sense, but some can be easily identified as a topics dealing with love, politics, sailing, nature, France or war. Which kinda fits into the character of our english dataset.

<pre>1	0.06379	sir king ye lord man lady thou good father master knight castle richard time
1	0.21507	life man great men world work things time people human good mind nature sense
1	0.07881	de day lord good king prince french great poor paris young la madame letter
0	0.00378	ra tz ff se ee ev qm fy sw gn ej ib ku hx
1	0.10065	god man thou men christ lord good things thy great world life made thee
1	0.10278	men time great army made general day place back war enemy long troops left
1	0.05883	species plants animals mr great case part long form birds water forms found cases
0	0.28987	man eyes face hand looked back moment time long life voice head night turned
0	0.09335	thy thou love thee heart er life footnote tis day death soul earth ii
0	0.22706	good time day great long back man made home head house mother people till
1	0.17554	great time made country mr general state people government power man part men public
0 0.11829 mr don mrs man ve ll good time back room sir miss asked young
0 0.08219 ll don man back ve good time made dick men make tom boys long
0	0.16306	mr mrs lady man miss good time don made sir house thought dear young
1	0.11807	captain time sea ship men water man boat good made great long day found
</pre>

## Further Ideas and Work

*   Search pagination
*   LDA - put topics per documents into the Elasticsearch
*   Visualize cluster network

## Requirements

#### Engines

*   [Elasticsearch (1.7)](https://www.elastic.co/products/elasticsearch) - in-memory full-text search
*   [Mallet (2.0.7)](http://mallet.cs.umass.edu/index.php) - used for LDA topic estimation

#### Web Application

*   Ruby
*   Sinatra
*   Take a look at Gemfile for docs :)

## Source Code

For source code checkout [Github repository](https://github.com/adamliesko/gutenberg).

## Conclusion

We have successfully implemented an in-memory full-text search over the Gutenberg books and analyzed their topics distribution. Altogether we have worked with three sources of data and experimented with interesting software libraries.
