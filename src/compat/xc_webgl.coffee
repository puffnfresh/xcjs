#oldX and oldY are used in tapMoved events to provide moveX and moveY
oldX = 0
oldY = 0
#tapDown is used to only raise tapMoved events when a tap is down.
tapDown = false

################# XCNode platform specific implementations #################
class XCCompat
	constructor: ->

_xcNodeWidth = (node) ->
	node._width * node._scaleX

_xcNodeHeight = (node) ->
	node._height * node._scaleY

_xcTextNodeWidth = (node) ->
	###context.save()
	context.font = node.font
	width = context.measureText(node._text).width
	context.restore()
	node.scaleX() * width###

_xcTextNodeHeight = (node) ->
	###context.save()
	context.font = node.font
	height = context.measureText('m').width
	context.restore()
	node.scaleY() * height###

_xcNodeX = (node) ->
	node._x

_xcNodeY = (node) ->
	node._y

_xcNodeSetX = (node, newX) ->
	node._x = newX

_xcNodeSetY = (node, newY) ->
	node._y = newY

_xcNodeLayer = (node) ->
	node._layer

_xcNodeSetLayer = (node, newLayer) ->
	node._layer = newLayer

_xcNodeColor = (node) ->
	node._color

_xcNodeSetColor = (node, newColor) ->
	node._color = newColor

_xcNodeScaleX = (node) ->
	node._scaleX

_xcNodeScaleY = (node) ->
	node._scaleY

_xcNodeSetScaleX = (node, newScaleX) ->
	node._scaleX = newScaleX

_xcNodeSetScaleY = (node, newScaleY) ->
	node._scaleY = newScaleY

_xcNodeRotation = (node) ->
	node._rotation

_xcNodeSetRotation = (node, newRotation) ->
	while newRotation > 360
		newRotation = newRotation - 360
	while newRotation < 0
		newRotation = 360 + newRotation
	node._rotation = newRotation

_xcNodeOpacity = (node) ->
	node._opacity

_xcNodeSetOpacity = (node, newOpacity) ->
	if newOpacity < 0
		newOpacity = 0
	else if newOpacity > 1.0
		newOpacity = 1.0

	node._opacity = newOpacity

_xcNodeAnchorX = (node) ->
	node._anchorX

_xcNodeAnchorY = (node) ->
	node._anchorY

_xcNodeSetAnchorX = (node, newAnchorX) ->
	node._anchorX = newAnchorX

_xcNodeSetAnchorY = (node, newAnchorY) ->
	node._anchorY = newAnchorY

_xcNodeVisible = (node) ->
	node._visible

_xcNodeSetVisible = (node, visible) ->
	node._visible = visible

_xcTextNodeText = (node) ->
	node._text

_xcTextSetText = (node, newText) ->
	node._text = newText

#load a sprite image.  Since all images are placed in the DOM
# in a hidden div, search through the images in document.imaes
_xcLoadImage = (imageName) ->
	#the images should be in the /resources directory so
	#finding /imageName$ will give the correct image
	endsWith = new RegExp('/' + imageName + '$')

	for image in document.images
		if image.src.match(endsWith)
			image.webglTexture = context.createTexture()
			context.bindTexture(context.TEXTURE_2D, image.webglTexture)
			context.texImage2D(context.TEXTURE_2D, 0, context.RGBA, context.RGBA, context.UNSIGNED_BYTE, image)
			context.texParameteri(context.TEXTURE_2D, context.TEXTURE_MAG_FILTER, context.NEAREST)
			context.texParameteri(context.TEXTURE_2D, context.TEXTURE_MIN_FILTER, context.NEAREST)
			context.texParameteri(context.TEXTURE_2D, context.TEXTURE_WRAP_S, context.CLAMP_TO_EDGE)
			context.texParameteri(context.TEXTURE_2D, context.TEXTURE_WRAP_T, context.CLAMP_TO_EDGE)

			image.webglCoordBuffer = context.createBuffer()
			context.bindBuffer(context.ARRAY_BUFFER, image.webglCoordBuffer)
			context.bufferData(context.ARRAY_BUFFER, new Float32Array([0, 1, 1, 1, 0, 0, 1, 0]), context.STATIC_DRAW)

			return image

	return null

_xcImageWidth = (node) ->
	node.sprite.width

_xcImageHeight = (node) ->
	node.sprite.height

# loading text in the WebGL backend doesn't
# need to do anything.  Just return null.
_xcLoadText = (node) -> null

# WebGL implementation of drawing a sprite.
# this is called by the SpriteNode's draw() function.
# The big picture is: setup the context with the node's
# coords, rotation, and opacity, and then draw it based
# on the scale and anchor positions.  node is an XCSpriteNode
_xcSpriteDraw = (node) ->
	#rotate the context to the node's rotation
	#since rotation is stored in degrees and the
	# context wants radians, convert.
	#TODO: move this into the node so the conversion
	#only has to be done when it changes.
	#context.rotate(node.rotation() * Math.PI / 180)

	#set up the context's drawing opacity
	#context.globalAlpha = node.opacity()

	#now draw the sprite's image.
	#the first 4 parameter values are the x,y with, height, to draw
	#from the source image.  These will always be 0,0 and the image height
	#The next 4 are the x, y, width, height to draw onto the canvas.
	# since we've already moved the context to the node's x and y, the
	#destination x and y here are simply a factor of the node's anchor.
	# the destination width and height are the image width/height multiplied by
	# the sprite's scale
	###
	context.drawImage(node.sprite,
					0,
					0,
					node.sprite.width,
					node.sprite.height,
					0 - (node.width() * node.anchorX()),
					0 - (node.height() * node.anchorY()),
					node.sprite.width * node.scaleX(),
					node.sprite.height * node.scaleY())
	###

	node.webglVertexBuffer = context.createBuffer() if !node.webglVertexBuffer?

	context.bindBuffer(context.ARRAY_BUFFER, node.webglVertexBuffer)
	x1 = node.X() - (node.anchorX() * node.width())
	x2 = x1 + node.width()
	y1 = node.Y() - (node.anchorY() * node.height())
	y2 = y1 + node.height()
	vertices = [
		x2, y2, 0.0,
		x1, y2, 0.0,
		x2, y1, 0.0,
		x1, y1, 0.0
		]
	context.bufferData(context.ARRAY_BUFFER, new Float32Array(vertices), context.STATIC_DRAW)
	context.vertexAttribPointer(context.webglVertexAttrib, 3, context.FLOAT, false, 0, 0)

	context.bindBuffer(context.ARRAY_BUFFER, node.sprite.webglCoordBuffer)
	context.vertexAttribPointer(context.webglCoordAttrib, 2, context.FLOAT, false, 0, 0)

	context.activeTexture(context.TEXTURE0)
	context.bindTexture(context.TEXTURE_2D, node.sprite.webglTexture)
	context.uniform1i(context.webglSampler, 0)

	context.vertexAttrib1f(context.webglAlphaAttrib, node.opacity())

	context.drawArrays(context.TRIANGLE_STRIP, 0, 4)

# canvas implementation of drawing a textnode.
# the big picture is: setup the context with all of
# the node's attributes and then fillText with the text.
# node is an XCTextNode
_xcTextDraw = (node) ->
	###
	#set the node font to a version that is readable by a canvas context
	#TODO: move this out into the node so it's not done every frame.
	node.font = node.fontSize + "pt " + node.fontName
	#set the context's font to the correct font.
	# context.font = node.font

	# #set the context's fillstyle to rgb with the text node's color values.
	# color = node.color()
	# fillStyle = 'rgb(' + color.r + ',' + color.g + ',' + color.b + ')'
	# context.fillStyle = fillStyle

	# #now move the context to the node's x and y
	# context.translate(node.X(), node.Y())

	# #rotate the context to the node's rotation,
	# context.rotate(node.rotation() * Math.PI / 180)
	# #scale the context to the node's scale,
	# context.scale(node.scaleX(), node.scaleY())
	# #and set the context's opacity.
	# context.globalAlpha = node.opacity()

	# #finally, draw the text.  since we've already moved the context
	# #to the node's x and y coordinates, the x and y here are simply
	# # based on the node's anchor points.
	# context.fillText(node.text(), 0 - (node.width() * node.anchorX()),
	# 								0 - (node.height() * node.anchorY()))
	###


#to get mousedown events (which are converted to xc tapDown events),
#listen for jquery mousedown events on the canvas.
handleMouseDown = (event) ->
	#get the x and y relative to the canvas
	x = event.pageX - canvas.offsetLeft
	y = event.pageY - canvas.offsetTop

	#since the tap just started, oldX and oldY are the x and y
	#they will change on a mouse move.
	oldX = x
	oldY = y
	#a tap is down.
	tapDown = true

	#now raise an XCTapDown event
	e = new XCTapDownEvent(x, y, 0)
	#and dispatch it.
	xc.dispatchEvent(e)

#to get mouseup events (which are converted to xc tapUp events),
# listen for jquery mouseup events.  This listener should be global
# because if a tap starts on the canvas, it can still stop outside of it
# and we don't want to lose the tap.
handleMouseUp = (event) ->
	#was the tap started within the canvas?
	if tapDown
		#if so, there is no longer a tap donw
		tapDown = false
		#get x and y relative to the canvas
		x = event.pageX - canvas.offsetLeft
		y = event.pageY - canvas.offsetTop
		#if x or y are larger than the canvas width/height or negative,
		#that means the tapup happened outside of the canvas.  To make sense
		#in the context of the canvas, they should be set to 0 or the canvas
		#width/height
		if x > canvasWidth then x = canvasWidth
		if x < 0 then x = 0
		if y > canvasHeight then x = canvasHeight
		if y < 0 then y = 0

		#now make a new TapUp event
		e = new XCTapUpEvent(x, y, 0)
		#and dispatch it
		xc.dispatchEvent(e)

	#otherwise, don't do anything; we don't care about the tapup

#to get mousemoved events, (which are converted to xc tapMoved events),
# list for jquery mousemoved events on the canvas.
handleMouseMoved = (event) ->
	#is there currently a tap down?
	if tapDown
		#if so, get the x and y relative to the canvas
		x = event.pageX - canvas.offsetLeft
		y = event.pageY - canvas.offsetTop

		#now get the amount the tap moved in x and y by subtracting the
		#last coords from the current coords.
		moveX = x - oldX
		moveY = y - oldY
		#now the new old coords are the current coords.
		oldX = x
		oldY = y
		#now make a new TapMoved event
		e = new XCTapMovedEvent(x, y, moveX, moveY, 0)
		#and dispatch it.
		xc.dispatchEvent(e)

#keyup and keydown events are specific to the canvas implementation.
#They allow for keyboard input.  They listen for jquery keydown events.
#TODO: figure out if keys can be blocked from doing stuff like the arrow
# keys scrolling the window.
#TODO: make a nicer way to figure out what a key is from its 'event.which'

handleKeyDown = (event) ->
	#they key that is down is stored in event.which
	key = event.which
	#create a new keydown event with the appropriate key
	e = new XCKeyDownEvent(key)
	#and dispatch it.
	xc.dispatchEvent(e)

handleKeyUp = (event) ->
	#they key that is down is stored in event.which
	key = event.which

	#create a new keyup event with the appropriate key
	e = new XCKeyUpEvent(key)
	#and dispatch it.
	xc.dispatchEvent(e)

# this is the function that is called when a resource, for example an image,
# is loaded into the DOM.  (it should be the image tag's onLoad event)
itemLoaded = (item)->
	# have all of the items loaded?
	if --itemsToLoad <= 0
		#if so, start up xc
		xc_init()

# xc_init is the function that starts everything off.  It is called when
# all of the resources have been loaded.  It calls the user defined main
# function and then starts an update loop.
xc_init = ->
	window.canvas = document.getElementById('xcCanvas')
	window.context = canvas.getContext('experimental-webgl')

	vshader = [
		"uniform mat4 uProjectionMatrix;",
		"attribute vec3 aVertexPosition;",
		"attribute vec2 aTextureCoord;",
		"attribute float aTextureAlpha;",
		"",
		"varying vec2 vTextureCoord;",
		"varying float fTextureAlpha;",
		"",
		"void main(void) {",
		"    gl_Position = uProjectionMatrix * vec4(aVertexPosition, 1.0);",
		"",
		"    vTextureCoord = aTextureCoord;",
		"    fTextureAlpha = aTextureAlpha;",
		"}"
		].join("\n");

	fshader = [
		"#ifdef GL_ES",
		"precision highp float;",
		"#endif",
		"",
		"varying vec2 vTextureCoord;",
		"varying float fTextureAlpha;",
		"",
		"uniform sampler2D uSampler;",
		"",
		"void main(void) {",
		"    vec4 tex = texture2D(uSampler, vTextureCoord);",
		"    gl_FragColor = vec4(tex.r, tex.g, tex.b, tex.a);",
		"}"
		].join("\n");

	makeShader = (source, type) ->
		shader = context.createShader(type)
		context.shaderSource(shader, source)
		context.compileShader(shader)
		shader

	shaderProgram = context.createProgram()
	context.attachShader(shaderProgram, makeShader(vshader, context.VERTEX_SHADER))
	context.attachShader(shaderProgram, makeShader(fshader, context.FRAGMENT_SHADER))

	context.linkProgram(shaderProgram)
	context.useProgram(shaderProgram)

	context.webglVertexAttrib = context.getAttribLocation(shaderProgram, "aVertexPosition")
	context.enableVertexAttribArray(context.webglVertexAttrib)

	context.webglCoordAttrib = context.getAttribLocation(shaderProgram, "aTextureCoord")
	context.enableVertexAttribArray(context.webglCoordAttrib)

	context.webglAlphaAttrib = context.getAttribLocation(shaderProgram, "aTextureAlpha")

	context.webglSampler = context.getUniformLocation(shaderProgram, "uSampler");

	createProjection = (width, height) ->
		left = 0
		right = width
		bottom = height
		top = 0
		near = 1
		far = -1

		tx = -(right + left) / (right - left)
		ty = -(top + bottom) / (top - bottom)
		tz = -(far + near) / (far - near)

		orthoMatrix = []
		orthoMatrix[0] = 2 / (right - left)
		orthoMatrix[1] = 0
		orthoMatrix[2] = 0
		orthoMatrix[3] = 0
		orthoMatrix[4] = 0
		orthoMatrix[5] = 2 / (top - bottom)
		orthoMatrix[6] = 0
		orthoMatrix[7] = 0
		orthoMatrix[8] = 0
		orthoMatrix[9] = 0
		orthoMatrix[10] = -2 / (far - near)
		orthoMatrix[11] = 0
		orthoMatrix[12] = tx
		orthoMatrix[13] = ty
		orthoMatrix[14] = tz
		orthoMatrix[15] = 1

		uProjectionMatrix = context.getUniformLocation(shaderProgram, "uProjectionMatrix")
		context.uniformMatrix4fv(uProjectionMatrix, false, new Float32Array(orthoMatrix))

	createProjection(canvasWidth, canvasHeight)

	context.blendFunc(context.SRC_ALPHA, context.ONE_MINUS_SRC_ALPHA)
	context.enable(context.BLEND)

	$(canvas).mousedown(handleMouseDown)
	$(canvas).mousemove(handleMouseMoved)
	$(document).mouseup(handleMouseUp)
	$(document).keydown(handleKeyDown)
	$(document).keyup(handleKeyUp)

	#call the user defined main function.  This is the code
	# that a game written using this framework will provide.
	main()

	#to keep track of the time between frames, start off a previous time
	previousTime = (new Date()).getTime()

	#when a scene is paused, things must be changed when it is resumed
	#so that the dt between frames isn't huge.  wasPaused keeps track of
	# whether the scene was paused.
	wasPaused = false


	update =  ->
		context.clear(context.COLOR_BUFFER_BIT | context.DEPTH_BUFFER_BIT)

		currentTime = new Date().getTime()
		delta = (currentTime - previousTime) / 1000
		previousTime = currentTime

		currentScene = xc.getCurrentScene()

		#is the scene paused?
		if currentScene.paused()
			#if so, set wasPaused to true so
			# we know to handle the time correctly
			# when it resumes
			wasPaused = true
			#and then return, we don't need to do
			#anything else if the active scene is paused.
			return
		else
			if wasPaused
				delta = 0
				wasPaused = false

			currentScene.tick(delta)
			for child in currentScene.children()
				if child.visible()
					child.draw()

	setInterval(update, 1000/60)


#when the document is ready, create a new xc object
$(xc = new XC())
