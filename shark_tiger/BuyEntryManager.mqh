//+------------------------------------------------------------------+
//|                                              BuyEntryManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "BuyRejectionDetector.mqh"
#include  <Trade/Trade.mqh>

CTrade tradeLong ;
class BuyEntryManager
  {
private:
                    
                     bool longTradeTaken ;
                     bool waitingForRejectionCandle;
                     bool waitingForRetracement ;
                     
                     
                     
public:
                     BuyEntryManager();
                    ~BuyEntryManager();
                    
                     BuyRejectionDetector* buyRejectionDetector ;
                    
                     bool isWaitingForRejectionCandle(){return waitingForRejectionCandle ;}
                     void setWaitingForRejectionCandle(bool _setting){waitingForRejectionCandle = _setting ;}
                     
                     bool isWaitingForRetracement(){return waitingForRetracement;}
                     void setWaitingForRetracement(bool _setting){waitingForRetracement = _setting ;}                                  
                    
                     bool buyTradeTaken();
                     void setTradeTakenStatus(bool _status){longTradeTaken = _status ; Print("long trade taken flag has been set to true");} 
                     
                     
                     ulong takeBuyTrade(double _lots,double _stopLoss);
                     ulong takeBuyTradeTiger(double _lots,double _stopLoss,double _takeProfit);
                     ulong takeBuyTradeTiger(double _lots,double _stopLoss);
                    
                    
                     
                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyEntryManager::BuyEntryManager()
  {
    buyRejectionDetector = new BuyRejectionDetector();
    longTradeTaken = false ;
    waitingForRejectionCandle = false ;
    waitingForRetracement = false ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyEntryManager::~BuyEntryManager()
  {
      delete buyRejectionDetector ;
  }
//+------------------------------------------------------------------+


bool BuyEntryManager:: buyTradeTaken(){


return longTradeTaken ;
}


ulong BuyEntryManager:: takeBuyTrade(double _lots, double _stopLoss){
    
   tradeLong.Buy(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_ASK),_stopLoss);
   
   ulong tradeTicket = tradeLong.ResultOrder();
   
   Print("Buy entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
  
   
}


ulong BuyEntryManager:: takeBuyTradeTiger(double _lots,double _stopLoss, double _takeProft){ // first version, take the buy with fixed tp
   
   double netTp = _takeProft - SymbolInfoDouble(_Symbol, SYMBOL_ASK) ;
   
   tradeLong.Buy(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_ASK),_stopLoss,SymbolInfoDouble(_Symbol, SYMBOL_ASK) + netTp);
   
   ulong tradeTicket = tradeLong.ResultOrder();
   
   Print("Buy entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
   
}


ulong BuyEntryManager:: takeBuyTradeTiger(double _lots,double _stopLoss){ // second version, take the buy without a fixed tp
   
   
   tradeLong.Buy(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_ASK),_stopLoss);
   
   ulong tradeTicket = tradeLong.ResultOrder();
   
   Print("Buy entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
   
}

