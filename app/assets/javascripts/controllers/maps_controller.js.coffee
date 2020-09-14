class window.MapsController
  constructor: (params = {}) ->
    @merchants = params.merchantsData
    @infoWindows = []
    @skinName = $("body").data()["skinName"]
    container = params.container || "map"

    @merchantsLayer = {
      "id": "merchants",
      "type": "symbol",
      "source": {
        "type": "geojson",
        "data": {
          "type": "FeatureCollection",
          "features": []
        }
      },
      "layout": {
        "icon-image": "{icon}",
        "icon-allow-overlap": true,
        "icon-ignore-placement": true
      }
    }

    @map = new mapboxgl.Map({
      container: container,
      style: "mapbox://styles/mapbox/streets-v9",
    });

    @bounds = new mapboxgl.LngLatBounds()

    _.each(@merchants, (merchant, index) =>
      merchant.latitude = merchant.latitude.to_n() if isPresent(merchant.latitude)
      merchant.longitude = merchant.longitude.to_n() if isPresent(merchant.longitude)

      merchantPoints = [merchant.longitude, merchant.latitude]

      @merchantsLayer.source.data.features.push({
        "type": "Feature",
        "properties": {
          "icon": "marker_#{ index + 1 }",
          "content": merchant.content
        },
        "geometry": {
          "type": "Point",
          "coordinates": merchantPoints,
        }
      })

      @map.on("load", () =>
        @map.loadImage("https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{ @skinName }/web/map-icons/#{ index + 1 }.png",
          (error, image) =>
            throw error if error
            @map.addImage("marker_#{ index + 1 }", image)

            @map.removeLayer("merchants") if isPresent(@map.getLayer("merchants"))

            @map.addLayer(@merchantsLayer)
        )
      )

      infoWindow = new mapboxgl.Popup({
        closeButton: true,
      }).setHTML(merchant.content).setLngLat(merchantPoints)

      @bounds.extend(merchantPoints)

      new mapboxgl.Marker(null, { offset: [-16, -22] }).setLngLat(merchantPoints).setPopup(infoWindow).addTo(@map)
    )

    @setMapCenter()

    @bindPopUpEvents()

  setMapCenter: =>
    if @merchants.length == 1
      @map.setZoom(12)
      @map.setCenter([@merchants[0].longitude, @merchants[0].latitude])
    else
      @map.fitBounds(@bounds, { padding: 75, linear: true })

  bindPopUpEvents: =>
    @map.on("click", "merchants", (e) =>
      $(".info-window .buttons .pickup").click((e) ->
        MerchantsIndexController.buttonAction(e, "pickup")
      )

      $(".info-window .buttons .delivery").click((e) ->
        MerchantsIndexController.buttonAction(e, "delivery")
      )
    )

  closeAllInfoWindows: =>
    infoWindow.remove() for infoWindow in @infoWindows