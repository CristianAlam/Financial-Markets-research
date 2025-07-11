//+------------------------------------------------------------------+
//|                                             SellEntryManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "SellRejectionDetector.mqh"
#include  <Trade/Trade.mqh>





CTrade tradeShort ;

class SellEntryManager
  {
private:
                     
                     bool shortTradeTaken ;
                     bool waitingForRejectionCandle ;
                     bool waitingForRetracement ;
                     bool liquiditySweepEntryTaken ;
                     
public:
                     SellEntryManager();
                    ~SellEntryManager();
                    
                    SellRejectionDetector* sellRejectionDetector ;
                    
                    bool isWaitingForRejectionCandle(){return waitingForRejectionCandle ;}
                    void setWaitingForRejectionCandle(bool _setting){waitingForRejectionCandle = _setting ; }
                    
                    bool isWaitingForRetracement(){return waitingForRetracement;}
                    void setWaitingForRetracement(bool _setting){waitingForRetracement = _setting ;}
                    
                    
                    bool sellTradeTaken();
                    void setTradeTakenStatus(bool _status){shortTradeTaken = _status ;}
                    
                    bool liqEntryIsTaken(){return liquiditySweepEntryTaken;}
                    void setLiquiditySweepEntryTaken(bool _entryStatus){liquiditySweepEntryTaken = _entryStatus ;}
                    
                    
                    
                    
                    ulong takeSellTrade(double _lots,double _stopLoss);
                    ulong takeSellTradeTiger(double _lots, double _stopLoss, double _takeProfit);
                    ulong takeSellTradeTiger(double _lots, double _stopLoss);
                    
                    
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellEntryManager::SellEntryManager()
  {
  
  sellRejectionDetector = new SellRejectionDetector();
  shortTradeTaken = false ;
  waitingForRejectionCandle = false ;
  bool waitingForRetracement = false;
  liquiditySweepEntryTaken = false;
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellEntryManager::~SellEntryManager()
  {
  delete sellRejectionDetector;
  }
//+------------------------------------------------------------------+

bool SellEntryManager:: sellTradeTaken(){

      return shortTradeTaken ;
}

ulong SellEntryManager:: takeSellTrade(double _lots, double _stopLoss){
    
   tradeShort.Sell(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID),_stopLoss);
   ulong tradeTicket = tradeShort.ResultOrder();
   
   Print("Sell entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
  
   
}


ulong  SellEntryManager:: takeSellTradeTiger(double _lots, double _stopLoss, double _takeProfit){

      double netTp =  SymbolInfoDouble(_Symbol, SYMBOL_BID);
      netTp = netTp - _takeProfit ;
   
      tradeShort.Sell(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID),_stopLoss,SymbolInfoDouble(_Symbol, SYMBOL_BID) - netTp);
      
         
   ulong tradeTicket = tradeShort.ResultOrder();
   
   Print("sELL entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;

} 


ulong  SellEntryManager:: takeSellTradeTiger(double _lots, double _stopLoss){
    
   tradeShort.Sell(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID),_stopLoss);              
   ulong tradeTicket = tradeShort.ResultOrder();  
   Print("sELL entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;

}