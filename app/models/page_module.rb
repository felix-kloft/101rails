# this module includes all static methods for pages

class PageModule
  require 'media_wiki'

  def self.match_page_score(found_page, query_string)
    # find match ignoring case
    score = found_page.full_title.downcase.index query_string.downcase
    # not found match in title, make score worst
    if score == nil
      score = 10000
    end
    # exact match -> best score (lowest)
    if found_page.full_title.downcase == query_string.downcase
      score = -1
    end
    score
  end

  def self.contribution_array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
  end

  # if no namespace given
  # starts with '@' ? -> use namespace '101'
  # else -> use default namespace 'Concept'
  def self.retrieve_namespace_and_title(full_title)
    full_title_parts = full_title.split(':')
    # retrieve amount of splits
    amount_of_full_title_parts = full_title_parts.count
    # amount_of_full_title_parts == 0 or amount_of_full_title_parts > 2
    # retrieved namespace and title
    if amount_of_full_title_parts == 2
      namespace = full_title_parts[0]
      title = full_title_parts[1]
      # no namespace retrieved, amount_of_full_title_parts == 1
    else
      # then entire param is title
      title = full_title_parts[0]
      # and namespace need to be defined in this way
      # if title starts with '@' -> '101'
      # else namespace will be set to default value 'Concept'
      namespace = title[0] == "@" ?  "101" : "Concept"
    end
    { 'namespace' => namespace, 'title' => title }
  end

  def self.default_contribution_text(url)
    "You have created new contribution using [https://github.com Github]. " +
        "Source code for this contribution you can find [#{url} here]."
  end

  def self.search(query_string)
    begin
      found_pages = Page.full_text_search query_string
    rescue
      found_pages = nil
    end
    # nothing found -> go out
    if found_pages.nil?
      return []
    end
    results = []
    found_pages.each do |found_page|
      # do not show pages without content
      if found_page.raw_content.nil?
        next
      end
      score = PageModule.match_page_score found_page, query_string
      # prepare array wit results
      results << {
          :title => found_page.full_title,
          :link  => found_page.url,
          # more score -> worst result
          :score => score
      }
    end
    # sort by score and return
    results.sort_by { |a| a[:score] }
  end

  # link for using in html rendering
  # replace ' ' with '_', remove trailing spaces
  def self.url title
    self.unescape_wiki_url(title).strip.gsub(' ', '_')
  end

  def self.escape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, MediaWiki::wiki_to_uri(full_title)
  end

  def self.unescape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, MediaWiki::uri_to_wiki(full_title)
  end

  def self.create_page_by_full_title(full_title)
    page = Page.new
    full_title = self.unescape_wiki_url full_title
    namespace_and_title = self.retrieve_namespace_and_title full_title
    page.title = namespace_and_title['title']
    page.namespace = namespace_and_title['namespace']
    page.save ? page : nil
  end

  # find page without creating
  def self.find_by_full_title(full_title)
    full_title = (self.unescape_wiki_url full_title).strip
    nt = self.retrieve_namespace_and_title full_title
    Page.where(namespace: nt['namespace'], title: nt['title']).first
  end

  def self.uncapitalize_first_char(string)
    string[0,1].downcase + string[1..-1]
  end
  
end
