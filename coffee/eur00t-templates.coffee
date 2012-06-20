###
 Templating Module.
 
 namespace: eur00t.template
 
 eur00t.template.compileTemplatesRec (source, target)
    source - object with template strings
    target - object which will be consist of compiled template functions.
    
 eur00t.templates.compileTemplates
    compiles templates from "eur00t.templates" to "eur00t.compiledTemplates"
###

window.eur00t = {} unless window.eur00t?
window.eur00t.template = {} unless window.eur00t.template?

window.eur00t.template.compileTemplatesRec = (source, target) ->
  if _?.template?
    for own name, template of source
      if typeof template == 'string'
        target[name] = _.template template
      else if (typeof template == 'object') and (template isnt null)
        target[name] = {}
        window.eur00t.template.compileTemplatesRec template, target[name]
  else
    throw new Error 'Underscore Microtemplates is missing.'
  true

window.eur00t.template.compileTemplates = () ->
  if window.eur00t.templates?
    window.eur00t.compiledTemplates = {} unless window.eur00t.compiledTemplates?
    window.eur00t.template.compileTemplatesRec window.eur00t.templates, window.eur00t.compiledTemplates
  true