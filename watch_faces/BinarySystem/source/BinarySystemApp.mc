using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class BinarySystemApp extends App.AppBase {

	var mView = new BinarySystemView();

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
        // Earlier builds stored a Berlin test location. Remove it so the
        // real location is used.
        if (App.Storage.getValue("lastStoredLatitude") == 0.9163
            && App.Storage.getValue("lastStoredLongitude") == 0.2341) {
            App.Storage.deleteValue("lastStoredLatitude");
            App.Storage.deleteValue("lastStoredLongitude");
            App.Storage.deleteValue("hasStoredLocationData");
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
        mView.onSettingsChanged();
        Ui.requestUpdate();
    }

}