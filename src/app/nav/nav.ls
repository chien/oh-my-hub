angular.module 'OhMyHub.nav', <[
  ui.router
]>



.factory 'NavFilters', ->
  _ = require 'prelude-ls'  
  filters = do
    attributes:  {}
    indicators: []

  do
    get: -> filters
    add: (c, v) ->
      throw new Erro "try to add undifined condition into filters." unless c? and v?
      console.log "Added filter attribute: #{v}"
      unless filters.attributes[c]?
        filters.attributes[c] = []
      unless v in filters.attributes[c]
        filters.attributes[c].push v
        filters.indicators.push name: v, category: c
      else
        throw new Error "should not add a duplicated attribute into filters."
    del: (c, v) ->
      throw new Error "try to remove undifined condition from filters." unless c? and v?
      if filters.attributes[c]? and filters.attributes[c].length > 0
        console.log "Removed filter attribute: #{v}"
        filters.attributes[c] = _.reject (-> angular.equals it, v), filters.attributes[c]
        filters.indicators = _.reject (-> angular.equals it, {name:v, category:c}), filters.indicators
        if filters.attributes[c].length == 0
          delete filters.attributes[c]
      else
        throw new Error "should not remove a attribute from empty filters."

.factory 'NavMenu', ->
  menu = {}
  counts = {}
  toggle = do
    switcher: true
  do
    create: (projects) ->
      for project in projects
        for attrname in <[category type tag tool license]>
          toggle[attrname] = false
          attrval = project[attrname] or []
          unless menu[attrname]?
            menu[attrname] = {}
            counts[attrname] = 0
          for val in attrval
            unless menu[attrname][val]?
              menu[attrname][val] = 1
            else
              menu[attrname][val] += 1
            if menu[attrname]
              counts[attrname] = Object.keys menu[attrname] .length
      return [menu, counts, toggle]

.controller \NavCtrl, ($scope, $location, NavFilters) ->
  $scope.filters = NavFilters.get!

  $scope.goto = ->
    $location.path it
  $scope.toggleFilter = (c, v) ->
    if $location.path != '/projecthub/project'
      $scope.goto '/projecthub/project'
    if $scope.filters.attributes[c]? and v in $scope.filters.attributes[c]
      NavFilters.del c, v
    else
      NavFilters.add c, v
