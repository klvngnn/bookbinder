require_relative '../../../../lib/bookbinder/preprocessing/subnav_json_generator'
require_relative '../../../../lib/bookbinder/html_document_manipulator'
require 'nokogiri'

module Bookbinder
  module Preprocessing
    describe SubnavJsonGenerator do
      describe 'formatting a subnav' do
        def subnav_formatter
          SubnavJsonGenerator.new
        end

        it 'applies the appropriate CSS classes, wraps divs, and creates anchor paths from root' do
          toc_text = File.read('spec/fixtures/subnav_templates/tocjs_subnav.html')
          expected_processed_toc_text = File.read('spec/fixtures/subnav_templates/formatted_tocjs_subnav.json')

          expect(subnav_formatter.get_links_as_json(toc_text, "sample-section").gsub(/\s+/, '')).to eq expected_processed_toc_text.gsub(/\s+/, "")
        end
      end
    end
  end
end
