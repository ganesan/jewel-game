window.eur00t = {} unless window.eur00t?
window.eur00t.jewel = {} unless window.eur00t.jewel?

###
  Get random integer function.
  If supplied 2 arguments: result is in range [from, to]
  If 1 argument: [0, from]
###
window.eur00t.getRandomInt = (from, to) ->
  if arguments.length == 2
    from + Math.floor Math.random() * (to - from + 1)
  else if arguments.length == 1
    Math.floor Math.random() * (from + 1)
  else 0

###
  Colors of gems. Each color has correspondent CSS class.
###
window.eur00t.jewel.COLORS = ['orange', 'brown', 'yellow', 'blue', 'green', 'red']

###
  Value of game speed.
###
window.eur00t.jewel.SPEED = 600

###
  Main game constructor.
  
  jQueryContainer: append game to this container ($(document.body) default)
  boardW, boardH: width and height of board in item units (8x8 default)
  size: size of gem item (60 default)
  gap: gap between gems (2 default)
  border: value of gem's border
###
window.eur00t.jewel.Game = (jQueryContainer = $(document.body), boardW = 8, boardH = 8, size=60, gap=2, border=1) ->
  @jQueryContainer = jQueryContainer;
  @board = @_generateGameBoard eur00t.compiledTemplates.jewel.board, boardW, boardH, size, gap
  @scoresIndicator = $ eur00t.compiledTemplates.jewel.scores()
  
  @matrix = []
  
  @size = size
  @gap = gap
  @border = border
  
  @scores = 0
  
  @boardW = boardW
  @boardH = boardH
  
  # Initialize @matrix variable, construct @board
  for i in [0...boardH]
    @matrix.push []
    for j in [0...boardW]
      _item = @_generateItem eur00t.compiledTemplates.jewel.item, size, gap, i, j, border
      _item.elem.data
        i: i
        j: j
        color: _item.data.color
      @matrix[i].push _item.elem
      @board.append _item.elem
  
  @_initialize()
  
  @
        
window.eur00t.jewel.Game.prototype._generateGameBoard = (template, boardW, boardH, size, gap) ->
  $ template
    width: boardW * (size + 2 * gap)
    height: boardH * (size + 2 * gap)
    
window.eur00t.jewel.Game.prototype._generateItem = (template, size, gap, i, j, border) ->
  color = eur00t.jewel.COLORS[eur00t.getRandomInt eur00t.jewel.COLORS.length - 1]
  
  elem: $ template
    color: color
    size: size
    gap: gap
    i: i
    j: j
    border: border
  data:
    color: color

window.eur00t.jewel.Game.prototype._cancelPreviousSelect = ->
  if @selected.obj?
    @selected.obj.removeClass 'selected' if @selected.obj?
    @selected.obj = null
    @selected.i = -1
    @selected.j = -1
    true
  else false
  
window.eur00t.jewel.Game.prototype._selectItem = (i, j) ->
  @_cancelPreviousSelect()
  
  @selected.obj = @matrix[i][j]
  @selected.i = i
  @selected.j = j
  @selected.obj.addClass 'selected'
  
window.eur00t.jewel.Game.prototype._setPosition = (elem, i, j) ->
  if elem != null
    elem.css
      left: @gap + j * (@size + 2 * @gap) - @border
      top: @gap + i * (@size + 2 * @gap) - @border
    
    elem.data
      i: i
      j: j
  
window.eur00t.jewel.Game.prototype._swapItems = (i0, j0, i, j) ->
  from = @matrix[i0][j0]
  to = @matrix[i][j]
  
  @_setPosition from, i, j
  @_setPosition to, i0, j0
  
  [@matrix[i0][j0], @matrix[i][j]] = [to, from]
  
  true
    
window.eur00t.jewel.Game.prototype._ifEqualType = (i0, j0, i, j) ->
  @matrix[i0][j0].data('color') == @matrix[i][j].data('color')
  
window.eur00t.jewel.Game.prototype._destroyObj = (obj, hidden) ->
  if !hidden
    obj.obj.fadeOut window.eur00t.jewel.SPEED
    @scores += 1
  else
    obj.obj.remove()
  @matrix[obj.i][obj.j] = null

window.eur00t.jewel.Game.prototype._refreshScores = ->
  @scoresIndicator.children('h2').text(@scores)

window.eur00t.jewel.Game.prototype._processDestroyResult = (hidden) ->
  if @destroy.length >= 2
    @_destroyObj item, hidden for item in @destroy
    true
  else false

window.eur00t.jewel.Game.prototype._processDestroyDirection = (i, j, iteratorI, iteratorJ, postIteration) ->
  while (0 <= iteratorI < @boardH) and (0 <= iteratorJ < @boardW) and (@matrix[iteratorI][iteratorJ] != null) and (@_ifEqualType i, j, iteratorI, iteratorJ)
    @destroy.push 
      obj: @matrix[iteratorI][iteratorJ]
      i: iteratorI
      j: iteratorJ
    
    newIterators = postIteration iteratorI, iteratorJ
    
    iteratorI = newIterators.iteratorI
    iteratorJ = newIterators.iteratorJ
  
  true

window.eur00t.jewel.Game.prototype._destroyLinearVertical = (i, j, hidden) ->
  @destroy = []
  
  @_processDestroyDirection i, j, i + 1, j, (i, j) -> 
    iteratorI: i + 1
    iteratorJ: j
  
  @_processDestroyDirection i, j, i - 1, j, (i, j) -> 
    iteratorI: i - 1
    iteratorJ: j
  
  @_processDestroyResult(hidden)

window.eur00t.jewel.Game.prototype._destroyLinearHorizontal = (i, j, hidden) ->
  @destroy = []
  
  @_processDestroyDirection i, j, i, j + 1, (i, j) -> 
    iteratorI: i
    iteratorJ: j + 1
  
  @_processDestroyDirection i, j, i, j - 1, (i, j) -> 
    iteratorI: i
    iteratorJ: j - 1
  
  @_processDestroyResult(hidden)
    
window.eur00t.jewel.Game.prototype._checkIfSelectable = (i, j, hidden) ->
  if (@selected.obj == null) 
    true
  else if ((@selected.i == i) and (Math.abs(@selected.j - j) < 2)) or ((@selected.j == j) and (Math.abs(@selected.i - i) < 2))
    if (i == @selected.i) and (j == @selected.j)
      @_cancelPreviousSelect()
      false
    else
      if @_ifEqualType i, j, @selected.i, @selected.j
        true
      else
        false
  else 
    true
    
window.eur00t.jewel.Game.prototype._compactizeBoard = ->
  newMatrix = []
  for j in [0...@boardW]
    newMatrix.push []
    for i in [@boardH - 1..0]
      if @matrix[i][j] != null
        newMatrix[j].push @matrix[i][j]
  
  for j in [0...@boardW]
    iterator = 0
    for i in [@boardH - 1...@boardH - 1 - newMatrix[j].length]
      @matrix[i][j] = newMatrix[j][iterator]
      @_setPosition @matrix[i][j], i, j
      @matrix[i][j].data
        i: i
        j: j
      iterator += 1
    
    if (@boardH - 1 - newMatrix[j].length) >= 0
      iterator = 1
      for i in [@boardH - 1 - newMatrix[j].length..0]
        _item = @_generateItem eur00t.compiledTemplates.jewel.item, @size, @gap, -iterator, j, @border
        @board.append _item.elem
        @matrix[i][j] = _item.elem
        
        _item.elem.data
          color: _item.data.color
          
        do (i, j) =>
          setTimeout (=> @_setPosition @matrix[i][j], i, j), 0
          
        iterator += 1
   
  true
  
window.eur00t.jewel.Game.prototype._destroyAt = (i, j, hidden) ->
  destroyedFlag = @_destroyLinearVertical i, j, hidden
  destroyedFlag = (@_destroyLinearHorizontal i, j, hidden) || destroyedFlag
  
  if destroyedFlag
    @_destroyObj {
      obj: @matrix[i][j]
      i: i
      j: j
    }, hidden
      
  @_refreshScores() if !hidden
  return destroyedFlag
  
window.eur00t.jewel.Game.prototype._clearBoard = (hidden) ->
  destroyedFlag = false
  for i in [0...@boardH]
    for j in [0...@boardW]
      if @matrix[i][j] != null
        destroyedFlag = (@_destroyAt i, j, hidden) || destroyedFlag
  
  if destroyedFlag
    if !hidden
      setTimeout (=> @_compactizeBoard()), window.eur00t.jewel.SPEED / 2
      setTimeout (=> @_clearBoard()), window.eur00t.jewel.SPEED / 2
    else
      @_compactizeBoard()
      @_clearBoard(hidden)
      
window.eur00t.jewel.Game.prototype._initialize = ->
  @jQueryContainer.append @scoresIndicator
  @jQueryContainer.append @board
  
  @selected = 
    obj: null
    i: -1
    j: -1
    
  @_refreshScores()
  @_clearBoard(true)

  @board.on 'click', '.jewel', (e) =>
    data = ($ e.target).data()
    i = data.i
    j = data.j
    
    if @_checkIfSelectable i, j
      @_selectItem i, j
    else
      @_swapItems i, j, @selected.i, @selected.j
      destroyedFlag0 = @_destroyAt i, j
      destroyedFlag = @_destroyAt @selected.i, @selected.j
      
      if (!destroyedFlag0) && (!destroyedFlag)
        do (selectedI = @selected.i, selectedJ = @selected.j) =>
          setTimeout (=> @_swapItems i, j, selectedI, selectedJ;), 300
        @_cancelPreviousSelect()
      else
        setTimeout (=> @_compactizeBoard(); @_clearBoard()), window.eur00t.jewel.SPEED / 2
        @_cancelPreviousSelect()
