using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.Activity as Activity;

// references
//https://forums.garmin.com/showthread.php?351367-Sun-rise-sunset/page2
// https://github.com/haraldh/SunCalc
//http://lexikon.astronomie.info/zeitgleichung/

class SunView extends Ui.Drawable
{
    var showSun = false;
    var color;
    var gpsImage = null;
    var latitude = null;
    var longitude = null;
    var iconX = 0;
    var iconY = 0;
    var textX = 0;
    var textY = 0;

    // sunrise/sunset only changes once a day, so the text is cached
    var sunText = null;
    var sunTextDay = null;

    function initialize(params)
    {
        Ui.Drawable.initialize(params);
        iconX = params.get(:iconX);
        iconY = params.get(:iconY);
        textX = params.get(:textX);
        textY = params.get(:textY);

        showSun = App.getApp().getProperty("ShowSun") == true;
        color = App.getApp().getProperty("ForegroundColor");
        if (showSun)
        {
            gpsImage = Ui.loadResource(Rez.Drawables.nogps_icon);
            updateLocation();
        }
    }

    function updateLocation()
    {
        var curLoc = Activity.getActivityInfo().currentLocation;
        if (curLoc != null)
        {
            var latlon = curLoc.toRadians();
            latitude = latlon[0];
            longitude = latlon[1];
            App.Storage.setValue("lastStoredLatitude", latitude);
            App.Storage.setValue("lastStoredLongitude", longitude);
            App.Storage.setValue("hasStoredLocationData", true);
        }
        else if (App.Storage.getValue("hasStoredLocationData") == true)
        {
            latitude = App.Storage.getValue("lastStoredLatitude");
            longitude = App.Storage.getValue("lastStoredLongitude");
        }
    }

    function formatTime(moment)
    {
        if (moment == null)
        {
            return "--:--";     // no sunrise/sunset (polar day/night)
        }
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return info.hour.format("%01d") + ":" + info.min.format("%02d");
    }

    function draw(dc)
    {
        if (!showSun)
        {
            return;
        }

        // keep trying to acquire a location until one is found
        if (latitude == null)
        {
            updateLocation();
        }

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);

        if (latitude == null)
        {
            dc.drawBitmap(iconX, iconY, gpsImage);
            return;
        }

        var now = Time.now();
        var today = Gregorian.info(now, Time.FORMAT_SHORT).day;
        if (sunText == null || sunTextDay != today)
        {
            var sc = new SunCalc();
            sunText = formatTime(sc.calculate(now, latitude, longitude, SUNRISE)) + " - "
                    + formatTime(sc.calculate(now, latitude, longitude, SUNSET));
            sunTextDay = today;        }
        dc.drawText(textX, textY, Gfx.FONT_TINY, sunText, Gfx.TEXT_JUSTIFY_CENTER);
    }
}
