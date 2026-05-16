using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class BinarySystemApp extends App.AppBase {

	var mView = new BinarySystemView();

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
        App.Storage.setValue("BinaryRadius", 14);
        // Seed a test location (Berlin) if none is stored yet
        if (App.Storage.getValue("hasStoredLocationData") != true) {
            App.Storage.setValue("lastStoredLatitude", 0.9163);   // 52.5°N in radians
            App.Storage.setValue("lastStoredLongitude", 0.2341);  // 13.4°E in radians
            App.Storage.setValue("hasStoredLocationData", true);
        }
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ mView ];
    }

    //! New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        Ui.requestUpdate();
        mView.onSettingsChanged();
    }

}