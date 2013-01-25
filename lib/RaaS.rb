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
  end
end

module RaaS
  class RaaSError < StandardError
  end

  class InvalidUrl < RaaSError
  end
end
