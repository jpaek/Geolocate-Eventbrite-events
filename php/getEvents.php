<?php
// ============================================================================
// PHP server-side script to get the events matching user query from eventbrite
// and parse into format that can be consumed by the Flex application.

// ----------------------------------------------------------------------------
// Initialize the output event list
$eventList = new SimpleXMLElement('<events></events>');

// Get APP Key
$appKeyFile = fopen('../config/AppKey.txt', 'r');

if (!$appKeyFile) {
  $eventList->addChild('error', 'Fail to get Eventbrite App Key');
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

$queryUrl .= $appKeyParam . '&' . $keywordParam;

// ----------------------------------------------------------------------------
// Get result event list from eventbrite
$resultStr = file_get_contents($queryUrl);

if (!$resultStr) {
  $eventList->addChild('error', 'Failed to get search results from eventbrite');
  echo $eventList->asXML();
  exit();
}

$queryResult = json_decode($resultStr);
if (!$queryResult) {
  $eventList->addChild('error', 'Failed to load search results from eventbrite');
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

  // If the venue does not have latitude and longitude coordinates,
  // skip it.
  if (!(property_exists($resultVenue, 'latitude') && 
        property_exists($resultVenue, 'longitude')) ||
      !(trim($resultVenue->latitude) != '' &&
        trim($resultVenue->longitude) != '')) {
    continue;
  }
 
  // Add the event to the event list
  
  try {
    $event = $eventList->addChild('event');
    $event->addChild('id', $resultEvent->id);
    $event->addChild('title', $resultEvent->title);
    $event->addChild('start_date', $resultEvent->start_date);
    $event->addChild('end_date', $resultEvent->end_date);
    $event->addChild('url', $resultEvent->url);

    $logo = empty($resultEvent->logo) ? '' : $resultEvent->logo;
    $event->addChild('logo', $logo);
    $resultAddress = $resultEvent->venue->address . ', '. 
                     $resultEvent->venue->city . ', ' .
                     $resultEvent->venue->region . ', ' .
                     $resultEvent->venue->country;
    $event->addChild('latitude', $resultVenue->latitude);
    $event->addChild('longitude', $resultVenue->longitude);
    $event->addChild('venue', $resultVenue->name);
    $event->addChild('address', implode(',', [$resultVenue->address,
                                             $resultVenue->address_2,
                                             $resultVenue->city,
                                             $resultVenue->postal_code,
                                             $resultVenue->city]));
    $event->addChild('organizer', $resultEvent->organizer->name);
  }

  // I have noticed that some of the results from eventbrite is missing the
  // required fields.  In this case, just continue on to the next result
  catch (Exception $e) {
    continue;
  }
}


// ----------------------------------------------------------------------------
// Print output.
echo $eventList->asXML();

?>
