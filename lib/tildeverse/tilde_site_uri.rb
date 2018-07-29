#!/usr/bin/env ruby

module Tildeverse
  ##
  # Wrapper class for Ruby's URI module.
  # Adds some functionality specific to Tilde user list URIs.
  #
  # Delegates missing methods to the underlying
  # {URI}[https://ruby-doc.org/stdlib-2.3.3/libdoc/uri/rdoc/URI.html]
  # instance {#uri}
  #
  class TildeSiteURI
    ##
    # @return [URI] the URI of the user list.
    #   All other attributes are based on this by default.
    #
    attr_reader :uri

    ##
    # @!attribute name
    # @return [String] the name of the website
    # @example
    #   'example.com'
    #   'tilde.town'

    ##
    # @!attribute root
    # @return [String] the root URL of the website
    # @example
    #   'http://example.com/'
    #   'https://tilde.town/'

    ##
    # @!attribute list
    # @return [String] the URL of the user list
    # @example
    #   'http://example.com/users.html'
    #   'https://tilde.town/~dan/users.json'

    ##
    # @!attribute homepage_format
    # @return [String]
    #   the format that the site uses to map users to their homepage.
    # @example
    #   'https://tilde.town/~USER/'
    #   'https://USER.remotes.club/'

    ##
    # Make setters and getters that default to method +default_<attr>+
    # if not explicitly set. This way users of the class can specify their
    # own values if the defaults are not appropriate.
    #
    # Because the code is using ||, a variable can be restored to the
    # default by setting its value to nil.
    #
    def self.use_default_if_missing(attr)
      class_eval(<<-CODE, __FILE__, __LINE__ + 1)
        def #{attr}=(val)
          @#{attr} = val
        end
        def #{attr}
          @#{attr} || default_#{attr}
        end
      CODE
    end
    use_default_if_missing(:name)
    use_default_if_missing(:root)
    use_default_if_missing(:list)
    use_default_if_missing(:homepage_format)

    ##
    # @param [String, URI] uri
    #   {URI}[https://ruby-doc.org/stdlib-2.3.3/libdoc/uri/rdoc/URI.html]
    #   object to which this class acts as a wrapper. If an object other
    #   than a URI is passed, it will attempt to convert it to one.
    #
    def initialize(uri)
      @uri = uri.is_a?(URI::HTTP) ? uri : URI(URI.escape(uri))
      validate_uri
    rescue
      raise(NotHTTPError)
    end

    ############################################################################

    ##
    # Use {#homepage_format} to map the user to their homepage URL.
    #
    # @param [String] user The name of the user.
    # @return [String] user's homepage.
    # @example
    #   site = TildeSiteURI.new('http://tilde.town/~dan/users.json')
    #   site.homepage('imt')
    #   # => 'https://tilde.town/~imt/'
    # @example
    #   site = TildeSiteURI.new('https://www.remotes.club/')
    #   site.homepage_format = 'https://USER.remotes.club/'
    #   site.homepage('imt')
    #   # => 'https://imt.remotes.club/'
    #
    def homepage(user)
      output = homepage_format.sub('USER', user)

      # Throw error if 'homepage_format' does not contain USER substring.
      if homepage_format == output
        msg  = '#homepage_format should replace USER in the format eg: '
        msg += 'http://www.example.com/~USER/'
        raise ArgumentError, msg
      end
      output
    end

    ##
    # Use {#name} to map the user to their email address
    #
    # @param [String] user The name of the user
    # @return [String] user's email address
    # @example
    #   site = TildeSiteURI.new('http://tilde.town/~dan/users.json')
    #   site.email('nossidge')
    #   # => 'nossidge@tilde.town'
    # @note
    #   On most Tilde servers, this is valid for local email only
    #
    def email(user)
      user.to_s + '@' + name
    end

    ############################################################################

    private

    def default_name
      uri.host.sub(/^www\./, '')
    end

    def default_root
      uri.scheme + '://' + uri.host
    end

    def default_list
      uri.to_s
    end

    def default_homepage_format
      root + '/~USER/'
    end

    # Raise an error if the URI is not the correct type
    def validate_uri
      return true if uri.is_a?(URI::HTTP)
      raise NotHTTPError
    end

    # Exception to raise on invalid URI input
    class NotHTTPError < URI::InvalidURIError
      def initialize(msg = 'Tilde URI must be HTTP or HTTPS')
        super msg
      end
    end

    # Delegate unknown methods to the {#uri} instance
    def method_missing(method, *args)
      if uri.respond_to?(method)
        uri.send(method, *args)
      else
        raise NoMethodError, method
      end
    end

    # Respond to unknown methods as the {#uri} instance
    def respond_to_missing?(method, include_private = false)
      return true if uri.respond_to?(method)
      super
    end
  end
end
