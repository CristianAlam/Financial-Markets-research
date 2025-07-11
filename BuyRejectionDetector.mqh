//+------------------------------------------------------------------+
//|                                         BuyRejectionDetector.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class BuyRejectionDetector
  {
private:

public:
                     BuyRejectionDetector();
                    ~BuyRejectionDetector();
                    
                    bool rejectionByOneCandleFormed(ENUM_TIMEFRAMES _timeFrame);
                    bool rejectionByRangeFormed();
                    bool rejectionByWicksFormed();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyRejectionDetector::BuyRejectionDetector()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyRejectionDetector::~BuyRejectionDetector()
  {
  }
//+------------------------------------------------------------------+


bool BuyRejectionDetector:: rejectionByOneCandleFormed(ENUM_TIMEFRAMES _timeFrame){

    double rejectionCandleClose = iClose(_Symbol,_timeFrame,1);
    double rejectionCandleOpen = iOpen(_Symbol,_timeFrame,1);
    double rejectionCandleHigh = iHigh(_Symbol,_timeFrame,1) ; 
    double rejectionCandleHigherWickSize ;
    double rejectionCandleBodySize ;
    
    if( rejectionCandleClose > rejectionCandleOpen ){ // the previous candle closed bullish
         rejectionCandleHigherWickSize = rejectionCandleHigh - rejectionCandleClose;
         rejectionCandleBodySize = rejectionCandleClose - rejectionCandleOpen;
         if(rejectionCandleBodySize >= rejectionCandleHigherWickSize){
            return true ;
         }
         
    }
    return false ;
}