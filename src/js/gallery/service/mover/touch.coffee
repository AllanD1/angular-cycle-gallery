angular.module('multiGallery').service 'MoverTouch', ->

  class MoverTouch

    _mover: null
    _storage: null
    _holder: null

    trigger: false
    start_position: 0
    slide_diff: 0

    constructor: (mover, holder)->
      @_mover = mover
      @_holder = holder

    touchStart: (position)->
      @trigger = true
      @_mover._stopPreviusAnimation() # todo fix name
      @start_position = position

    touchEnd: ->
      return true unless @trigger
      @trigger = false
      @start_position = 0
      position_diff = @_holder.getSlideDiff()

      @_mover.applyIndexDiff( @_holder.getDisplayIndex() - @_mover.getTrueMoveIndex() )

      position_diff += @_holder.getItemWidth() if first_half
      first_half = Math.abs(position_diff) > @_holder.getItemWidth()/2

      @_holder.setPosition( @_holder.getCurrentPosition() + position_diff )
      @_mover._animate()

    touchMove: (position)->
      return true unless @trigger
      @_mover.forceMove(position - @start_position)
