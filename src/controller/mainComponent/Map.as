// =============================================================================
// This program finds the location of the selected event and displays
// the location and information of the event on the map 

// =============================================================================
// Import required packages

// -----------------------------------------------------------------------------
// Import ArcGIS package
import com.esri.ags.Graphic;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.tasks.supportClasses.AddressCandidate;
import com.esri.ags.utils.WebMercatorUtil;
import com.esri.ags.SpatialReference;
import com.esri.ags.geometry.Extent;

// -----------------------------------------------------------------------------
// Import Adobe packages
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import mx.collections.ArrayCollection;

import flashx.textLayout.conversion.TextConverter;

// -----------------------------------------------------------------------------
// Import custom packages
import libs.helpers.Config;

// =============================================================================
// Define public functions.

// -----------------------------------------------------------------------------
// Read the required parameters from configuration object, and set the
// the private members
public function init(config:Config):void {

  // Set the URL of the locator service
  m_locateTask.url = config.getValue("locatorUrl");
  m_mapLayer.url = config.getValue("mapUrl"); 

  // Initialize map extent
  m_map.extent = new Extent(config.getValue('lonMin'), 
                            config.getValue('latMin'), 
                            config.getValue('lonMax'), 
                            config.getValue('latMax'), 
                           new SpatialReference(config.getValue('wkid')));

  // Set the output fields to be returned from locator service
  m_locatorOutFields = new Array();
  if (config.getValue("locatorOutFields") is ArrayCollection) {
    m_locatorOutFields = config.getValue("locatorOutFields").source;
  }
  else {
    m_locatorOutFields.add(config.getValue("locatorOutFields"));
  }
}

// -----------------------------------------------------------------------------
// Request to find the geographical location of the given event venue address 
public function findEvent(eventInfo:Object):void {

  // Get the address of the event venue
  var eventVenue:Object = { SingleLine: eventInfo.address };

  // Set the current event 
  m_currentEvent = eventInfo;

  // Clear the previously drawn event info
  m_graphicsLayer.clear();
  m_map.infoWindow.hide();

  // Send the request to get event location
  m_locateTask.outSpatialReference = m_map.spatialReference;
  m_locateTask.addressToLocations(eventVenue, m_locatorOutFields, 
                                  new AsyncResponder(prv_eventFound, 
                                                     prv_eventSearchFault));
}

// =============================================================================
// Define private functions

// -----------------------------------------------------------------------------
// Request to find the event location returned output.  Display the event 
// location and info on the map.
private function prv_eventFound(candidates:Array, token:Object = null):void {

  // Found location matching given address
  if (candidates.length > 0) {

    // Get the object containing location and initialize the placemark
    var addressCandidate:AddressCandidate = candidates[0];
    var eventGraphic:Graphic = new Graphic();

    // Set the placemark
    eventGraphic.geometry = addressCandidate.location;
    eventGraphic.symbol = m_eventSymbol;
    eventGraphic.toolTip = addressCandidate.address.toString();
    eventGraphic.id = "graphic";

    // Show the information about the events
    prv_showEventInfo(addressCandidate.location);
    //eventGraphic.addEventListener(MouseEvent.CLICK, prv_showEventInfo);
    m_graphicsLayer.add(eventGraphic);

    // Center the map to the event location
    m_map.centerAt(eventGraphic.geometry as MapPoint);

    // Zoom into the location of the map
    m_map.extent = eventGraphic.geometry.extent;
    m_map.scale = prv_findEventZoomLevel(addressCandidate.attributes.Loc_name);
  }

  // No event matched the given address
  else {
    Alert.show("Sorry, couldn't find a location of the event");
  }
}

// -----------------------------------------------------------------------------
// Fail to get output from the request to get location of the event. 
// Print the error message.
private function prv_eventSearchFault(info:Object, token:Object = null):void {
  Alert.show("Failure: \n" + info.toString());
}

// -----------------------------------------------------------------------------
// Get the appropriate zoom level for given event location.
private function prv_findEventZoomLevel(locationName:String):int {

  // US RoofTop
  if (locationName.search("RoofTop") > 0) {
    return 10000;
  }

  // Address
  if (locationName.search("Address") > 0) {
    return 10000;
  }
  
  // US_Streets, CAN_Streets, CAN_StreetName, 
  // EU_Street_Addr* or EU_Street_Name 
  if (locationName.search("Street") > 0) {
    return 15000;
  }

  // US ZIP4 code or Canada Postal code
  if (locationName.search("ZIP4") > 0 ||
      locationName.search("Postcode") > 0) {
    return 20000;
  }

  // US Zipcode
  if (locationName.search("Zipcode") > 0) {
    return 40000;
  }

  // US_CitySTate, CAN_CityProv
  if (locationName.search("City") > 0) {
    return 150000;
  }

  // Default zoom-level
  return 500000;
}

// -----------------------------------------------------------------------------
// Show the event information on info window
private function prv_showEventInfo(location:MapPoint):void {
  m_eventInfoWindow.setEvent(m_currentEvent);  

  m_map.infoWindow.label = "Event Info";
  m_map.infoWindow.show(location);

  //m_map.infoWindow.show(m_map.toMapFromStage(event.stageX, event.stageY));
}

// =============================================================================
// Define private data members
private var m_currentEvent:Object;
private var m_locatorOutFields:Array;
