module Scraper
  module Cleaner
    HEADER_MARKERS = [

      '*** START OF THE PROJECT GUTENBERG',
      '*** START OF THIS PROJECT GUTENBERG',
      'This etext was prepared by',
      'E-text prepared by',
      'Produced by',
      'Distributed Proofreading Team',
      '*END THE SMALL PRINT',
      '***START OF THE PROJECT GUTENBERG',
      'This etext was produced by',
      '*** START OF THE COPYRIGHTED',
      'The Project Gutenberg',
      'http://gutenberg.spiegel.de/ erreichbar.',
      'Project Runeberg publishes',
      'Beginning of this Project Gutenberg',
      'Project Gutenberg Online Distributed',
      'Gutenberg Online Distributed',
      'the Project Gutenberg Online Distributed',
      'Project Gutenberg TEI',
      'This eBook was prepared by',
      'http://gutenberg2000.de erreichbar.',
      'This Etext was prepared by',
      'Gutenberg Distributed Proofreaders',
      'the Project Gutenberg Online Distributed Proofreading Team',
      '**The Project Gutenberg',
      '*SMALL PRINT!',
      'More information about this book is at the top of this file.',
      'tells you about restrictions in how the file may be used.',
      'of the etext through OCR.',
      '*****These eBooks Were Prepared By Thousands of Volunteers!*****',
      'SERVICE THAT CHARGES FOR DOWNLOAD',
      'We need your donations more than ever!',
      ' *** START OF THIS PROJECT GUTENBERG',
      '****     SMALL PRINT!'
    ]

    FOOTER_MARKERS = [
      '*** END OF THE PROJECT GUTENBERG',
      '*** END OF THIS PROJECT GUTENBERG',
      '***END OF THE PROJECT GUTENBERG',
      'End of the Project Gutenberg',
      'End of The Project Gutenberg',
      'by Project Gutenberg',
      'End of Project Gutenberg',
      'End of this Project Gutenberg',
      '        ***END OF THE PROJECT GUTENBERG',
      '*** END OF THE COPYRIGHTED',
      'End of this is COPYRIGHTED',
      '**This is a COPYRIGHTED Project Gutenberg Etext, Details Above**',
      'More information about this book is at the top of this file.',
      'We need your donations more than ever!',
      '<<THIS ELECTRONIC VERSION OF',
      'END OF PROJECT GUTENBERG',
      ' End of the Project Gutenberg',
      ' *** END OF THIS PROJECT GUTENBERG'
    ]

    def self.clean(text)
      strip_headers(text)
    end

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
  end
end
