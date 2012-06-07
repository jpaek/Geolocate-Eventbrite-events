// =============================================================================
// Display event information on the info window

// =============================================================================
// Import required packages

// -----------------------------------------------------------------------------
// Import Adobe packages
import flashx.textLayout.conversion.TextConverter;

// =============================================================================
// Define public functions

// -----------------------------------------------------------------------------
// Set the event description text, the url to the event, and address of the 
// event venue.
public function setEvent(eventObj:Object):void {

  // Event description text
  var eventDescr:String = "<b>Title:</b> " + eventObj.title + "<br>";
  eventDescr += "<b>Venue:</b> " + eventObj.venue + "<br>";
  eventDescr += "<b>Start:</b> " + eventObj.start_date + "<br>";
  eventDescr += "<b>End:</b> " + eventObj.end_date + "<br>";
  eventDescr += "<b>Organizer:</b> " + eventObj.organizer + "<br><br>";
  eventDescr += "<a href='" + eventObj.url + "' target='_blank'>" +
                "<b>Click Here to Go to Event Page</b></a>"; 

  m_eventDescriptionArea.htmlText = eventDescr;

  // Event URL
  m_eventUrl = eventObj.url;

  // Event Address
  m_eventAddress = eventObj.address;
}


// =============================================================================
// Define private functions

// -----------------------------------------------------------------------------
// Let user tweet the event.
private function prv_tweet():void {

  // Initialize URL request to tweet
  var twitterUrl:String = "https://twitter.com/intent/tweet";
  var twitterRequest:URLRequest = new URLRequest(twitterUrl);
  var tweetParam:URLVariables = new URLVariables();
   
  // Set the URL of the event and text of the tweet.
  tweetParam.url = m_eventUrl;
  tweetParam.text = "Check out this event"
      
  twitterRequest.data = tweetParam;

  // Send the tweet request.
  navigateToURL(twitterRequest, '_blank');
}

// -----------------------------------------------------------------------------
// To be implemented - Get the direction to the event from a given address.
private function prv_getDirection():void {
}

// =============================================================================
// Define private members
private var m_eventUrl:String;
private var m_eventAddress:String;
