// =============================================================================
// Main controller
//   This program reads in the configuration file and allows communication
//  between map and event list components

// =============================================================================
// Import required packages


// -----------------------------------------------------------------------------
// Import Adobe packages
import mx.controls.Alert;
import mx.rpc.AsyncResponder;

// -----------------------------------------------------------------------------
// Import custom packages
import libs.events.ConfigEvent;
import libs.events.MapLocationEvent;
import libs.helpers.Config;

// =============================================================================
// Define private functions.

// -----------------------------------------------------------------------------
// Initialize configuration member and request to load configuration file.
private function prv_init():void {
  m_config = new Config(st_configPath, new Array("attributeList")); 
  m_config.addEventListener(ConfigEvent.LOAD_COMPLETED, prv_configLoadComplete);
  m_config.addEventListener(ConfigEvent.LOAD_FAILED, prv_configLoadFailure);
  m_config.retrieveConfig();
}

// -----------------------------------------------------------------------------
// Called once the configuration has been successfully retrieved and loaded.
// We can no configure out components.
private function prv_configLoadComplete(event:ConfigEvent):void {

  // Initialize children components
  m_eventList.init(m_config);
  m_map.init(m_config);
}

// -----------------------------------------------------------------------------
// Called if something goes wrong when retrieving the configuration
// or at initial parsing into an object. 
private function prv_configLoadFailure(event:ConfigEvent):void {
  Alert.show("Loading Configuration" + event.failureMessage);
}

// -----------------------------------------------------------------------------
// Put the event location on the map.
private function prv_onMapLocationEvent(event:MapLocationEvent):void {
  m_map.findEvent(event.eventInfo);
}


// =============================================================================
// Declare private members

private var m_config:Config;

// -----------------------------------------------------------------------------
// Private constants
private static const st_configPath:String = 'config/Config.xml';
