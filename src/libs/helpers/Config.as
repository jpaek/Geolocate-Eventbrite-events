// ===========================================================================
// Class to wrap up a configuration. This expects to retrieve an XML 
// formatted file from a specified URL. The XML retrieved must be of the 
// format:
//   <config>
//     <configItem1>value1</configItem1>
//     <configItem2>value2</configItem2>
//     <configItem3>
//       <subConfigItem1>subValue1</configItem1>
//       <subConfigItem2>subValue2</configItem2>
//       <subConfigItem3>subValue3</configItem3>
//       <subConfigItem4>subValue4</configItem4>
//       <subConfigItem5>subValue4</configItem5>
//     </configItem3>
//     ...
//     </config>
//       
// The URL is specified at constructiontime and should be given relative 
// to the application path.
//
// This object will dispatch a ConfigEvent when it has something to report
// back to anyone listening. It will dispatch a 'configLoadCompleted' event
// on successful loading of the configuration. It will disptach a 
// 'configLoadFailed' event when the configuration could not be properly 
// loaded.
//
// The XML file will be 'automagically' converted by flex into an Object.
// We wrap up that object and provide a predcitable interface.
//
// NOTE: This class can only be instatiated within action script. It has no
// corresponding mxml component.
package libs.helpers {
  import flash.events.EventDispatcher;
  
  import libs.events.ConfigEvent;
  
  import mx.rpc.events.FaultEvent;
  import mx.rpc.events.ResultEvent;
  import mx.rpc.http.HTTPService;

  import mx.collections.ArrayCollection;

  import mx.controls.Alert;


  // ==========================================================================
  // Class defining Config Event
  public class Config extends EventDispatcher{

    // ------------------------------------------------------------------------
    // Constructor
    public function Config(url:String = "", collectionList:Array = null) {
      m_httpService = new HTTPService();
      m_httpService.url = url;
      m_httpService.method = 'POST';
      m_httpService.addEventListener(ResultEvent.RESULT, prv_httpResult);
      m_httpService.addEventListener(FaultEvent.FAULT, prv_httpFault);

      m_collectionList = collectionList;
    }

    // ========================================================================
    // Interface

    // ------------------------------------------------------------------------ 
    // Will kick off our request to retrive the configuration.
    // 
    // This will result in either a LOAD_COMPLETED or LOAD_FAILED ConfigEvent
    // being dispatched. Please be listening for both if you use this
    // method!
    public function retrieveConfig():void {
      m_httpService.send(); 
    }

    // ------------------------------------------------------------------------
    // Will retrieve the configuration value specified. If the configuration
    // value is not present and the defaultValue is not given, and Error
    // will be thrown.
    public function getValue(parameter:String, defaultValue:* = null):* {
      var value:* = m_config[parameter];
      if (value == null) {
        if (defaultValue != null) {
          return defaultValue;
        }
        throw new Error('Required config parameter [' + parameter + '] is '
                         + 'missing');
      }
      return value;
    }

    // ========================================================================
    // Event Handlers

    // ------------------------------------------------------------------------
    // Called when the HTTP result is ready (i.e. we have success)
    private function prv_httpResult(event:ResultEvent):void {
      var fault:String = '';
   
      if (event.result == null) {
        fault = 'Received an empty response from URL: ' + m_httpService.url;
      }
      else if (event.result.config == null) {
        fault = 'Received an invalid configuration; expected root node of ' +
                '"config" from url: ' + m_httpService.url;
      }

      if (fault != '') {
        this.dispatchEvent(new ConfigEvent(ConfigEvent.LOAD_FAILED, fault));
        return;
      }
      
      m_config = new Object();
      for (var parameter:String in event.result.config) {
        if (m_collectionList.lastIndexOf(parameter) != -1) {
          m_config[parameter] = new ArrayCollection();
          for (var parameterField:String in event.result.config[parameter]) {
            for each (var value:String in 
                      event.result.config[parameter][parameterField]) {
              m_config[parameter].addItem(value);
            }
          }

        }
        else {
          m_config[parameter] = event.result.config[parameter];
        }
      }

      this.dispatchEvent(new ConfigEvent(ConfigEvent.LOAD_COMPLETED));
    }

    // ------------------------------------------------------------------------
    // Called when the HTTP call failed
    private function prv_httpFault(event:FaultEvent):void {
      this.dispatchEvent(new ConfigEvent(ConfigEvent.LOAD_FAILED,
                                         event.fault.toString()));
    }

    // ========================================================================
    // Data members
 
    // The configuration container
    private var m_config:Object = new Object();
    
    // The HTTPSerivce used to retrieve the configuration
    private var m_httpService:HTTPService;

    // A list of parameter names.
    // The parameters in this list are ArrayCollection. 
    private var m_collectionList:Array;
  }
}
