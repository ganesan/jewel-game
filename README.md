Jewels Game
===========
by [eur00t](http://www.eur00t.com), live version: [http://jewels.eur00t.com](http://jewels.eur00t.com)

The source code for a clone of popular [Bejeweled Game](http://en.wikipedia.org/wiki/Bejeweled) is presented here. 
Use [Ant](http://ant.apache.org/) to build minified library file. Launch
 
	ant build.release
	
This will generate "build/jewels-game.js" and "build/jewels-game-min.js"

Events
------

A number of events can be handled to perform custom actions: 'refresh-scores', 'refresh-wave'. Example of usage:

	$ ->
	  eur00t.template.compileTemplates()
	  window.game = new eur00t.jewels.Game null, 21, 10
	  
	  ($ window.game).on 'refresh-scores', (e, scores) ->
	    console.log "Scores: #{scores}"
	  
	  ($ window.game).on 'refresh-wave', (e, wave) ->
	    console.log "Wave: #{wave}"

See the code for details.