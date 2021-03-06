module BooksAdapters

  class WorkerAdapter

    def get_books(title)
      begin
        url = get_url(title)
        url = URI.encode url
        url = URI(url)
        response = Net::HTTP.get url

        JSON::parse(response)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise Errors::NetworkError
      rescue JSON::ParserError
        raise Errors::InvalidBooks
      end
    end

    protected
    def get_url(title)
      "http://worker.101companies.org/services/termResources/#{title}.json"
    end

  end

end
