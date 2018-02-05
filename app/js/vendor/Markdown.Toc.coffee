utils =
  slugify: (text) ->
    text.toLowerCase().replace(/\s+/g, "-").replace(/[^\w\-]+/g, "").replace(/\-\-+/g, "-").replace(/^-+/, "").replace /-+$/, ""

Markdown.Toc = (->
  toc = {}

  TocElement = (tagName, anchor, text) ->
    @tagName = tagName
    @anchor = anchor
    @text = text
    @children = []
    return

  TocElement::childrenToString = ->
    return ""  if @children.length is 0
    result = "<ul>\n"
    result += child.toString() for child in @children

    result += "</ul>\n"
    result

  TocElement::toString = ->
    result = "<li>"
    result += "<a href=\"#" + @anchor + "\">" + @text + "</a>"  if @anchor and @text
    result += @childrenToString() + "</li>\n"
    result

  groupTags = (array, level) ->
    pushCurrentElement = ->
      if currentElement isnt `undefined`
        currentElement.children = groupTags(currentElement.children, level + 1)  if currentElement.children.length > 0
        result.push currentElement

    level = level or 1
    tagName = "H" + level
    result = []
    currentElement = undefined
    for element in array
      unless element.tagName is tagName
        if level isnt 6
          currentElement = new TocElement()  if currentElement is `undefined`
          currentElement.children.push element
      else
        pushCurrentElement()
        currentElement = element

    pushCurrentElement()
    result

  buildToc = ($el) ->
    createAnchor = (el) ->
      id = el.id or utils.slugify(el.textContent) or "title"
      anchor = id
      index = 0
      anchor = id + "-" + (++index)  while _.has(anchorList, anchor)
      anchorList[anchor] = true

      el.id = anchor
      anchor

    anchorList = {}
    elementList = []

    $el.find("h1, h2, h3, h4, h5, h6").each (index, elt) ->
      elementList.push new TocElement(elt.tagName, createAnchor(elt), elt.textContent)

    elementList = groupTags(elementList)
    "<div class=\"toc\">\n<ul>\n" + elementList.join("") + "</ul>\n</div>\n"

  toc.apply = ($el) ->
    marker = "\\[(TOC|toc)\\]"
    tocExp = new RegExp('^'+marker+'$')
    htmlToc = buildToc($el)

    $el.find("p").each (index, elt) ->
      elt.innerHTML = htmlToc if tocExp.test(elt.innerHTML)

  toc)()
