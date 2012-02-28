
#
# CBRAIN Project
#
# Copyright (C) 2008-2012
# The Royal Institution for the Advancement of Learning
# McGill University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.  
#

module DynamicFormHelper
  
  Revision_info=CbrainFileRevision[__FILE__] 
  
  include JavascriptOptionSetup
  
  ##################################################################
  # Creates a submit button with the value specified in the helper
  #
  # ex: <%= submit_button("Move Files") %>
  #
  #
  # This generates: 
  #
  # <input type="submit" value="Move Files" class="button"/>
  #
  ###################################################################
  def submit_button(value,html_opts={}) 
    html_opts[:class] ||= ""
    html_opts[:class] +=  " button"
    atts = html_opts.to_html_attributes
    return "<input type=\"submit\" value=\"#{h(value)}\" #{atts} />".html_safe
  end
  
  
  #Create a checkbox that will select or deselect all checkboxes on the page 
  #of class +checkbox_class+.
  #+options+ are just treated as HTML attributes.
  def select_all_checkbox(checkbox_class, options = {})
    options[:class] ||= ""
    options[:class] +=  " select_all"
    
    options["data-checkbox-class"] = checkbox_class
    atts = options.to_html_attributes 
    
    "<input type='checkbox' #{atts}/>".html_safe
  end
  
  #Create a select box with options +select_options+ that will manipulate
  #all select boxes on the page of class +select_class+ to switch to 
  #share its current selection (if it is one of their options).
  #+options+ are treated as HTML attributes.
  def master_select(select_class, select_options, options = {})
    options[:class] ||= ""
    options[:class] +=  " select_master"
    
    options["data-select-class"] = select_class
    atts = options.to_html_attributes 
    
    result =  "<select #{atts}>\n"
    result += select_options.map{|text| "<option>#{h(text)}</option>"}.join("\n")
    result += "</select>"
    result.html_safe
  end
  
  #Ajax version of form_tag. Takes the exact same options, except for:
  #[:datatype] the datatype expected from the request (HTML, XML, script...).
  #[:method] HTTP method to use for the request.
  #[:target] selector for elements to update prior to or after the
  #         the request is sent.
  def ajax_form_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
    options[:class] ||= ""
    options[:class] +=  " ajax_form"
    options[:remote] = true
    
    data_type = options.delete(:datatype) || "html"
    if data_type
      options["data-type"] = data_type.to_s.downcase
    end
    
    method = options[:method] #NOTE: not deleted, so it can still be used by rails
    if method
      options["data-method"] = method.to_s.upcase
    end
    
    target = options.delete(:target)
    if target
      options["data-target"] = target
    end
    
    overlay = options.delete(:overlay)
    if overlay && overlay.to_s.downcase != "false"
      options["data-target"] = "__OVERLAY__"
    end
    
    width = options.delete(:width)
    if width
      options["data-width"] = width
    end
    
    height = options.delete(:height)
    if height
      options["data-height"] = height
    end
    
    reset_form = options.delete(:reset_form)
    unless reset_form.nil?
      options["data-reset-form"] = reset_form
    end
    
    form_tag(url_for_options, options, *parameters_for_url, &block)
  end
  
  #Ajax version of form_for. Takes the exact same options, except for:
  #[:datatype] the datatype expected from the request (HTML, XML, script...).
  #[:method] HTTP method to use for the request.
  #[:target] selector for elements to update prior to or after the
  #         the request is sent.
  def ajax_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    
    options[:html] ||= {}
    
    options[:html][:class] ||= ""
    options[:html][:class] +=  " ajax_form"
    options[:remote] = true
    
    data_type = options.delete(:datatype) || "html"
    if data_type
      options[:html]["data-type"] = data_type.to_s.downcase
    end
    
    method = options.delete(:method)  #NOTE: not deleted, so it can still be used by rails
    if method
      options[:html]["data-method"] = method.to_s.upcase
    end
    
    target = options.delete(:target)
    if target
      options[:html]["data-target"] = target
    end
    
    overlay = options.delete(:overlay)
    if overlay && overlay.to_s.downcase != "false"
      options[:html]["data-target"] = "__OVERLAY__"
    end
    
    width = options.delete(:width)
    if width
      options[:html]["data-width"] = width
    end
    
    height = options.delete(:height)
    if height
      options[:html]["data-height"] = height
    end
    
    reset_form = options.delete(:reset_form)
    unless reset_form.nil?
      options[:html]["data-reset-form"] = reset_form
    end
    
    args << options
    
    form_for(record_or_name_or_array, *args, &proc)
  end
  
  #A form that assumes it will be submitting to multiple locations
  #and thus does not explicitly define its +action+ attribute.
  #Assumes that all submit buttons will be created using
  #+hijacker_submit_button+ with a +url+ defined.
  def multi_form_tag(options = {}, *parameters_for_url, &block)
    options[:class] ||= ""
    options[:class] +=  " multi_form"
    
    data_type = options.delete(:datatype)
    if data_type
      options["data-type"] = data_type.to_s.downcase
    end
    
    method = options[:method] #NOTE: not deleted, so it can still be used by rails
    if method
      options["data-method"] = method.to_s.upcase
    end
    
    form_tag("#", options, *parameters_for_url, &block)
  end
  
  #A submit button that hijack the submission of the form in which it appears
  #by for example, sending to a different url, requesting a 
  #different data type, changing the http method, etc.
  #
  #
  #Options:
  #[:url] url to submit to.
  #[:datatype] the datatype expected from the request (HTML, XML, script...).
  #[:method] HTTP method to use for the request.
  #[:target] selector for elements to update prior to or after the
  #         the request is sent.
  #[:confirm] Confirm message to display before sending the request.
  #[:ajax_submit] Submit using ajax. Defaults to true.
  def hijacker_submit_button(name, options = {})
    options_setup("hijacker_submit_button", options)
    
    ajax_submit = options.delete(:ajax_submit)
    unless ajax_submit.nil?
      options["data-ajax-submit"] = ajax_submit.to_s
    end
    
    submit_tag(name, options)
  end
  
  #A submit button that can be outside the form it submits,
  #which is defined by +form_id+.
  #
  #Options:
  #[:confirm] Confirm message to display before sending the request.
  def external_submit_button(name, form_id, options = {})
    options_setup("external_submit_button", options)
    
    options["data-associated-form"] = form_id
    
    submit_tag(name, options)
  end

  # Creates a disabled checkbox, which will be checked if
  # +checked+ is present.
  def disabled_checkbox(checked = nil)
    check_box_tag(:dummy_disabled_checkbox, "", checked.present?, :disabled => true)
  end
  
end