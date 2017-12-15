markupTextCache = {}

class @MarkupText
  @get: (markup) ->
    markupTextCache[markup] ||= new MarkupText(markup)

  @render: (context, markup, font) ->
    context.pixelRatio ?= 1
    markupText  = MarkupText.get(markup)
    tempCanvas  = markupText.render(context, font)
    boundingBox = markupText.boundingBox
    x = switch context.textAlign
      when 'center' then Math.floor(boundingBox.w / 2)
      when 'right', 'end' then boundingBox.maxX
      when 'left', 'start' then boundingBox.x
      else 0
    y = switch context.textBaseline
      when 'alphabetic' then boundingBox.maxY
      when 'top' then boundingBox.y
      when 'hanging' then boundingBox.y
      when 'middle' then Math.floor(boundingBox.h / 2)
      when 'ideographic' then boundingBox.maxY
      when 'bottom' then boundingBox.maxY
      else 0
    context.scale(1 / context.pixelRatio, 1 / context.pixelRatio)
    context.drawImage(tempCanvas, -x, -y)

  constructor: (markup) ->
    @markup = markup
    markupTextCache[markup] = this

  getBoundingBox: (context, alphaThreshold) ->
    alphaThreshold = 15 if alphaThreshold is undefined
    minX = Infinity
    minY = Infinity
    maxX = -Infinity
    maxY = -Infinity
    w = context.canvas.width
    h = context.canvas.height
    data = context.getImageData(0, 0, w, h).data

    for x in [1...w]
      for y in [1...h]
        alpha = data[(w * y + x) * 4 + 3]
        if (alpha > alphaThreshold)
          maxX = x if x > maxX
          minX = x if x < minX
          maxY = y if y > maxY
          minY = y if y < minY

    return {
      x: minX
      y: minY
      maxX: maxX
      maxY: maxY
      w: maxX - minX
      h: maxY - minY
    }

  render: (originalContext, font = originalContext?.font) ->
    @canvas ||= do =>
      canvas = document.createElement('canvas')
      canvas.width = 300 * originalContext.pixelRatio
      canvas.height = 300 * originalContext.pixelRatio
      context = canvas.getContext('2d')
      context.scale(originalContext.pixelRatio, originalContext.pixelRatio)
      x = 0
      h = parseInt(originalContext?.font?.match(/(\d+)px/)?[1] or 12)
      htmlTags = @markup.match(/([^<]+)|<([^>]+)>([^<]*)<\/([^>]+)>/g)
      if htmlTags?
        for part in htmlTags
          context.fillStyle = originalContext?.fillStyle
          context.font = font

          tag = null
          text = part
          if (match = part.match(/<([^>]+)>([^<]*)<\/([^>]+)>/))
            tag = match[1]
            text = match[2]

          if tag is 'sub'
            subFontSize = Math.round(parseInt(context.font.match(/\d+/)[0]) * 0.8)
            context.font = context.font.replace(/\d+/, subFontSize)
            context.textBaseline = 'hanging'
          else if tag is 'sup'
            supFontSize = Math.round(parseInt(context.font.match(/\d+/)[0]) * 0.8)
            context.font = context.font.replace(/\d+/, supFontSize)
            context.textBaseline = 'alphabetic'
          else
            context.textBaseline = 'middle'

          context.fillText(text, x, h)
          x += context.measureText(text).width + 1
      @boundingBox = @getBoundingBox(context)
      canvas
