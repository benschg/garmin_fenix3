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
    // when the location was last checked (seconds): every minute until one
    // is found, then once an hour
    var locationCheckTime = null;

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
        }
    }

    //! Current position in radians as [lat, lng], or null if unknown:
    //! the watch's last GPS fix, else the location of the phone's weather data
    function readLocation()
    {
        var location = Activity.getActivityInfo().currentLocation;
        if (location == null && Toybox has :Weather)
        {
            var conditions = Toybox.Weather.getCurrentConditions();
            if (conditions != null && conditions has :observationLocationPosition)
            {
                location = conditions.observationLocationPosition;
            }
        }
        return location == null ? null : location.toRadians();
    }

    //! Picks up the current location, falling back to the last stored one.
    //! Returns true if the location changed.
    function updateLocation()
    {
        var latlon = readLocation();
        if (latlon == null)
        {
            if (latitude == null && App.Storage.getValue("hasStoredLocationData") == true)
            {
                latitude = App.Storage.getValue("lastStoredLatitude");
                longitude = App.Storage.getValue("lastStoredLongitude");
                return true;
            }
            return false;
        }

        // ignore tiny changes (0.001 rad is about 6 km) to avoid storage writes
        if (latitude != null
            && (latlon[0] - latitude).abs() < 0.001
            && (latlon[1] - longitude).abs() < 0.001)
        {
            return false;
        }
        latitude = latlon[0];
        longitude = latlon[1];
        App.Storage.setValue("lastStoredLatitude", latitude);
        App.Storage.setValue("lastStoredLongitude", longitude);
        App.Storage.setValue("hasStoredLocationData", true);
        return true;
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

        var now = Time.now();
        var nowSeconds = now.value();
        var interval = latitude == null ? 60 : 3600;
        if (locationCheckTime == null || nowSeconds - locationCheckTime >= interval)
        {
            locationCheckTime = nowSeconds;
            if (updateLocation())
            {
                sunText = null;
            }
        }

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

        if (latitude == null)
        {
            dc.drawBitmap(iconX, iconY, gpsImage);
            return;
        }

        var today = Gregorian.info(now, Time.FORMAT_SHORT).day;
        if (sunText == null || sunTextDay != today)
        {
            var sc = new SunCalc();
            sunText = formatTime(sc.calculate(now, latitude, longitude, SUNRISE)) + " - "
                    + formatTime(sc.calculate(now, latitude, longitude, SUNSET));
            sunTextDay = today;
        }
        dc.drawText(textX, textY, Gfx.FONT_TINY, sunText, Gfx.TEXT_JUSTIFY_CENTER);
    }
}
