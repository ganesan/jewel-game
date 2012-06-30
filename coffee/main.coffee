
$ ->
  eur00t.template.compileTemplates()
  window.game = new eur00t.jewels.Game null, 21, 10
  
  ($ window.game).on 'refresh-scores', (e, scores) ->
    console.log "Scores: #{scores}"
  
  ($ window.game).on 'refresh-wave', (e, wave) ->
    console.log "Wave: #{wave}"
  
    
    
  