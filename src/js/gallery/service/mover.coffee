angular.module('multiGallery').service 'GalleryMover', ->

  class GalleryMover

    ANIMATION_TIME: 3000
    ANIMATION_SIDE_NEXT: 1
    ANIMATION_SIDE_PREV: 2

    _storage: null
    _renderer: null
    _$holder: null
    _$scope: null

    _animation: null

    _itemWidth: 0
    _currentIndex: 0

    # Public methods

    constructor: (storage, gallery, $holder, $scope)->
      @_storage = storage
      @_renderer = gallery
      @_$holder = $holder
      @_$scope = $scope

    render: (items)->
      @_storage.setItems(items)
      @_renderer.render( @_storage.getNearestRange() )
      @_loadElementInfo()
      @_syncCurrentIndex()
      @_applyCurrentIndexPosition()

    next: ->
      @_storage.nextIndex()
      @_syncCurrentIndex()
      @_rerender()

    prev: ->
      @_storage.prevIndex()
      @_syncCurrentIndex()
      @_rerender()

    animateNext: ->
      @_animation_type = @ANIMATION_SIDE_NEXT
      @_storage.incNextBuffer()
      @_animate()

    animatePrev: ->
      @_animation_type = @ANIMATION_SIDE_PREV
      @_storage.incPrevBuffer()
      @_animate()


    # Animation block

    _defaultAnimationTime: -> @ANIMATION_TIME/1000

    _stopPreviusAnimation: ->
      @_animation.pause() if @_animation
      @_animation.kill() if @_animation

    _animate: (
      time = @_defaultAnimationTime()
      position = @_positionForMoveIndex()
    )->
      @_stopPreviusAnimation()
      # Todo make request animation frame animation
      @_animation = TweenMax.to(@_$holder, time, {
        left: position + 'px'
        ease: Linear.easeNone
        onUpdate: => @_checkFrameChange()
        onComplete: => @_onAnimationComplete()
      })

    _onAnimationComplete: ->
      console.log('Animation complete')
      @_storage.clearRangeBuffer()
      @_syncCurrentIndex()
      @_rerender()

    _checkFrameChange: (changeCallback)->
      return false if (display_index = @_getDisplayIndex()) == @_getCurrentIndex()

      # Stop animation
      @_stopPreviusAnimation()

      # Current display element
      $element = @_renderer.getElementByIndex(display_index)

      # Render
      @_renderer.render( @_storage.getNearestRange() )
      @_$scope.$apply()

      # Change current index
      if @_animation_type == @ANIMATION_SIDE_NEXT
        @_currentIndex++
        position_diff = (@_currentHolderPosition() % @_itemWidth) + @_itemWidth
        moveToPosition = @_positionForMoveIndex()
      else
        new_element_index = @_renderer.getElementIndex($element)

        @_currentIndex += new_element_index - display_index
        @_currentIndex--

        position_diff = (@_currentHolderPosition() % @_itemWidth)
        moveToPosition = @__calculateCenterPositionForIndex( @_storage.NEAREST_ITEMS )

      # Change position
      @_setHolderPosition( @_positionForCurrentIndex() + position_diff )

      # Animate
      @_animate(null, moveToPosition)


    # Index and position calculation

    _currentHolderPosition: ->
      parseInt(@_$holder.css('left'), 10)

    _setHolderPosition: (position)->
      @_$holder.css 'left', position

    _applyCurrentIndexPosition: ->
      @_setHolderPosition( @_positionForCurrentIndex() )

    _positionForCurrentIndex: ->
      @__calculateCenterPositionForIndex(@_getCurrentIndex())

    _getDisplayIndex: ->
      Math.abs( Math.round( @_currentHolderPosition() / @_itemWidth ) )

    _syncCurrentIndex: ->
      @_currentIndex = @_storage.getCurrentIndexInRange()

    _getCurrentIndex: ->
      @_currentIndex

    _positionForMoveIndex: ->
      @__calculateCenterPositionForIndex(@_storage.getCurrentIndexInRange())

    __calculateCenterPositionForIndex: (index)->
      @_itemWidth * index * -1


    # Render

    _loadElementInfo: ->
      element = @_renderer.firstElement()
      @_itemWidth = element.offsetWidth if element #todo it's unposiable for different block size

    _rerender: ->
      @_renderer.render( @_storage.getNearestRange() )
      @_applyCurrentIndexPosition()
      @_$scope.$apply()
