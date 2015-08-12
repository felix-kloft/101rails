require 'rails_helper'

describe Page do

  before(:each) do

  end

  describe 'preparing_the_page' do

    it 'parses the page' do
      page = create :page

      expect(page.used_links).to include("Abstraction",
                                         "MemberOf::Vocabulary:Programming",
                                         "RelatesTo::Result",
                                         "IsA::Concept")
    end

  end

  describe 'describe render page' do

    it 'renders the page' do
      page = create :page

      expect(page.render).to include('abstraction')
    end

  end

  describe 'get_metadata_section' do

    it 'gives the section if metadata exists' do
      page = create :page

      expect(page.get_metadata_section).not_to be_nil
    end

    it 'gives nil if metadata does not exists' do
      page = create :page_without_metadata

      expect(page.get_metadata_section).to be_nil
    end

  end

  describe 'inject_triple' do

    it 'inserts a triple into a page with metadata' do
      page = create :page

      page.inject_triple 'instanceOf::something'
      page.parse
      expect(page.get_metadata_section['content']).to include("[[instanceOf::something]]")
    end

    it 'inserts a triple into a page without metadata' do
      page = create :page_without_metadata

      page.inject_triple 'instanceOf::something'
      page.parse
      expect(page.get_metadata_section['content']).to include("[[instanceOf::something]]")
    end

  end

  describe 'decorate_headline' do

    it 'cuts too long headline' do
      page = create :page_with_long_headline

      result = page.decorate_headline page.title

      expect(result).to include('...')
      expect(result.length).to eq(254)
    end

    it 'does nothing for short headlines' do
      page = create :page

      result = page.decorate_headline page.title

      expect(result).to eq(page.title)
    end

  end

  describe 'get_headline' do

    it 'gets headline' do
      page = create :page

      result = page.get_headline

      expect(result).to eq('The argument of an abstraction')
    end

    it 'gets no headline' do
      page = create :page_with_no_headline

      result = page.get_headline

      expect(result).to include('No headline found')
    end

  end

  describe 'full_title' do

    it 'gets full title for normal page' do
      page = create :page

      result = page.full_title

      expect(result).to include(page.title, page.namespace)
    end

    it 'gets full title for concept page' do
      page = create :concept_page

      result = page.full_title

      expect(result).to eq(page.title)
    end

  end

end
