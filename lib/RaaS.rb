require "active_support/all"
require "andand"

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
    raise InvalidUrl  unless options[:url].starts_with?("http://")
    raise InvalidEndpointUrl  unless options[:endpoint_url].present?
  end
end

module RaaS
  class RaaSError < StandardError
  end

  class InvalidUrl < RaaSError
  end

  class InvalidEndpointUrl < RaaSError
  end
end
