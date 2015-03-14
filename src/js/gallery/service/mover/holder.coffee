angular.module('multiGallery').service 'MoverHolder', ->

  class MoverHolder

    _$holder: null
    _itemWidth: 0

    _position_lock: null

    constructor: ($holder)->
      @_$holder = $holder

    update: ->
      @getItemWidth(false)

    getElement: ->
      @_$holder

    getDisplayIndex: ->
      Math.abs( Math.round( @getCurrentPosition() / @getItemWidth() ) )

    getItemWidth: (cached = true)->
      return @_itemWidth if @_itemWidth and cached
      $element = @_$holder.children().eq(0)
      @_itemWidth = $element[0].offsetWidth if $element[0]

    getCurrentPosition: ->
      parseInt @_$holder.css('left'), 10

    setPosition: (position)->
      @_$holder.css 'left', position + 'px'

    getSlideDiff: ->
      @getCurrentPosition() % @getItemWidth()

    __calculatePositionForIndex: (index)->
      @getItemWidth() * index * -1

    createPositionLock: ->
      @_position_lock = @getCurrentPosition() unless @_position_lock

    getPositionLockDiff: ->
      @getCurrentPosition() - @_position_lock

    clearPositionLock: ->
      @_position_lock = null
