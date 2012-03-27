// =============================================================================
// This program reads in the user query and display the events matching the user
// query.

// =============================================================================
// Import required packages

// -----------------------------------------------------------------------------
// Import Adobe packages
import mx.controls.Alert;
import mx.rpc.http.HTTPService;
import mx.collections.ArrayCollection;
import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;
import spark.events.IndexChangeEvent;
import mx.managers.CursorManager;


// -----------------------------------------------------------------------------
// Import custom packages
import libs.events.MapLocationEvent;
import libs.helpers.Config;

// =============================================================================
// Define public functions.

// -----------------------------------------------------------------------------
// Reads in required configuration parametes and initialize the HTTPService
// for searching events
public function init(config:Config):void {

  // Initialize HTTP service to search for events
  m_eventListService = new HTTPService();
  m_eventListService.url = config.getValue("eventQueryUrl");
  m_eventListService.method = "POST"
  m_eventListService.addEventListener(ResultEvent.RESULT, prv_eventListResult);
  m_eventListService.addEventListener(FaultEvent.FAULT, prv_eventListFault);

  // Initialize the container to store the matching events
  m_eventList = new ArrayCollection();
  m_eventTable.dataProvider = m_eventList;
}

// =============================================================================
// Define private functons.

// -----------------------------------------------------------------------------
// Helper function to format the event entries in the m_eventTable list.
private function prv_labelEvents(item:Object):String {
  return item.title + " (" + item.start_date + "): " + item.address;
}

// -----------------------------------------------------------------------------
// Send the event search request.
private function prv_requestEventList():void {

  // Clear the m_eventTable
  m_eventList.removeAll();

  // Set busy cursor
  CursorManager.setBusyCursor();

  // Send the request
  m_eventListService.send({keyword: m_keyword.text});
}

// -----------------------------------------------------------------------------
// Request to search for events returned result. Handle the output appropriately
private function prv_eventListResult(event:ResultEvent):void {

  // Remove busy cursor.
  CursorManager.removeBusyCursor();

  // There was a problem with the query.
  // Print the error message.
  if (event.result.events.hasOwnProperty("error")) {
    Alert.show("Event List Query Failed: ", 
               event.result.events.error); 
    return;
  }

  // Display the events found on m_eventTable.
  if (event.result.events.event is ArrayCollection) {
    m_eventList.source = event.result.events.event.source;
  }
  else {
    m_eventList.addItem(event.result.events.event);
  }
  m_eventList.refresh();
}

// -----------------------------------------------------------------------------
// Request to search for events failed.  Print error message.
private function prv_eventListFault(event:FaultEvent):void {
  CursorManager.removeBusyCursor();
  Alert.show("Unable to get list of the events: ", event.fault.faultString);
}


// -----------------------------------------------------------------------------
// Dispatch event to display a selected event on the map UI.
private function prv_requestEventMapping(event:IndexChangeEvent):void {
  dispatchEvent(new MapLocationEvent(MapLocationEvent.MAP_LOCATION,
                                     m_eventList[event.currentTarget
                                                      .selectedIndex]));
}

// =============================================================================
// Define private data members
private var m_eventListService:HTTPService;

[Bindable]
private var m_eventList:ArrayCollection;

