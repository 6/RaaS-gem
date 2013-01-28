require "active_support/all"
require "andand"
require "cgi"
require "rest-client"

module RaaS
  module_function

  def get(options = {})
    self.execute(:get, options)
  end

  def post(options = {})
    self.execute(:post, options)
  end

  def execute(method, options = {})
    raise InvalidUrl  unless options[:url].present?
    raise InvalidUrl  unless options[:url].starts_with?("http://", "https://")
    raise InvalidEndpointUrl  unless options[:endpoint_url].present?
    raise InvalidHttpMethod  unless [:get, :post].include?(method)

    options[:method] = :post
    options[:url] = "#{options[:endpoint_url]}/#{method.to_s}?url=#{CGI.escape(options[:url])}"
    [:force, :timeout].each do |param|
      options[:url] += "&#{param.to_s}=#{options[param]}"  if options[param]
    end
    options.delete(:endpoint_url)
    options.delete(:force)

    RestClient::Request.execute(options) do |response, request, result, &block|
      raise BadRequest.new(JSON.parse(response.body)['error'])  if response.code == 400
      raise InternalServerError  if response.code >= 500
      raise UnexpectedStatusCode  if response.code != 200
      JSON.parse(response.body)
    end
  end
end

module RaaS
  class RaaSError < StandardError
    def initialize(*args)
      super
    end
  end

  class InvalidUrl < RaaSError
  end

  class InvalidEndpointUrl < RaaSError
  end

  class InvalidHttpMethod < RaaSError
  end

  class BadRequest < RaaSError
    def initialize(*args)
      super
    end
  end

  class InternalServerError < RaaSError
  end

  class UnexpectedStatusCode < RaaSError
  end
end
