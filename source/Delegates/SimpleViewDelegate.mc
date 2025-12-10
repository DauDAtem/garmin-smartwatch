import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    var currentView = null;

     function initialize() {
        BehaviorDelegate.initialize();
    }


    function onKey(keyEvent as WatchUi.KeyEvent){
        var key = keyEvent.getKey();

        if(key == WatchUi.KEY_UP)//block GarminControlMenu (the triangle screen)
        {
            return true;
        }

        if(key == WatchUi.KEY_DOWN){
            currentView = new AdvancedView();

            // Switches the screen to advanced view by clocking down button
            WatchUi.pushView(currentView, new AdvancedViewDelegate(currentView), WatchUi.SLIDE_DOWN);
        }

        return true;
    }


    function onSwipe(SwipeEvent as WatchUi.SwipeEvent){
        var direction = SwipeEvent.getDirection();
            
        if (direction == WatchUi.SWIPE_UP) {
            currentView = new AdvancedView(); 
            System.println("Swiped Down");
            WatchUi.pushView(currentView, new AdvancedViewDelegate(currentView), WatchUi.SLIDE_DOWN);
        }

        if(direction == WatchUi.SWIPE_LEFT){
            currentView = new SettingsView();
            System.println("Swiped Left");
            WatchUi.pushView(currentView, new SettingsDelegate(currentView), WatchUi.SLIDE_LEFT);
        }

        return true;
    }

    function onBack(){
        //dont pop view and exit app
        return true;
    }

}