class PagesController < ApplicationController

  include RdfModule

  respond_to :json, :html

  # order of next two lines is very important!
  # before_filter need to be before load_and_authorize_resource
  before_filter :get_the_page
  # methods, that need to check permissions
  load_and_authorize_resource :only => [:delete, :rename, :update]

  def get_the_page
    # if no title -> set default wiki startpage '@project'
    full_title = params[:id].nil? ? '@project' : params[:id]
    @page = PageModule.find_by_full_title full_title
    # page not found and user can create page -> create new page by full_title
    @page = PageModule.create_page_by_full_title full_title if @page.nil? && (can? :create, Page.new)
    # if no page created/found
    if !@page
      respond_to do |format|
        format.html do
          flash[:error] = "Page wasn't not found. Redirected to main wiki page"
          go_to_homepage
        end
        format.json { render :json => {success: false}, :status => 404 }
      end
    end

  end

  def get_rdf
    title = params[:id]
    graph_to_return = RDF::Graph.new
    get_rdf_graph(title).each do |st|
      graph_to_return << (st.subject.to_s === "IN" ? (reverse_statement st, title) : st)
    end
    respond_with graph_to_return.dump(:ntriples)
  end

  def get_json
    title = params[:id]
    directions = params[:directions]
    json = []
    get_rdf_graph(title, directions).each do |res|
      if directions
        json << { :direction => res.subject.to_s, :predicate => res.predicate.to_s, :node => res.object.to_s }
      else
        # ingoing triples
        res = reverse_statement res, title if res.subject.to_s == 'IN'
        json << [ res.subject.to_s, res.predicate.to_s, res.object.to_s ]
      end
    end
    respond_with json
  end

  def delete
    result = @page.delete
    # generate message if deleting was successful
    flash[:notice] = 'Page ' + @page.full_title + ' was deleted' if result
    render :json => {:success => result}
  end

  def show
    respond_to do |format|
      format.html {
        # if need redirect? -> wiki url conventions -> do a redirect
        good_link = @page.nice_wiki_url
        if good_link != params[:id]
          redirect_to '/wiki/'+ good_link and return
        end
        # no redirect? -> render the page
        render :html => @page
      }

      last_change = @page.page_changes.last
      if last_change
        history_entry = {
            user_name: last_change.user.name,
            user_pic: last_change.user.github_avatar,
            user_email: last_change.user.email,
            created_at: last_change.created_at
        }
      else
        history_entry = {}
      end

      format.json { render :json => {
        'id'        => @page.full_title,
        'content'   => @page.raw_content,
        'sections'  => @page.sections,
        'history'   => history_entry,
        'backlinks' => @page.backlinks
      }}

    end
  end

  def parse
    parsed_page = @page.create_wiki_parser params[:content]
    parsed_page.sections.first.auto_toc = false
    html = parsed_page.to_html
    # mark empty or non-existing page with class missing-link (red color)
    parsed_page.internal_links.each do |link|
      nice_link = PageModule.nice_wiki_url link
      used_page = PageModule.find_by_full_title nice_link
      # if not found page or it has no content
      # set in class_attribute additional class for link (mark with red)
      class_attribute = (used_page.nil? || used_page.raw_content.nil?) ? 'class="missing-link"' : ''
      # replace page links in html
      html.gsub! "<a href=\"#{link}\"", "<a #{class_attribute} href=\"/wiki/#{nice_link}\""
      html.gsub! "<a href=\"#{link.camelize(:lower)}\"", "<a #{class_attribute} href=\"/wiki/#{nice_link}\""
    end
    render :json => {:success => true, :html => html.html_safe}
  end

  def search
    @query_string = params[:q]
    if @query_string == ''
      flash[:notice] = 'Please write something, if you want to search something'
      go_to_homepage
    else
      @search_results = PageModule.search @query_string
      respond_with @search_results
    end
  end

  def summary
    render :json => {:sections => @page.sections, :internal_links => @page.internal_links}
  end

  # get all sections for a page
  def sections
    respond_with @page.sections
  end

  # get all internal links for the page
  def internal_links
    respond_with @page.internal_links
  end

  def update
    sections = params[:sections]
    content = params[:content]
    new_full_title = PageModule.unescape_wiki_url params[:newTitle]

    history_track = @page.create_track current_user
    result = @page.update_or_rename_page(new_full_title, content, sections)
    history_track.save if result

    # TODO: renaming -> check used page
    render :json => {
      :success => result,
      :newTitle => @page.nice_wiki_url
    }
  end

  def section
    respond_with ({:content => @page.section(params[:full_title])}).to_json
  end

end
