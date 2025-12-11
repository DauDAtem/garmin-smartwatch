import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var app = getApp();
        if (app.isRunning() || app.isPaused()) {
            app.stopTimer();
            app.resetTimer();
        }

        var settingsView = new SettingsView();

        //Switches the screen to settings view by holding up button
        WatchUi.pushView(settingsView, new SettingsDelegate(settingsView), WatchUi.SLIDE_UP);

        return true;
    }

    function onNextPage() as Boolean {
        var advancedView = new AdvancedView();

        // Switches the screen to advanced view by holding down button
        WatchUi.pushView(advancedView, new AdvancedViewDelegate(advancedView), WatchUi.SLIDE_DOWN);

        return true;
    }

    function onBack() as Boolean {
        var app = getApp();
        if (app.isRunning() || app.isPaused()) {
            app.stopTimer();
            app.resetTimer();
        }
        return true;
    }

    function onKey(key as Number, state as Number) as Boolean {
        if (state == WatchUi.KEY_PRESS) {
            if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
                var app = getApp();

                if (!app.isRunning()) {
                    app.startTimer();
                } else {
                    app.stopTimer();
                }

                // Switch to the running view and keep navigation consistent
                WatchUi.switchToView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                return true;
            }
        }

        return false;
    }

}