package libs.events {
  
  import flash.events.Event;

  // =========================================================================
  // Implements events triggered during configuration
  public class ConfigEvent extends Event {
    
    // -----------------------------------------------------------------------
    // Valid event types
    
    public static const LOAD_COMPLETED:String   = 'configLoadCompleted';
    public static const LOAD_FAILED:String      = 'configLoadFailed';
    public static const CONFIG_COMPLETED:String = 'configCompleted';
    public static const CONFIG_FAILED:String    = 'configFailed';
    
    // -----------------------------------------------------------------------
    // Construction
    public function ConfigEvent(type:String, 
                                failMsg:String = null,
                                bubbles:Boolean = false, 
                                cancelable:Boolean = false)
    {
      super(type, bubbles, cancelable);
      m_failMsg = failMsg;
    }
    
    // -----------------------------------------------------------------------
    // Properties
    
    public function get failureMessage():String {
      return m_failMsg;
    }
    
    // -----------------------------------------------------------------------
    // Data Members
    
    private var m_failMsg:String;
  }
}
