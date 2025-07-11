//+------------------------------------------------------------------+
//|                                        SellRejectionDetector.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class SellRejectionDetector
  {
private:

public:
                     SellRejectionDetector();
                    ~SellRejectionDetector();
                    
                    bool rejectionByOneCandleFormed(ENUM_TIMEFRAMES _timeFrame);
                    bool rejectionByRangeFormed();
                    bool rejectionByWicksFormed();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellRejectionDetector::SellRejectionDetector()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellRejectionDetector::~SellRejectionDetector()
  {
  }
//+------------------------------------------------------------------+

bool SellRejectionDetector:: rejectionByOneCandleFormed(ENUM_TIMEFRAMES _timeFrame){

    double rejectionCandleClose = iClose(_Symbol,_timeFrame,1);
    double rejectionCandleOpen = iOpen(_Symbol,_timeFrame,1);
    double rejectionCandleLow = iLow(_Symbol,_timeFrame,1);
    double rejectionCandleLowerWickSize ;
    double rejectionCandleBodySize;
    
    if(rejectionCandleOpen > rejectionCandleClose){ // the previous candle closed bearish
         rejectionCandleLowerWickSize = rejectionCandleClose - rejectionCandleLow ;
         rejectionCandleBodySize  = rejectionCandleOpen - rejectionCandleClose;
         if(rejectionCandleBodySize >= rejectionCandleLowerWickSize){
            return true ;
         }
         
    }
    return false ;
}