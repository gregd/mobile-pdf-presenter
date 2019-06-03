var rwjAdminLocDiag = {
  map: null,
  info_win: null,
  startY: null,
  width: null,
  curLr: null,

  initStickyMap: function() {
    var $s = $(".rwc-AdminLocDiag-scroll").first();
    this.startY = $s.offset().top;
    this.width = $s.width();
  },

  updateStickyMap: function() {
    var $s = $(".rwc-AdminLocDiag-scroll").first();
    var scrollY = $(window).scrollTop();
    var isFixed = $s.css('position') == 'fixed';

    console.log("update", this.startY, scrollY, isFixed, $s);

    if (scrollY > this.startY) {
      if (! isFixed) {
        $s.addClass("rwc-AdminLocDiag-fixed");
        $s.width(this.width);
      }
    } else {
      if (isFixed) {
        $s.removeClass("rwc-AdminLocDiag-fixed");
        $s.css("width", "auto");
      }
    }
  },

  attachInfoWin: function(marker, content) {
    google.maps.event.addListener(marker, 'click', function() {
      this.info_win.setContent(content);
      this.info_win.open(this.map, marker);
    }.bind(this));
  },

  init: function() {
    $(".rwc-AdminLocDiag-lsPoint").click(function(e) {
      e.preventDefault();
      var marker = $(this).closest(".rwc-AdminLocDiag-lsPoint").data("marker");
      if (marker !== null) {
        google.maps.event.trigger(marker, 'click');
      }
    });

    var mapNode = document.getElementsByClassName("rwc-AdminLocDiag-map")[0];
    if (mapNode == undefined) {
      console.log("no map node");
      return;
    }

    this.info_win = new google.maps.InfoWindow({ content: "<div class='rwc-AdminLocDiag-info'>&nbsp;</div>" });

    var myOptions = {
      // show whole Poland
      zoom: 6,
      center: new google.maps.LatLng(52.0, 19.0),
      mapTypeId: 'OSM',
      mapTypeControl: false
    };

    this.map = new google.maps.Map(mapNode, myOptions);
    this.map.mapTypes.set('OSM', rwjMapUtils.osmMapType());
    this.map.setMapTypeId('OSM');

    var bounds = new google.maps.LatLngBounds();
    var labels = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    $(".rwc-AdminLocDiag-lsPoint").each(function() {
      var ob = $(this);
      var order = parseInt(ob.data("order"));
      var loc = new google.maps.LatLng(ob.data("lat"), ob.data("lng"));

      var marker = new google.maps.Marker({
        position: loc,
        map: rwjAdminLocDiag.map,
        label: labels[order]
      });

      var circle = new google.maps.Circle({
        map: rwjAdminLocDiag.map,
        radius: ob.data("radius"),
        clickable: false,
        strokeWeight: 1,
        fillColor: '#AA5555'
      });
      circle.bindTo('center', marker, 'position');

      bounds.extend(loc);
      ob.data("marker", marker);
      rwjAdminLocDiag.attachInfoWin(marker, ob.data("info"));

    });

    if ($(".rwc-AdminLocDiag-lsPoint").size() > 0) {
      this.map.fitBounds(bounds);
    }

    $(".rwc-AdminLocDiag-lrPoint").click(function(e) {
      var ob = $(this);
      if (ob.data("marker") == null) {
        var label = ob.data("label");
        var id = ob.data("id");
        var lat = ob.data("lat");
        var lng = ob.data("lng");
        var loc = new google.maps.LatLng(lat, lng);

        var marker = new google.maps.Marker({
          position: loc,
          map: rwjAdminLocDiag.map,
          label: label
        });

        ob.data("marker", marker);
        rwjAdminLocDiag.attachInfoWin(marker, ob.data("info"));
        ob.addClass("rwc-AdminLocDiag-onMap");

        if (rwjAdminLocDiag.curLr != null) {
          var l1 = new google.maps.LatLng(rwjAdminLocDiag.curLr.lat, rwjAdminLocDiag.curLr.lng);
          var l2 = new google.maps.LatLng(lat, lng);
          var dist = Math.round(google.maps.geometry.spherical.computeDistanceBetween(l1, l2));

          var $div = $(".rwc-AdminLocDiag-dist");
          $div.html(rwjAdminLocDiag.curLr.id + '. ' + rwjAdminLocDiag.curLr.lat + ',' + rwjAdminLocDiag.curLr.lng + "<br/>" +
            id + '. ' + lat + ',' + lng + "<br/>" +
            "dist " + dist + "m<br/>");
        }
        rwjAdminLocDiag.curLr = { id: id, lat: lat, lng: lng };

      } else {
        ob.data("marker").setMap(null);
        ob.data("marker", null);
        ob.removeClass("rwc-AdminLocDiag-onMap");
      }
    });

    this.initStickyMap();
    $(window).scroll(function() {
      rwjAdminLocDiag.updateStickyMap();
    }.bind(this));
  }

};


