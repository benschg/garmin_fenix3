using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Activity as Activity;

// references
//https://forums.garmin.com/showthread.php?351367-Sun-rise-sunset/page2
// https://github.com/haraldh/SunCalc
//http://lexikon.astronomie.info/zeitgleichung/

class SunView extends Ui.Drawable
{
    var showSun = false;
    var gpsImage = null;
    var latitude = null;
    var longitude = null;
    var curLoc = null;
    var hasStoredLocationData = false;
    var iconX = 0;
    var iconY = 0;
    var textX = 0;
    var textY = 0;

    function initialize(params)
        {
            Ui.Drawable.initialize(params);
            iconX = params.get(:iconX);
            iconY = params.get(:iconY);
            textX = params.get(:textX);
            textY = params.get(:textY);
            showSun = params.get(:showSun);
            gpsImage = Ui.loadResource(Rez.Drawables.nogps_icon);
            updateLocation();
        }

    function updateLocation() {
        var curLoc = Activity.getActivityInfo().currentLocation;
        if (curLoc != null) {
            var latlon = curLoc.toRadians();
            latitude = latlon[0];
            longitude = latlon[1];
            App.Storage.setValue("lastStoredLatitude", latitude);
            App.Storage.setValue("lastStoredLongitude", longitude);
            App.Storage.setValue("hasStoredLocationData", true);
        } else if (latitude == null) {
            var stored = App.Storage.getValue("hasStoredLocationData");
            if (stored == true) {
                latitude = App.Storage.getValue("lastStoredLatitude");
                longitude = App.Storage.getValue("lastStoredLongitude");
            }
        }
    }

    function draw(dc)
    {
        var showSun = App.getApp().getProperty("ShowSun");

        if (showSun == true)
        {
            // Keep trying to acquire location on each draw tick
            if (latitude == null) {
                updateLocation();
            }

            var dot_color = App.getApp().getProperty("ForegroundColor");
            var bg_transp = Gfx.COLOR_TRANSPARENT;
            dc.setColor(dot_color, bg_transp);

            if (latitude != null) {
                var sc = new SunCalc();
                var now = new Time.Moment(Time.now().value());
                var sunrise_moment = sc.calculate(now, latitude, longitude, SUNRISE);
                var sunset_moment = sc.calculate(now, latitude, longitude, SUNSET);
                var timeInfoSunrise = Time.Gregorian.info(sunrise_moment, Time.FORMAT_SHORT);
                var timeInfoSunset = Time.Gregorian.info(sunset_moment, Time.FORMAT_SHORT);
                var sunInfoString = timeInfoSunrise.hour.format("%01d") + ":" + timeInfoSunrise.min.format("%02d") + " - " + timeInfoSunset.hour.format("%01d") + ":" + timeInfoSunset.min.format("%02d");
                dc.drawText(textX, textY, Gfx.FONT_TINY, sunInfoString, Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawBitmap(iconX, iconY, gpsImage);
            }
        }
    }
}
