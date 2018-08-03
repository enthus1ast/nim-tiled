import 
    xmlparser,
    xmltree,
    streams,
    strutils,
    parseutils,
    strformat,
    os,
    ospaths

type
    TiledRegion* = object
        x, y, width, height : int

    TiledOrientation* {.pure.} = enum
        Orthogonal,
        Orthographic

    TiledRenderorder* {.pure.} = enum
        RightDown

    TiledObject* = ref object of RootObj
      x, y, width, height: float

    TiledPolygon* = ref object of TiledObject
      points: seq[(float, float)]

    TiledPolyline* = ref object of TiledObject
      points: seq[(float, float)]

    TiledPoint* = ref object of TiledObject
    TiledEllipse* = ref object of TiledObject

    TiledTileset* = ref object
        name: string
        tilewidth, tileheight: int
        width, height: int
        tilecount: int
        columns: int
        regions: seq[TiledRegion]

    TiledLayer* = ref object
        name: string
        width, height: int
        tiles: seq[int]

    TiledObjectGroup* = ref object
        objects: seq[TiledObject]

    TiledMap* = ref object
        version: string
        tiledversion: string
        orientation: TiledOrientation
        renderorder: TiledRenderorder

        width, height: int
        tilewidth, tileheight: int
        infinite: bool

        tilesets: seq[TiledTileset]
        layers: seq[TiledLayer]
        objectGroups: seq[TiledObjectGroup]

        regions: seq[TiledRegion]

proc `$`* (r: TiledRegion): string=
    result = "TiledRegion {\n"
    result &= "   x: " & $r.x & "\n"
    result &= "   y: " & $r.y & "\n"
    result &= "   w: " & $r.width & "\n"
    result &= "   h: " & $r.height & "\n}\n"

# Public properties for the TiledMap
proc version*       (map: TiledMap): string {.inline.} = map.version
proc tiledversion*  (map: TiledMap): string {.inline.} = map.tiledversion
proc orientation*   (map: TiledMap): TiledOrientation {.inline.} = map.orientation
proc renderorder*   (map: TiledMap): TiledRenderorder {.inline.} = map.renderorder
proc width*         (map: TiledMap): int {.inline.} = map.width
proc height*        (map: TiledMap): int {.inline.} = map.height
proc tilewidth*     (map: TiledMap): int {.inline.} = map.tilewidth
proc tileheight*    (map: TiledMap): int {.inline.} = map.tileheight
proc infinite*      (map: TiledMap): bool {.inline.} = map.infinite
proc tilesets*      (map: TiledMap): seq[TiledTileset] {.inline.} = map.tilesets
proc layers*        (map: TiledMap): seq[TiledLayer] {.inline.} = map.layers
proc objectGroups*  (map: TiledMap): seq[TiledObjectGroup] {.inline.} = map.objectGroups
proc regions*       (map: TiledMap): seq[TiledRegion] {.inline.} = map.regions

# Public properties for the TiledLayer
proc name*    (layer: TiledLayer): string {.inline.}= layer.name
proc width*   (layer: TiledLayer): int {.inline.}= layer.width
proc height*  (layer: TiledLayer): int {.inline.}= layer.height
proc tiles*   (layer: TiledLayer): seq[int] {.inline.}= layer.tiles

# Public properties for the TiledObjectGroup
proc objects*   (layer: TiledObjectGroup): seq[TiledObject] {.inline.}= layer.objects

# Public properties for the TiledTileset
proc name* (tileset: TiledTileset): string {.inline.}= tileset.name
proc tilewidth* (tileset: TiledTileset): int {.inline.}= tileset.tilewidth
proc tileheight* (tileset: TiledTileset): int {.inline.}= tileset.tileheight
proc width* (tileset: TiledTileset): int {.inline.}= tileset.width
proc height* (tileset: TiledTileset): int {.inline.}= tileset.height
proc tilecount* (tileset: TiledTileset): int {.inline.}= tileset.tilecount
proc columns* (tileset: TiledTileset): int {.inline.}= tileset.columns
proc regions* (tileset: TiledTileset): seq[TiledRegion] {.inline.}= tileset.regions

# Public properties for the TiledRegion
proc x* (r: TiledRegion): auto {.inline.} = r.x
proc y* (r: TiledRegion): auto {.inline.} = r.y
proc width* (r: TiledRegion): auto {.inline.} = r.width
proc height* (r: TiledRegion): auto {.inline.} = r.height

proc `$`* (o: TiledPolygon): auto=
  result = "TiledPolygon{\n"
  result &= "   x:" & $o.x & "\n"
  result &= "   y:" & $o.y & "\n"
  result &= "   width:" & $o.width & "\n"
  result &= "   height:" & $o.height & "\n"
  result &= "   points: ["
  for p in o.points:
    result &= fmt"({p[0]},{p[1]}),"
  result &= "]\n}"

proc `$`* (o: TiledPolyline): auto=
  result = "TiledPolyline{\n"
  result &= "   x:" & $o.x & "\n"
  result &= "   y:" & $o.y & "\n"
  result &= "   width:" & $o.width & "\n"
  result &= "   height:" & $o.height & "\n"
  result &= "   points: ["
  for p in o.points:
    result &= fmt"({p[0]},{p[1]}),"
  result &= "]\n}"

proc `$`* (o: TiledPoint): auto=
  result = "TiledPoint{x:"& $o.x & " y:" & $o.y & " width:" & $o.width & " height:" & $o.height & "}"

proc `$`* (o: TiledEllipse): auto=
  result = "TiledEllipse{x:"& $o.x & " y:" & $o.y & " width:" & $o.width & " height:" & $o.height & "}"

proc `$`* (o: TiledObject): auto=
  if o of TiledPoint: return $(o.TiledPoint)
  if o of TiledEllipse: return $(o.TiledEllipse)
  if o of TiledPolygon: return $(o.TiledPolygon)
  if o of TiledPolyline: return $(o.TiledPolyline)
  result = "TiledObject{x:"& $o.x & " y:" & $o.y & " width:" & $o.width & " height:" & $o.height & "}"

proc newTiledRegion* (x, y, width, height: int): TiledRegion=
    TiledRegion(
        x: x, y: y, width: width, height: height
    )
    
proc loadTileset* (path: string): TiledTileset=
    assert(fileExists path, "[ERROR] :: loadTiledMap :: Cannot find tileset: " & path)

    result = TiledTileset()
    let theXml = readFile(path)
        .newStringStream()
        .parseXml()
    
    result.name         = theXml.attr "name"
    result.tilewidth    = theXml.attr("tilewidth").parseInt
    result.tileheight   = theXml.attr("tileheight").parseInt
    result.tilecount    = theXml.attr("tilecount").parseInt
    result.columns      = theXml.attr("columns").parseInt

    let theImage = theXml[0]

    let width = theImage.attr("width").parseInt
    let height = theImage.attr("height").parseInt

    result.width = width
    result.height = height

    #TODO: Check the assets manager
    #let region_string = $result.tilewidth & "x" & $result.tileheight
    # result.regions = newSeq[]

    let imageXml = theXml[0]
    let tpath = parentDir(path) & "/" & imageXml.attr("source")

    let num_tiles_w = (width / result.tilewidth).int
    let num_tiles_h = (height / result.tileheight).int
    
    result.regions = newSeq[TiledRegion](num_tiles_w * num_tiles_h)
    var index = 0
    for y in 0..<num_tiles_h:
        for x in 0..<num_tiles_w:
            result.regions[index] = newTiledRegion(
                x * result.tilewidth,
                y * result.tileheight,
                result.tilewidth,
                result.tileheight
            )
            index += 1

proc loadTiledMap* (path: string): TiledMap=
    assert(fileExists path, "[ERROR] :: loadTiledMap :: Cannot find map: " & path)

    result = TiledMap(
        tilesets: newSeq[TiledTileset](),
        layers: newSeq[TiledLayer](),
        objectGroups: newSeq[TiledObjectGroup]()
    )

    let theXml = readFile(path)
        .newStringStream()
        .parseXml()

    result.version = theXml.attr "version"
    result.tiledversion = theXml.attr "tiledversion"

    result.orientation = 
        if theXml.attr("orientation") == "orthogonal":
            TiledOrientation.Orthogonal
        else:
            TiledOrientation.Orthogonal
        
    result.renderorder =
        if theXml.attr("renderorder") == "right-down":
            TiledRenderorder.RightDown
        else:
            echo "Nim Tiled currently only supports: " & $TiledRenderorder.RightDown & " render order"
            TiledRenderorder.RightDown
        
    result.width = theXml.attr("width").parseInt
    result.height = theXml.attr("height").parseInt

    result.tilewidth = theXml.attr("tilewidth").parseInt
    result.tileheight = theXml.attr("tileheight").parseInt

    result.infinite =
        if theXml.attr("infinite") == "0":
            false
        else:
            true

    
    doAssert(result.infinite == false, "Nim Tiled currently doesn't support infinite maps")

    let tileset_xmlnodes = theXml.findAll "tileset"
    for node in tileset_xmlnodes:
        let tpath = parentDir(path) & "/" & node.attr "source"
        result.tilesets.add loadTIleset(tpath)
    
    let layers_xmlnodes = theXml.findAll "layer"
    let objects_xmlnodes = theXml.findAll "objectgroup"

    for layerXml in layers_xmlnodes:
        let layer = TiledLayer(
            name: layerXml.attr "name",
            width: layerXml.attr("width").parseInt,
            height: layerXml.attr("height").parseInt,
        )

        layer.tiles = newSeq[int](layer.width * layer.height)

        let dataXml = layerXml[0][0]
        let dataText = dataXml.rawText
        let dataTextLen = dataText.len

        var cursor = 0
        var index = 0
        var token = ""

        while cursor < dataTextLen:
            cursor += parseUntil(dataText, token, ',', cursor) + 1
            token.removeSuffix()
            token.removePrefix()
            layer.tiles[index] = token.parseInt
            index += 1

        result.layers.add(layer)

    for objectsXml in objects_xmlnodes:
        discard """ TODO: Implement"""

        var objectGroup = TiledObjectGroup(objects: newSeq[TiledObject]())
        result.objectGroups.add objectGroup

        for objXml in objectsXml:
          let x = objXml.attr("x").parseFloat
          let y = objXml.attr("y").parseFloat

          var width = 0.0
          var height = 0.0

          try:
            width = objXml.attr("width").parseFloat
          except:
            discard

          try:
            height = objXml.attr("height").parseFloat
          except:
            discard

          #echo fmt"x:{x} y:{y} width:{width} height:{height}" 

          var isRect = true
          for subXml in objXml:
            isRect = false

            case subXml.tag:
              of "polygon":
                let pointsStr = subXml.attr("points")
                let splits = pointsStr.split ' '

                var o = TiledPolygon(
                  x: x, y: y, width: width, height: height,
                  points: newSeq[(float, float)]()
                )

                for pstr in splits:
                   let p = pstr.split(',')
                   let x = p[0].parseFloat
                   let y = p[1].parseFloat
                   o.points.add (x, y)

                objectGroup.objects.add o

              of "polyline":
                let pointsStr = subXml.attr("points")
                let splits = pointsStr.split ' '

                var o = TiledPolyline(
                  x: x, y: y, width: width, height: height,
                  points: newSeq[(float, float)]()
                )

                for pstr in splits:
                   let p = pstr.split(',')
                   let x = p[0].parseFloat
                   let y = p[1].parseFloat
                   o.points.add (x, y)

                objectGroup.objects.add o

              of "point":
                objectGroup.objects.add TiledPoint(x: x, y: y, width: 0, height: 0)

              of "ellipse":
                objectGroup.objects.add TiledEllipse(
                  x: x,
                  y: y,
                  width: width,
                  height: height)

              else:
                echo fmt"Nim Tiled unsuported object type: {subXml.tag}"

          if isRect:
            objectGroup.objects.add(
              TiledObject(
                x: x, y: y, width: width, height: height 
              ))
