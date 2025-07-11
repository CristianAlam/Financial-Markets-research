//+------------------------------------------------------------------+
//|                                                  SellGandalf.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include  <Trade/Trade.mqh>

CTrade tradeShort ;

class SellGandalf
  {
private:
                     bool shortTradeTaken ;
                     ulong longTrades[10] ;

public:
                     SellGandalf();
                    ~SellGandalf();
                    
                    bool sellTradeTaken();
                    void setTradeTakenStatus(bool _status){shortTradeTaken = _status ; Print("long trade taken flag has been set to true");} 
                     
                     
                    ulong takeSellTrade(double _lots,double _stopLoss);
                    ulong takeSellTradeGandalf(double _lots,double _stopLoss);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellGandalf::SellGandalf()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellGandalf::~SellGandalf()
  {
  }
//+------------------------------------------------------------------+


bool SellGandalf:: sellTradeTaken(){


return shortTradeTaken ;
}



ulong SellGandalf:: takeSellTrade(double _lots, double _stopLoss){
    
   tradeShort.Sell(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID),_stopLoss);
   
   ulong tradeTicket = tradeShort.ResultOrder();
   
   Print("Sell entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
  
   
}


ulong SellGandalf:: takeSellTradeGandalf(double _lots,double _stopLoss){
   
   tradeShort.Sell(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID),_stopLoss);
   
   ulong tradeTicket = tradeShort.ResultOrder();
   
   Print("Sell entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
   
}


