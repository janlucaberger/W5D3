require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||=  false
  end

  # Set the response status code and header
  def redirect_to(url)
    raise dup_render_error if already_built_response?
    @res.status = 302
    @res["Location"] = url
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise dup_render_error if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = generate_tempate(self.class, template_name)
    render_content(template, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
  end

  private

  def dup_render_error
    "Error: Trying to render more than once"
  end

  def generate_tempate(controller_class, template)
    controller = controller_class
      .to_s.split("Controller")[0]
      .downcase + "_controller"

    path = "views/#{controller}/#{template.to_s}.html.erb"
    file = File.read(path)
    ERB.new(file).result(binding)
  end
end
