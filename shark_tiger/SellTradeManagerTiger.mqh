//+------------------------------------------------------------------+
//|                                        SellTradeManagerTiger.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class SellTradeManagerTiger
  {
private:
                     ulong tradeId ;
                     string entryType ;
                     bool firstPartialSecured ;
                     bool secondPartialSecured ;
                     bool managedRisk ;
                     int riskManagementCandleCounter ;
                     double brokenSupportHigherEdge ;
                     double brokenSupportLowerEdge ;
public:
                     ulong getTradeId(){return tradeId ;}
                     
                     bool riskAlreadyManaged(){return managedRisk ;}
                     void manageRisk(){managedRisk = true ;}
                     
                     bool firstPartialIsSecured(){return firstPartialSecured ;}
                     void secureFirstPartial(){firstPartialSecured = true ;}
                     
                     bool retestWickFormed ;
                     double retestWickLengthInPips ;
                     
                     void setBrokenSupportHigherEdge(double _brokenSupportHigherEdge){brokenSupportHigherEdge = _brokenSupportHigherEdge ;}
                     void setBrokenSupportLowerEdge(double _brokenSupportLowerEdge){brokenSupportLowerEdge = _brokenSupportLowerEdge ;}
                     
                     double getBrokenSupportHigherEdge(){return brokenSupportHigherEdge ;}
                     double getBrokenSupportLowerEdge(){return brokenSupportLowerEdge;}
                     
                     void incrementRiskManagementCandleCoutner(){riskManagementCandleCounter++ ;}
                     void decrementRiskManagementCandleCounter(){riskManagementCandleCounter-- ;}
                     
                     int getRiskManagementCandleCounter(){return riskManagementCandleCounter ;}
                     void setRiskManagementCandleCounter(int count){ riskManagementCandleCounter = count ;}
                    
                     
                     SellTradeManagerTiger(ulong _tradeId);
                    ~SellTradeManagerTiger();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellTradeManagerTiger::SellTradeManagerTiger(ulong _tradeId)
  {
  
      tradeId = _tradeId ;
      firstPartialSecured = false ;
      secondPartialSecured = false ;
      managedRisk = false ;
      
      retestWickFormed = false ;
      retestWickLengthInPips = 0 ;
      riskManagementCandleCounter = 0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellTradeManagerTiger::~SellTradeManagerTiger()
  {
  }
//+------------------------------------------------------------------+
