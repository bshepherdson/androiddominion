package dominion;

import dominion.Logger;

public class Exchange {
    public volatile Object decision;
    public volatile String response;
    
    private volatile boolean decisionActive = false; 
    private volatile boolean uiWaiting = false;
    
    private Object gameWait = new Object();
    private Object uiWait = new Object();

    private Logger logger;

    public void setLogger(Logger logger) {
      this.logger = logger;
    }
    
    public String postDecision(Object d) {
        if(decisionActive)
            return null;
        
        this.decision = d;
        this.decisionActive = true;
        if(uiWaiting) {
            synchronized(uiWait) {
              uiWait.notify();
            }
        }
        try {
            synchronized(gameWait) {
              gameWait.wait();
            }
        } catch (Exception e) { logger.log(""+e); }
        return response;
    }
    
    public boolean postResponse(String response) {
        logger.log("postResponse: " + response);

        if(!decisionActive)
            return false;
        
        this.response = response;
        this.decisionActive = false;
        synchronized(gameWait) {
          gameWait.notify();
        }
        return true;
    }
    
    // Called by the UI. Blocks until a decision is ready, then returns.
    public void waitForDecision(){
        if(!decisionActive) {
            try {
                uiWaiting = true;
                synchronized(uiWait) {
                  uiWait.wait();
                }
            } catch (Exception e) { logger.log(""+e); }
        }
    }
}
