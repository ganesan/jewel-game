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
  To add new gem type put new color name here and CSS class into main.css.
###
window.eur00t.jewel.COLORS = ['orange', 'brown', 'yellow', 'blue', 'green', 'red']

###
  Value of game speed. 
###
window.eur00t.jewel.SPEED = 300

###
  Main game constructor.
  
  jQueryContainer: append game to this container ($(document.body) default)
  boardW, boardH:  width and height of board in item units (8x8 default)
  size:            size of gem item (60 default)
  gap:             gap between gems (2 default)
  border:          value of gem's border
  
  NOTE: you should compile templates to use this constructor. Template module is located in 
  eur00t-templates.coffee file. Templates themselves are located in templates.coffee
  
  Example of usage:
  
    eur00t.template.compileTemplates()
    window.game = new eur00t.jewel.Game null, 21, 10
###
window.eur00t.jewel.Game = (jQueryContainer = $(document.body), boardW = 8, boardH = 8, size=60, gap=2, border=2) ->
  @jQueryContainer = jQueryContainer;
  
  @board = @_generateGameBoard eur00t.compiledTemplates.jewel.board, boardW, boardH, size, gap
  
  # The score indicator. 
  @scoresIndicator = $ eur00t.compiledTemplates.jewel.scores()
  
  # This is matrix for elements of board. If (i, j) is empty, @matrix[i][j] equal null.
  @matrix = []
  
  @size = size
  @gap = gap
  @border = border
  
  # The scores variable. Each destroyed gem adds 1 to total score.
  @scores = 0
  
  @boardW = boardW
  @boardH = boardH
  
  # Initialize @matrix variable, fill @board with gem items.
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

###
  Generate DOM structure for game board.
  
  template:       compiled template function
  boardW, boardH: size of board in gem element units
  size:           size of gem element in pixels
  gap:            a gap value in pixels between gem elements
  
  return value:   jQuery wrapper for generated DOM element
###
window.eur00t.jewel.Game.prototype._generateGameBoard = (template, boardW, boardH, size, gap) ->
  $ template
    width: boardW * (size + 2 * gap)
    height: boardH * (size + 2 * gap)

###
  Generate new gem item.
  
  template: compiled template function
  size:     size of gem element in pixels
  gap:      a gap value in pixels between gem elements
  i,j:      coordinates of element
  border:   a value of element's border in pixels
  
  return value: {
    elem: <jQuery wraper>,
    data: {
      color: <color value>
    }
  }
###
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

# Cancel privious selection. Returns system into unselected state.
window.eur00t.jewel.Game.prototype._cancelPreviousSelect = ->
  if @selected.obj?
    @selected.obj.removeClass 'selected' if @selected.obj?
    @selected.obj = null
    @selected.i = -1
    @selected.j = -1
    true
  else false

# Select item at (i, j) coordinates
window.eur00t.jewel.Game.prototype._selectItem = (i, j) ->
  @_cancelPreviousSelect()
  
  @selected.obj = @matrix[i][j]
  @selected.i = i
  @selected.j = j
  @selected.obj.addClass 'selected'

# Set position of elem to (i, j)
window.eur00t.jewel.Game.prototype._setPosition = (elem, i, j) ->
  if elem != null
    elem.css
      left: @gap + j * (@size + 2 * @gap) - @border
      top: @gap + i * (@size + 2 * @gap) - @border
    
    elem.data
      i: i
      j: j

# Swap position of two elements
window.eur00t.jewel.Game.prototype._swapItems = (i0, j0, i, j) ->
  from = @matrix[i0][j0]
  to = @matrix[i][j]
  
  @_setPosition from, i, j
  @_setPosition to, i0, j0
  
  [@matrix[i0][j0], @matrix[i][j]] = [to, from]
  
  true

# Check if elements with coords (i0, j0) and (i, j) have equal color
window.eur00t.jewel.Game.prototype._ifEqualType = (i0, j0, i, j) ->
  @matrix[i0][j0].data('color') == @matrix[i][j].data('color')

###
  Destroy object at (i, j) position.
  
  i, j:      coordinates of element to be distroyed
  hidden:    destroy object without animation.
  nospecial: do not perform special actions if true
  
  return value:
    true  - if element is destroyed
    false - if not
###
window.eur00t.jewel.Game.prototype._destroyObj = (i, j, hidden, nospecial) ->
  if (0 <= i < @boardH) && (0 <= j < @boardW) && (@matrix[i][j] isnt null)
    @_processSpecial i, j if !nospecial
    if !hidden
      # jQuery fadeout effect
      @matrix[i][j].fadeOut window.eur00t.jewel.SPEED
      @scores += 1
    else
      # remove silently
      @matrix[i][j].remove()
    @matrix[i][j] = null
    true
  else false

# Update GUI score indicator
window.eur00t.jewel.Game.prototype._refreshScores = ->
  @scoresIndicator.children('h2').text(@scores)

###
  Process elements that are queued for deletion.
  
  hidden: flag for silent mode without delays and effects
  
  return value: {
    destroyed: <true if elements were destroyed>,
    count: <a number of destroyed elements>
  }
###
window.eur00t.jewel.Game.prototype._processDestroyResult = (hidden) ->
  # a number of destroyed elements
  destroyedCounter = 0
  
  # @destroyH - an horizontal line of destroyed elements
  # @destroyH - an vertical line
  # Perform destroy action only if more than 1 elemt is destroyed
  if (@destroyH.length >= 2) || (@destroyV.length >= 2)
    if @destroyH.length >= 2
      @_destroyObj obj.i, obj.j, hidden for obj in @destroyH
      destroyedCounter += @destroyH.length
    
    if @destroyV.length >= 2
      @_destroyObj obj.i, obj.j, hidden for obj in @destroyV 
      destroyedCounter += @destroyV.length
      
    destroyed: true
    count: destroyedCounter
  else
    destroyed: false
    count: 0

###
  Destroy iteration check function.
  
  destroyArr:           a collection of destroyed elements that are currently processing
  i, j:                 an elements that initiates deletion
  iteratorI, iteratorJ: the position of current element that is checked
  postIteration:        function, that calculates next value of iteratorI and iteratorJ
###
window.eur00t.jewel.Game.prototype._processDestroyDirection = (destroyArr, i, j, iteratorI, iteratorJ, postIteration) ->
  while (0 <= iteratorI < @boardH) and (0 <= iteratorJ < @boardW) and (@matrix[iteratorI][iteratorJ] != null) and (@_ifEqualType i, j, iteratorI, iteratorJ)
    destroyArr.push 
      i: iteratorI
      j: iteratorJ
    
    newIterators = postIteration iteratorI, iteratorJ
    
    iteratorI = newIterators.iteratorI
    iteratorJ = newIterators.iteratorJ
  
  true

# Find vertical elements to destroy
window.eur00t.jewel.Game.prototype._destroyLinearVertical = (i, j, hidden) ->
  @_processDestroyDirection @destroyV, i, j, i + 1, j, (i, j) -> 
    iteratorI: i + 1
    iteratorJ: j
  
  @_processDestroyDirection @destroyV, i, j, i - 1, j, (i, j) -> 
    iteratorI: i - 1
    iteratorJ: j
  
  true

# Find horizontal elements to destroy
window.eur00t.jewel.Game.prototype._destroyLinearHorizontal = (i, j, hidden) ->
  @_processDestroyDirection @destroyH, i, j, i, j + 1, (i, j) -> 
    iteratorI: i
    iteratorJ: j + 1
  
  @_processDestroyDirection @destroyH, i, j, i, j - 1, (i, j) -> 
    iteratorI: i
    iteratorJ: j - 1

  true

# Check if (i, j) is elements that can be selected
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

###
  This method perform following actions:
  1. Place all available items donw in regard of empty cells.
  2. Generate new items to fill empty space.
###
window.eur00t.jewel.Game.prototype._compactizeBoard = ->
  newMatrix = []
  
  # collect all remaining elements into newMatrix. newMatrix[j] is elements from column number j
  for j in [0...@boardW]
    newMatrix.push []
    for i in [@boardH - 1..0]
      if @matrix[i][j] != null
        newMatrix[j].push @matrix[i][j]
  
  # iterate over each column
  for j in [0...@boardW]
    iterator = 0
    # set new position for remaining elements
    for i in [@boardH - 1...@boardH - 1 - newMatrix[j].length]
      @matrix[i][j] = newMatrix[j][iterator]
      @_setPosition @matrix[i][j], i, j
      @matrix[i][j].data
        i: i
        j: j
      iterator += 1
    
    # add new elements in necessary
    if (@boardH - 1 - newMatrix[j].length) >= 0
      iterator = 1
      for i in [@boardH - 1 - newMatrix[j].length..0]
        # generate new element
        # new element are positioned behind the top of board
        _item = @_generateItem eur00t.compiledTemplates.jewel.item, @size, @gap, -iterator, j, @border
        @board.append _item.elem
        @matrix[i][j] = _item.elem
        
        _item.elem.data
          color: _item.data.color
        
        # animate moving new elements from top to actual position
        do (i, j) =>
          setTimeout (=> @_setPosition @matrix[i][j], i, j), 0
          
        iterator += 1
   
  true

###
  Initiate destruction process at (i, j)
  
  i, j:    coordinates of gem that initiates destruction
  hidden:  silent mode with no effects
  initial: if destruction is triggered by user or not
    
  return value: {
    destroyed: <true if elements were destroyed>,
    count: <a number of destroyed elements>
  }
###
window.eur00t.jewel.Game.prototype._destroyAt = (i, j, hidden, initial) ->
  @destroyV = []
  @destroyH = []
  
  if @matrix[i][j] isnt null
    @_destroyLinearVertical i, j, hidden
    @_destroyLinearHorizontal i, j, hidden
    
    destroyObj = @_processDestroyResult(hidden)
    
    destroyedFlag = destroyObj.destroyed
    
    ###
      Item at (i, j) should be destroyed only if:
      - number of destroyed element are 3 (including current);
      OR
      - (i, j) is special object
    ###
    if (destroyedFlag && ((destroyObj.count < 3) || !initial)) || (destroyedFlag && (@matrix[i][j] isnt null) && (@_processSpecial i, j))
      @_destroyObj i, j, hidden
    
    ###
      In case (i, j) wasn't destroyed after previous check AND
      destruction process is initiated by user AND
      element were destroyed (in this case destroyObj.count is more than 2)
      
      (i, j) should be destroyed and should be transformed into special element
    ###
    else if (@matrix[i][j] isnt null) && initial && destroyedFlag
      @matrix[i][j].addClass 'special'
      
      if destroyObj.count == 3
        @matrix[i][j].data
          special: 'bomb'
        @matrix[i][j].addClass 'bomb'
      else
        @matrix[i][j].data
          special: 'colorbomb'
        @matrix[i][j].addClass 'colorbomb'
    
    @_refreshScores() if !hidden
    
    destroyed: destroyedFlag
    count: destroyObj.count
  else
    destroyed: false
    count: 0

# Clear board. This process is initiated each time new element are added to the board.
window.eur00t.jewel.Game.prototype._clearBoard = (hidden) ->
  destroyedFlag = false
  for i in [0...@boardH]
    for j in [0...@boardW]
      if @matrix[i][j] != null
        destroyedFlag = (@_destroyAt i, j, hidden).destroyed || destroyedFlag
  
  if destroyedFlag
    if !hidden
      # If elements were destroyed, compactize the board and perform clear process
      setTimeout (=> @_compactizeBoard()), window.eur00t.jewel.SPEED
      setTimeout (=> @_clearBoard()), window.eur00t.jewel.SPEED * 2
    else
      @_compactizeBoard()
      @_clearBoard(hidden)

# Process deletion of special Bomb element at (i, j)
# This will delete the row number i and column number j
window.eur00t.jewel.Game.prototype._processSpecialBomb = (i, j) ->
  for j0 in [0...@boardW]
    @_destroyObj i, j0, false, true if j0 != j
  
  for i0 in [0...@boardH]
    @_destroyObj i0, j, false, true if i0 != i
  
  true

# Process deletion of special Color Bomb element at (i, j)
# All element with equal color will be deleted
window.eur00t.jewel.Game.prototype._processSpecialColorBomb = (i, j) ->
  color = @matrix[i][j].data().color
  
  for j0 in [0...@boardW]
    for i0 in [0...@boardH]
      if ((j0 != j) || (i0 != i)) && (@matrix[i0][j0] isnt null) && (@matrix[i0][j0].data().color == color)
        @_destroyObj i0, j0, false, true
    
  true

# Process deletion of special element.
window.eur00t.jewel.Game.prototype._processSpecial = (i, j) ->
  data = @matrix[i][j].data()
  
  if data.special?
    switch data.special
      when 'bomb' then @_processSpecialBomb i, j
      when 'colorbomb' then @_processSpecialColorBomb i, j
      
    true
  else false

# Initialize game process
window.eur00t.jewel.Game.prototype._initialize = ->
  # append Scores Indicator and Board elements to the page
  @jQueryContainer.append @scoresIndicator
  @jQueryContainer.append @board
  
  @selected = 
    obj: null
    i: -1
    j: -1
    
  @_refreshScores()
  
  # perform clear bopard process at mode with no effects
  @_clearBoard(true)
  
  # delegate 'click' event to Board element
  @board.on 'click', '.jewel', (e) =>
    # collect data from processing DOM element
    # it includes (i, j) cordinates and color
    data = ($ e.target).data()
    i = data.i
    j = data.j
    
    # select element if it's possible
    if @_checkIfSelectable i, j
      @_selectItem i, j
    
    # otherwise perform swap process
    else
      @_swapItems i, j, @selected.i, @selected.j
      
      destroyedFlag0 = (@_destroyAt i, j, false, true).destroyed
      destroyedFlag = (@_destroyAt @selected.i, @selected.j, false, true).destroyed
      
      if (!destroyedFlag0) && (!destroyedFlag)
        # if no element were destroyed, swap elements back
        do (selectedI = @selected.i, selectedJ = @selected.j) =>
          setTimeout (=> @_swapItems i, j, selectedI, selectedJ;), 300
        @_cancelPreviousSelect()
      else
        # otherwise compactize and clear board
        setTimeout (=> @_compactizeBoard()), window.eur00t.jewel.SPEED
        setTimeout (=> @_clearBoard()), window.eur00t.jewel.SPEED * 2
        @_cancelPreviousSelect()
