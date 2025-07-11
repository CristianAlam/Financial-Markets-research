//+------------------------------------------------------------------+
//|                                         BuyTradeManagerTiger.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class BuyTradeManagerTiger
  {
private:
                     
                     ulong tradeId ;
                     string entryType ;
                     bool firstPartialSecured ;
                     bool secondPartialSecured ;
                     bool managedRisk ;                    
                     bool retestWickFormed ;
                     double retestWickLengthInPips ;
                     
                     int riskManagementCandleCounter ;
                     double brokenResistanceLowerEdge ;
                     double brokenResistanceHigherEdge ;
public:

                     ulong getTradeId(){return tradeId ;}
                     
                     bool riskAlreadyManaged(){return managedRisk ;}
                     void manageRisk(){managedRisk = true ;}
                     
                     bool firstPartialIsSecured(){return firstPartialSecured ;}
                     void secureFirstPartial(){firstPartialSecured = true ;}
                     
                     void setBrokenResistancetLowerEdge(double _brokenResistanceLowerEdge){brokenResistanceLowerEdge = _brokenResistanceLowerEdge ;}
                     void setBrokenResistanceHigherEdge(double _brokenResistanceHigherEdge){brokenResistanceHigherEdge = _brokenResistanceHigherEdge ;}
                     
                     double getBrokenResistanceLowerEdge(){return brokenResistanceLowerEdge ;}
                     double getBrokenResistanceHigherEdge(){return brokenResistanceHigherEdge ;}
                     
                     void incrementRiskManagementCandleCoutner(){riskManagementCandleCounter++ ;}
                     void decrementRiskManagementCandleCounter(){riskManagementCandleCounter-- ;}
                     
                     int getRiskManagementCandleCounter(){return riskManagementCandleCounter ;}
                     
                     void setRiskManagementCandleCounter(int count){ riskManagementCandleCounter = count ;}
                     
                     BuyTradeManagerTiger(ulong _tradeId);                    
                    ~BuyTradeManagerTiger();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyTradeManagerTiger::BuyTradeManagerTiger(ulong _tradeId)
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
BuyTradeManagerTiger::~BuyTradeManagerTiger()
  {
  }
//+------------------------------------------------------------------+

