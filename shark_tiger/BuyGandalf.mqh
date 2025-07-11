//+------------------------------------------------------------------+
//|                                                   BuyGandalf.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include  <Trade/Trade.mqh>

CTrade tradeLong ;
class BuyGandalf
  {
private:

                     bool longTradeTaken ;
                     ulong longTrades[10] ;
                    

public:
                     BuyGandalf();
                    ~BuyGandalf();
                    
                                              
                    
                     bool buyTradeTaken();
                     void setTradeTakenStatus(bool _status){longTradeTaken = _status ; Print("long trade taken flag has been set to true");} 
                     
                     
                     ulong takeBuyTrade(double _lots,double _stopLoss);
                     ulong takeBuyTradeGandalf(double _lots,double _stopLoss);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyGandalf::BuyGandalf()
  {
  
      longTradeTaken = false ;
    
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyGandalf::~BuyGandalf()
  {
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+


bool BuyGandalf:: buyTradeTaken(){


return longTradeTaken ;
}


ulong BuyGandalf:: takeBuyTrade(double _lots, double _stopLoss){
    
   tradeLong.Buy(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_ASK),_stopLoss);
   
   ulong tradeTicket = tradeLong.ResultOrder();
   
   Print("Buy entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
  
   
}


ulong BuyGandalf:: takeBuyTradeGandalf(double _lots,double _stopLoss){
   
   tradeLong.Buy(NormalizeDouble(_lots,2),_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_ASK),_stopLoss);
   
   ulong tradeTicket = tradeLong.ResultOrder();
   
   Print("Buy entry manager has taken a trade, ticket: " + tradeTicket);
   return tradeTicket;
   
}
