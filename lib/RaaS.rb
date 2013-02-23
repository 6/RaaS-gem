require "active_support/all"
require "andand"
require "cgi"
require "rest-client"

module RaaS
  module_function

  def get(options = {})
    execute(:get, options)
  end

  def post(options = {})
    execute(:post, options)
  end

  def execute(method, options = {})
    validate_params!(method, options)

    options[:method] = :post
    options[:url] = "#{options[:endpoint_url]}/#{method.to_s}?url=#{CGI.escape(options[:url])}"
    [:force, :timeout].each do |param|
      options[:url] += "&#{param.to_s}=#{options[param]}"  if options[param]
      options.delete(param)
    end
    options.delete(:endpoint_url)

    RestClient::Request.execute(options) do |response, request, result, &block|
      validate_response!(response)
      JSON.parse(response.body)
    end
  end

  def validate_params!(method, options)
    raise InvalidUrl  unless options[:url].present?
    raise InvalidUrl  unless options[:url].starts_with?("http://", "https://")
    raise InvalidEndpointUrl  unless options[:endpoint_url].present?
    raise InvalidHttpMethod  unless [:get, :post].include?(method)
  end

  def validate_response!(response)
    raise BadRequest, JSON.parse(response.body)['error']  if response.code == 400
    raise InternalServerError  if response.code >= 500
    raise UnexpectedStatusCode, response.code.to_s  if response.code != 200
  end
end

module RaaS
  class RaaSError < StandardError
  end

  class InvalidUrl < RaaSError
  end

  class InvalidEndpointUrl < RaaSError
  end

  class InvalidHttpMethod < RaaSError
  end

  class BadRequest < RaaSError
  end

  class InternalServerError < RaaSError
  end

  class UnexpectedStatusCode < RaaSError
  end
end
