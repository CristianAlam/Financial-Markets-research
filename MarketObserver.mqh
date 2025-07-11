//+------------------------------------------------------------------+
//|                                               MarketObserver.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include  "Zone.mqh"
#include  "ZoneContainer.mqh"
#include  "LowFractal.mqh"
#include  "HighFractal.mqh"
#include  "LowFractalContainer.mqh"
#include  "HighFractalContainer.mqh"


// ALGORITHM CLASSES INCLUDES

#include "NewCandleDetector.mqh"


// LIVE FORMING FRACTALS HANDLER CLASS




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MarketObserver
  {
   // THIS CLASS HAS ACCESS TO ZONE CONTAINER, HOWEVER IT MUST NOT CHANGE IT IT ONLY READS FROM THE ZONECONTAINER CLASS
private:
   /*NewCandleDetector* newCandleDetector_H4;
   NewCandleDetector* newCandleDetector_H1 ;
   NewCandleDetector* newCandleDetector_M30;
   NewCandleDetector* newCandleDetector_M1 ;*/
   ZoneContainer* zoneContainer ; // must not be changed from this class
   bool closestResistanceWaiting ;
   bool closestSupportWaiting ;
public:
                     MarketObserver(ZoneContainer* _zoneContainer);
                    ~MarketObserver();

   string            zoneReached();

   Zone*             getClosestResistanceZone() {return zoneContainer.getHigherPivotIndexZone();}
   Zone*             getClosestSupportZone() {return zoneContainer.getLowerPivotIndexZone();}
   bool              reachedClosestSupportZone();
   bool              reachedClosestResistanceZone();


   bool              bearishCandleClosedInsideClosestSupportZone(ENUM_TIMEFRAMES tf);
   bool              bullishCandleClosedInsideClosestResistanceZone(ENUM_TIMEFRAMES tf);

   bool              candleClosedBelowClosestSupportZone(ENUM_TIMEFRAMES tf);
   bool              candleClosedAboveClosestResistanceZone(ENUM_TIMEFRAMES tf);
   bool              candleClosedAboveResistanceByIndex(int _index,ENUM_TIMEFRAMES tf); // the index is a specific zone from the zones container
   bool              candleClosedBelowSupportByIndex(int _index,ENUM_TIMEFRAMES tf);  // the index is a specific zone from the zones container

   bool              isClosestResistanceWaiting() {return closestResistanceWaiting;}
   bool              isClosestSupportWaiting() {return closestSupportWaiting;}

   void              setClosestResistanceWaiting(bool _state) {closestResistanceWaiting = _state ;}
   void              setClosestSupportWaiting(bool _state) {closestSupportWaiting = _state ;}


   string            giveMarketReport();



  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MarketObserver::MarketObserver(ZoneContainer* _zoneContainer)
  {
   /*newCandleDetector_H4 = new NewCandleDetector("PERIOD_H4") ;
   newCandleDetector_H1 = new NewCandleDetector("PERIOD_H1");
   newCandleDetector_M30 = new NewCandleDetector("PERIOD_M30");
   newCandleDetector_M1 = new NewCandleDetector("PERIOD_M1");*/

   zoneContainer = _zoneContainer ;
   closestResistanceWaiting = false ;
   closestSupportWaiting = false ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MarketObserver::~MarketObserver()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MarketObserver:: zoneReached()
  {


   int currentResistanceZoneIndex = zoneContainer.getHighZonePivot();
   int currentSupportZoneIndex = zoneContainer.getLowZonePivot();

   if(currentResistanceZoneIndex != -1 && currentSupportZoneIndex != -1)
     {


      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= zoneContainer.getZoneByIndex(currentResistanceZoneIndex).getLowerEdge())
        {

         Print("Reached the current resistance zone !");
         return "TYPE_RESISTANCE" ;

        }

      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= zoneContainer.getZoneByIndex(currentSupportZoneIndex).getHigherEdge())
        {
         Print("Reached the current support zone !");
         return "TYPE_SUPPORT" ;

        }
     }


   return "" ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketObserver:: reachedClosestSupportZone()
  {

   int currentSupportZoneIndex = zoneContainer.getLowZonePivot();

   if(currentSupportZoneIndex != -1)
     {
      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= zoneContainer.getZoneByIndex(currentSupportZoneIndex).getHigherEdge())
        {
         return true ;

        }

     }

   return false ;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketObserver:: reachedClosestResistanceZone()
  {

   int currentResistanceZoneIndex = zoneContainer.getHighZonePivot();

   if(currentResistanceZoneIndex != -1)
     {

      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= zoneContainer.getZoneByIndex(currentResistanceZoneIndex).getLowerEdge())
        {
         return true ;

        }
     }


   return false ;

  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketObserver::  bullishCandleClosedInsideClosestResistanceZone(ENUM_TIMEFRAMES tf)
  {

   double previousCandleClose = iClose(_Symbol,tf,1);
   double previousCandleOpen = iOpen(_Symbol,tf,1);

   if(zoneContainer.getHighZonePivot() != -1)   // means if there is a pivot zone
     {

      if((previousCandleClose > previousCandleOpen) && (previousCandleClose > zoneContainer.getZoneByIndex(zoneContainer.getHighZonePivot()).getLowerEdge()) && (previousCandleClose < zoneContainer.getZoneByIndex(zoneContainer.getHighZonePivot()).getHigherEdge()))   // means if previous the candle is bullish and closed inside the resistance zone
        {

         return true ;
        }
     }

   return false ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketObserver:: bearishCandleClosedInsideClosestSupportZone(ENUM_TIMEFRAMES tf)
  {

   double previousCandleClose = iClose(_Symbol,tf,1);
   double previousCandleOpen = iOpen(_Symbol,tf,1);

   if(zoneContainer.getLowZonePivot() != -1)
     {
      if((previousCandleClose < previousCandleOpen) && (previousCandleClose < zoneContainer.getZoneByIndex(zoneContainer.getLowZonePivot()).getHigherEdge()) && (previousCandleClose > zoneContainer.getZoneByIndex(zoneContainer.getLowZonePivot()).getLowerEdge()))   // means if previous the candle is breaish and closed inside the support zone
        {
         return true ;
        }

     }
   return false ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  MarketObserver:: giveMarketReport()
  {


   return " " ;
  }

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  MarketObserver::  candleClosedBelowClosestSupportZone(ENUM_TIMEFRAMES tf)
  {

   double previousCandleClose = iClose(_Symbol,tf,1);
   double previousCandleOpen = iOpen(_Symbol,tf,1);


   if(zoneContainer.getLowZonePivot() != -1)
     {
      if((previousCandleClose < zoneContainer.getZoneByIndex(zoneContainer.getLowZonePivot()).getLowerEdge()))   // means if the previous  candle  closed below the support zone
        {

         return true ;
        }

     }
   return false ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  MarketObserver::  candleClosedAboveClosestResistanceZone(ENUM_TIMEFRAMES tf)
  {

   double previousCandleClose = iClose(_Symbol,tf,1);
   double previousCandleOpen = iOpen(_Symbol,tf,1);

   if(zoneContainer.getHighZonePivot() != -1)   // means if there is a pivot zone
     {

      if((previousCandleClose > zoneContainer.getZoneByIndex(zoneContainer.getHighZonePivot()).getHigherEdge()))    // means if previous the candle  closed above the resistance zone
        {

         return true ;
        }
     }
   return false ;

  }
  

 bool MarketObserver:: candleClosedAboveResistanceByIndex(int _index,ENUM_TIMEFRAMES tf){
 
      double previousCandleClose = iClose(_Symbol,tf,1);
      
       if((previousCandleClose > zoneContainer.getZoneByIndex(_index).getHigherEdge())){
            
            return true ;
       } 
       
       return false ;
 }
//+------------------------------------------------------------------+
