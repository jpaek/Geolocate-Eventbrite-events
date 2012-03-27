<?php
// ============================================================================
// PHP server-side script to get the events matching user query from eventbrite
// and parse into format that can be consumed by the Flex application.

// ----------------------------------------------------------------------------
// Initialize the output event list
$eventList = new SimpleXMLElement('<events></events>');

// ----------------------------------------------------------------------------
// Get user queries
$keyword = empty($_REQUEST['keyword']) ? '' : $_REQUEST['keyword'];

// Check that the required user query is set
if ($keyword == '') {
  $eventList->addChild('error', 'No keyword or address supplied');
  echo $eventList->asXML();
  exit();
}


// ----------------------------------------------------------------------------
// Load configuration
$config = simplexml_load_file('../config/Config.xml');

if (!$config) {
  $eventList->addChild('error', 'Failed to load configuration file');
  echo $eventList->asXML();
  exit();
}

// ----------------------------------------------------------------------------
// Construct query URL
$queryUrl = 'https://www.eventbrite.com/xml/event_search?';
$appKeyParam = 'app_key=' . $config->eventbriteAppKey;

$keywordParam = '';
if ($keyword != '') {
  $keywordParam = 'keywords=' . urlencode($keyword);
}

$queryUrl .= $appKeyParam . '&' . $keywordParam;


// ----------------------------------------------------------------------------
// Get result event list from eventbrite
$queryStr = file_get_contents($queryUrl);

if (!$queryStr) {
  $eventList->addChild('error', 'Failed to get search results from eventbrite');
  echo $eventList->asXML();
  exit();
}

$queryResult = simplexml_load_string($queryStr);
if (!$queryResult) {
  $eventList->addChild('error', 'Failed to load search results from eventbrite');
  echo $eventList->asXML();
  exit();
}

// ----------------------------------------------------------------------------
// Parse the event reulst list into format that can be consumed by 
// Geolocate-Eventbrite-events application.
foreach ($queryResult->event as $resultEvent) {
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
  $resultAddress = ltrim($resultAddress, ", ");
  $event->addChild('address', $resultAddress);
  $event->addChild('organizer', $resultEvent->organizer->name);
}


// ----------------------------------------------------------------------------
// Print output.
echo $eventList->asXML();

?>
