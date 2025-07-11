//+------------------------------------------------------------------+
//|                                          MarketObserverTiger.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include  "Zone.mqh"
#include  "ZoneContainer.mqh"


// ALGORITHM CLASSES INCLUDES

#include "NewCandleDetector.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MarketObserverTiger
  {
   // THIS CLASS HAS ACCESS TO ZONE CONTAINER, HOWEVER IT MUST NOT CHANGE IT IT ONLY READS FROM THE ZONECONTAINER CLASS
private:



public:
                     MarketObserverTiger();
                    ~MarketObserverTiger();

   string            zoneReached();
   bool              candleClosedAboveResistanceByIndex(int _index,ENUM_TIMEFRAMES tf,ZoneContainer& resistanceZoneContainer); // the index is a specific zone from the zones container
   bool              candleClosedBelowSupportByIndex(int _index,ENUM_TIMEFRAMES tf,ZoneContainer& supportZoneContainer);  // the index is a specific zone from the zones container




  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MarketObserverTiger::MarketObserverTiger()
  {


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MarketObserverTiger::~MarketObserverTiger()
  {
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketObserverTiger:: candleClosedAboveResistanceByIndex(int _index,ENUM_TIMEFRAMES tf,ZoneContainer& resistanceZoneContainer)
  {

   double previousCandleClose = iClose(_Symbol,tf,1);

   if((previousCandleClose > resistanceZoneContainer.getZoneByIndex(_index).getHigherEdge()))
     {

      return true ;
     }

   return false ;
  }
  
  
  
bool MarketObserverTiger:: candleClosedBelowSupportByIndex(int _index, ENUM_TIMEFRAMES tf, ZoneContainer& supportZoneContainer){


   double previousCandleClose = iClose(_Symbol,tf,1);
   if(previousCandleClose < supportZoneContainer.getZoneByIndex(_index).getLowerEdge()){
         return true ;
   }
   
   return false ;
}
