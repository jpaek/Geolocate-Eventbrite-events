<?php
// ============================================================================
// PHP server-side script to get the events matching user query from Eventbrite
// and parse into format that can be consumed by the Flex application.

// ----------------------------------------------------------------------------
// Initialize the output event list
$eventList = new SimpleXMLElement('<events></events>');

// Get APP Key
$appKeyFile = fopen('../config/AppKey.txt', 'r');

if (!$appKeyFile) {
  $eventList->addChild('error', 'Missing Eventbrite App Key');
  echo $eventList->asXML();
  exit();
}

$appKey = trim(fgets($appKeyFile));

// ----------------------------------------------------------------------------
// Get user queries
$keyword = empty($_REQUEST['keyword']) ? '' : trim($_REQUEST['keyword']);
$country = empty($_REQUEST['country']) ? '' : trim($_REQUEST['country']);

// Check that the required user query is set
if ($keyword == '') {
  $eventList->addChild('error', 'No keyword or address supplied');
  echo $eventList->asXML();
  exit();
}


// ----------------------------------------------------------------------------
// Construct query URL
$queryUrl = 'https://www.eventbrite.com/json/event_search?';
$appKeyParam = 'app_key=' . $appKey;

$keywordParam = 'keywords=' . urlencode($keyword);

if ($country != '') {
  $keywordParam .= '&country=' . urlencode($country);
}

$queryUrl .= $appKeyParam . '&' . $keywordParam . '&max=100';

// ----------------------------------------------------------------------------
// Get result event list from Eventbrite
$resultStr = file_get_contents($queryUrl);

if (!$resultStr) {
  $eventList->addChild('error', 'No Events Found');
  echo $eventList->asXML();
  exit();
}

$queryResult = json_decode($resultStr);
if (!$queryResult) {
  $eventList->addChild('error', 'Result Parsing Failed');
  echo $eventList->asXML();
  exit();
}

if (property_exists($queryResult, 'error')) {
  $eventList->addChild('error', $queryResult->error->error_type . ': ' . 
                                $queryResult->error->error_message);
  echo $eventList->asXML();
  exit();
}   

// ----------------------------------------------------------------------------
// Parse the event reulst list into format that can be consumed by 
// Geolocate-Eventbrite-events application.
foreach ($queryResult->events as $resultEvent) {

  if (!property_exists($resultEvent, 'event')) {
    continue;
  }

  $resultEvent = $resultEvent->event;

  // If the venue is not assigned to this event, skip it.
  if (!property_exists($resultEvent, 'venue')) {
    continue;
  }
  
  // Get venue
  $resultVenue = $resultEvent->venue;

  // If the venue does not have valid latitude and longitude coordinates,
  // skip it.
  if (!(property_exists($resultVenue, 'latitude') and 
        property_exists($resultVenue, 'longitude')) or
      !(trim($resultVenue->latitude) != '' and
        trim($resultVenue->longitude) != '') or
       ($resultVenue->latitude == 0 and 
        $resultVenue->longitude == 0)) {
    continue;
  }
 
  // Add the event to the event list
  
  set_error_handler('handleError');
  try {
    $event = $eventList->addChild('event');
    $event->addChild('id', 
                     iconv('ISO-8859-1', 'UTF-8', $resultEvent->id));
    $event->addChild('title', 
                     iconv('ISO-8859-1', 'UTF-8', $resultEvent->title));
    $event->addChild('start_date', 
                     iconv('ISO-8859-1', 'UTF-8', $resultEvent->start_date));
    $event->addChild('end_date', 
                     iconv('ISO-8859-1', 'UTF-8', $resultEvent->end_date));
    $event->addChild('url', 
                     iconv('ISO-8859-1', 'UTF-8', $resultEvent->url));
    $event->addChild('latitude', 
                     iconv('ISO-8859-1', 'UTF-8', $resultVenue->latitude));
    $event->addChild('longitude', 
                     iconv('ISO-8859-1', 'UTF-8', $resultVenue->longitude));
    $event->addChild('venue', 
                     iconv('ISO-8859-1', 'UTF-8', $resultVenue->name));
    $event->addChild('organizer', 
                     iconv('ISO-8859-1', 'UTF-8', 
                           $resultEvent->organizer->name));
  }

  // I have noticed that some of the results from Eventbrite is missing the
  // required fields.  In this case, just continue on to the next result
  catch (Exception $e) {
    continue;
  }
}


// ----------------------------------------------------------------------------
// Print output.
echo $eventList->asXML();


// ----------------------------------------------------------------------------
// Error handler function to catch all warnings and errors when
// parsing JSON result into XML doc.
// Source: http://stackoverflow.com/questions/1241728/can-i-try-catch-a-warning 
function handleError($errno, $errstr, $errfile, $errline, array $errcontext)
{
    // error was suppressed with the @-operator
    if (0 === error_reporting()) {
        return false;
    }

    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
}


?>
