using Toybox.Application;
using Toybox.WatchUi;

class InfoFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new InfoFaceView() ];
    }
}
