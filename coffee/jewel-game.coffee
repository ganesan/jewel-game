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
  Colors of gems
###
window.eur00t.jewel.COLORS = ['orange', 'brown', 'yellow', 'blue', 'green', 'red']

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
  @board = (@_generateGameBoard eur00t.compiledTemplates.jewel.board, boardW, boardH, size, gap)
  @scoresIndicator = $ eur00t.compiledTemplates.jewel.scores()
  
  @matrix = []
  @marks = []
  
  @size = size
  @gap = gap
  @border = border
  
  @scores = 0
  
  @boardW = boardW
  @boardH = boardH
  
  for i in [0...boardH]
    @matrix.push []
    @marks.push []
    for j in [0...boardW]
      _color = eur00t.jewel.COLORS[eur00t.getRandomInt eur00t.jewel.COLORS.length - 1]
      _item = @_generateItem eur00t.compiledTemplates.jewel.item, size, gap, _color, i, j, border
      _item.data
        i: i
        j: j
      @matrix[i].push _item
      @marks[i].push 0
      @board.append _item
  
  @_initialize()
  
  @
        
window.eur00t.jewel.Game.prototype._generateGameBoard = (template, boardW, boardH, size, gap) ->
  $ template
    width: boardW * (size + 2 * gap)
    height: boardH * (size + 2 * gap)
    
window.eur00t.jewel.Game.prototype._generateItem = (template, size, gap, color, i, j, border) ->
  $ template
    color: eur00t.jewel.COLORS[eur00t.getRandomInt eur00t.jewel.COLORS.length - 1]
    size: size
    gap: gap
    i: i
    j: j
    border: border

window.eur00t.jewel.Game.prototype._cancelPreviousSelect = ->
  @selected.obj.removeClass 'selected'
  @selected.obj = null
  @selected.i = -1
  @selected.j = -1
  
window.eur00t.jewel.Game.prototype._selectItem = (i, j) ->
  @selected.obj = @matrix[i][j]
  @selected.i = i
  @selected.j = j
  @selected.obj.addClass 'selected'
  
window.eur00t.jewel.Game.prototype._setPosition = (elem, i, j) ->
  if elem != null
    elem.css
      left: @gap + j * (@size + 2 * @gap) - @border
      top: @gap + i * (@size + 2 * @gap) - @border
  
window.eur00t.jewel.Game.prototype._swapItems = (i0, j0, i, j) ->
  from = @matrix[i0][j0]
  to = @matrix[i][j]
  @_setPosition from, i, j
  @_setPosition to, i0, j0
  [@matrix[i0][j0], @matrix[i][j]] = [to, from]
  
  from.data
    i: i
    j: j
  
  to.data
    i: i0
    j: j0
    
window.eur00t.jewel.Game.prototype._initMarks = ->
  for i in [0...@boardH]
    for j in [0...@boardW]
      @marks[i][j] = 0
  
  true

window.eur00t.jewel.Game.prototype._processStack = (stack, i, j) ->
  if @marks[i][j] == 0
    @destroy.push 
      obj: @matrix[i][j]
      i: i
      j: j

    @marks[i][j] = 1
    stack.push
      i: i
      j: j
  
  true
      
window.eur00t.jewel.Game.prototype._getStringExceptWords = (string, exceptList) ->
  returnString = string
  for word in exceptList
    returnString = returnString.replace ///#{word}///, ''
  
  returnString

window.eur00t.jewel.Game.prototype._ifEqualType = (i0, j0, i, j) ->
  color0 = @_getStringExceptWords @matrix[i0][j0][0].className, ['jewel', 'selected']
  color = @_getStringExceptWords @matrix[i][j][0].className, ['jewel', 'selected']
  
  color0 = color0.trim ' '
  color = color.trim ' '
  
  if color0 == color
    true
  else false
  
window.eur00t.jewel.Game.prototype._destroyObj = (obj) ->
  obj.obj.fadeOut 1000
  @matrix[obj.i][obj.j] = null
  @scores += 1
  
window.eur00t.jewel.Game.prototype._processDestroyResult = ->
  if @destroy.length >= 2
    @_destroyObj item for item in @destroy
    @scoresIndicator.text(@scores)
    true
  else false

window.eur00t.jewel.Game.prototype._destroyDeep = (i, j) ->
  @_initMarks()
  stack = []
  @destroy = []
  
  @_processStack(stack, i, j)

  while item = stack.pop()
    @_processStack(stack, item.i + 1, item.j) if (item.i + 1 < @boardH) and (@matrix[item.i + 1][item.j] != null) and @_ifEqualType i, j, item.i + 1, item.j
    @_processStack(stack, item.i - 1, item.j) if (item.i - 1 >= 0) and (@matrix[item.i - 1][item.j] != null) and @_ifEqualType i, j, item.i - 1, item.j
    @_processStack(stack, item.i, item.j + 1) if (item.j + 1 < @boardW) and (@matrix[item.i][item.j + 1] != null) and @_ifEqualType i, j, item.i, item.j + 1
    @_processStack(stack, item.i, item.j - 1) if (item.j - 1 >= 0) and (@matrix[item.i][item.j - 1] != null) and @_ifEqualType i, j, item.i, item.j - 1
  
  @_processDestroyResult()

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

window.eur00t.jewel.Game.prototype._destroyLinearVertical = (i, j) ->
  @destroy = []
  
  iteratorI = i + 1
  iteratorJ = j
  
  @_processDestroyDirection i, j, iteratorI, iteratorJ, (i, j) -> 
    iteratorI: i + 1
    iteratorJ: j
  
  iteratorI = i - 1
  
  @_processDestroyDirection i, j, iteratorI, iteratorJ, (i, j) -> 
    iteratorI: i - 1
    iteratorJ: j
  
  @_processDestroyResult()

window.eur00t.jewel.Game.prototype._destroyLinearHorizontal = (i, j) ->
  @destroy = []
  
  iteratorI = i
  iteratorJ = j + 1
  
  @_processDestroyDirection i, j, iteratorI, iteratorJ, (i, j) -> 
    iteratorI: i
    iteratorJ: j + 1
  
  iteratorJ = j - 1
  
  @_processDestroyDirection i, j, iteratorI, iteratorJ, (i, j) -> 
    iteratorI: i
    iteratorJ: j - 1
  
  @_processDestroyResult()
    
window.eur00t.jewel.Game.prototype._checkIfSelectable = (i, j) ->
  if (@selected.obj == null) 
    true
  else if ((@selected.i == i) and (Math.abs(@selected.j - j) < 2)) or ((@selected.j == j) and (Math.abs(@selected.i - i) < 2))
    if @_ifEqualType i, j, @selected.i, @selected.j
      @_cancelPreviousSelect()
      true
    else
      false
  else 
    @_cancelPreviousSelect()
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
        _color = eur00t.jewel.COLORS[eur00t.getRandomInt eur00t.jewel.COLORS.length - 1]
        _item = @_generateItem eur00t.compiledTemplates.jewel.item, @size, @gap, _color, -iterator, j, @border
        @board.append _item
        @matrix[i][j] = _item
        do (i, j) =>
          setTimeout (=> @_setPosition @matrix[i][j], i, j), 100
        @matrix[i][j].data
          i: i
          j: j
        iterator += 1
   
  true
  
window.eur00t.jewel.Game.prototype._destroyAt = (i, j) ->
  destroyedFlag = @_destroyLinearVertical i, j
  destroyedFlag = (@_destroyLinearHorizontal i, j) || destroyedFlag
  
  if destroyedFlag
    @_destroyObj
      obj: @matrix[i][j]
      i: i
      j: j
  
  return destroyedFlag
  
window.eur00t.jewel.Game.prototype._clearBoard = ->
  destroyedFlag = false
  for i in [0...@boardH]
    for j in [0...@boardW]
      if @matrix[i][j] != null
        destroyedFlag = (@_destroyAt i, j) || destroyedFlag
  
  if destroyedFlag
    setTimeout (=> @_compactizeBoard()), 500
    setTimeout (=> @_clearBoard()), 500
            
      
window.eur00t.jewel.Game.prototype._initialize = ->
  @jQueryContainer.append @scoresIndicator
  @jQueryContainer.append @board
  @selected = 
    obj: null
    i: -1
    j: -1
  
  @_clearBoard()

  @board.on 'click', '.jewel', (e) =>
    data = ($ e.target).data()
    i = data.i
    j = data.j
    
    if (@_checkIfSelectable i, j) or (@_ifEqualType i, j, @selected.i, @selected.j)
      @_selectItem i, j
    else
      @_swapItems i, j, @selected.i, @selected.j
      destroyedFlag0 = @_destroyAt i, j
      destroyedFlag = @_destroyAt @selected.i, @selected.j
      
      if (!destroyedFlag0) && (!destroyedFlag)
        setTimeout (=> @_swapItems i, j, @selected.i, @selected.j), 300
      else
        setTimeout (=> @_compactizeBoard(); @_clearBoard()), 500
        @_cancelPreviousSelect()
