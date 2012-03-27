package libs.events {
  import flash.events.Event;

  // ===========================================================================
  // Implements event triggered when user request to display an event on the 
  // map.
  public class MapLocationEvent extends Event {

    // =========================================================================
    // Public data members
    
    // -------------------------------------------------------------------------
    // Valid event types
    public static const MAP_LOCATION:String = "mapLocation";

    // -------------------------------------------------------------------------
    // event information
    public var eventInfo:Object;

    // =========================================================================
    // Public interface

    // -------------------------------------------------------------------------
    // Construction
    public function MapLocationEvent(type:String, eventInfo:Object) {
      super(type);

      this.eventInfo = eventInfo;
    }

    // -------------------------------------------------------------------------
    // Override required clone method.
    override public function clone():Event {
      return new MapLocationEvent(type, eventInfo);
    }
  }
}   
