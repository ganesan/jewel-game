window.eur00t = {} unless window.eur00t?
window.eur00t.templates = {} unless window.eur00t.templates?
window.eur00t.templates.jewel = {} unless window.eur00t.templates.jewel?

###
  Board template.
  
  width, height: size in pixels
###
eur00t.templates.jewel.board = """
  <div class="board" style="width: <%=width %>px; height: <%=height %>px;">
  </div>
"""

###
  Scores template.
###
eur00t.templates.jewel.scores = """
  <h2 class="scores"></h2>
"""

###
  Jewel template.
  
  color: 'orange', 'blue', 'yellow', 'brown'
  size: a size of jewel
  i,j: position of jewel
  i: row coordinate 0,1,...
  j: column coordinate 0,1,...
  gap: a gap between items
  border: border for each gem
###
eur00t.templates.jewel.item = """
  <div class="jewel <%=color %>" style="width: <%=size %>px; height: <%=size %>px; left: <%=gap+j*(size+2*gap)-border %>px; top: <%=gap+i*(size+2*gap)-border %>px;">
  </div>
"""
