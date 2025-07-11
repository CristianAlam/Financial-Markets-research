//+------------------------------------------------------------------+
//|                                      Algo_Skeleton_Functions.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#define NUM_MAX_ALLOWED_TRADES 4

#include "library_functions.mqh"

#include "NewCandleDetector.mqh"
#include "GraphicalObjectsManager.mqh"
#include  "Zone.mqh"
#include "ZoneContainer.mqh"
#include "LotSizeCalculator.mqh"
#include  "MarketObserverTiger.mqh"

#include "BuyEntryManager.mqh"
#include "SellEntryManager.mqh"
#include "BuyTradeManagerTiger.mqh"
#include "SellTradeManagerTiger.mqh"



input group "Risk Management Related Variables"
input double riskManagementPartial ;
input double firstPartialCloseFactor ;
input double firstPartialProfitInPips;
input bool trail_based_m30 ;
input bool trail_based_h1 ;
input bool trail_based_h4 ;

input group "Entry Time Frame"
input bool ENTRY_BASED_M30_STRUCTURE ;
input bool ENTRY_BASED_H1_STRUCTURE ;

input group "Range Related Variables"
input double rangeDistanceBetweenZones_4H ;
input double rangeDistanceBetweenZones_H1;
input double rangeDistanceBetweenZones_M30 ;
input double breakoutMinDist_H4 ;
input double breakoutMinDist_H1 ;
input double breakoutMinDist_M30 ;
input double cleanRangeUponEntry ;
input double potentialRR;

input group "Zone Related Settings"
input double resistanceExtendAboveCandle;
input double resistanceLowerEdgeExtend ;
input double supportExtendBelowCandle ;
input double supportHigherEdgeExtend;
input int    firstZoneShift ;
input datetime rightEdge ;
input int deleteAllZonesAfter_Weeks ;


input group "Candle Body Variables"
input double WICK_RATIO_REJECTION;
input double SIZE_OF_BREAKER_CANDLE_BODY;


input group "Trade Restrictions"
input bool BUYS_ALLOWED = true ;
input bool SELLS_ALLOWED = true ;


/*
input int wickLengthInMinutes ;
input double preWickPush ;
input double stopOrderFactor ;
input double retracementWickSize ;
input double retracementWickFibMeasure ;
input double minimumStopLossInPips ; */

input group "Trading Sessions"
input bool TRADE_NEW_YORK_ALLOWED = true  ;
input bool TRADE_LONDON_ALLOWED = true ;
input bool TRADE_TOKYO_ALLOWED = true ;

input group "Modes"
input bool MODE_WICKS_INCLUDED ;

input group "HTF Confirmations"
input bool H4_Break_Confirmation ;
input bool H4_Closure_Confirmation ;

// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();

// CONTAINERS INITIALIZATION


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZoneContainer* zoneContainer_W1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_D1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_H4 = new ZoneContainer() ;
ZoneContainer* zoneContainer_H1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_M30 = new ZoneContainer() ;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZoneContainer* zoneContainerSupport_W1 = new ZoneContainer() ;
ZoneContainer* zoneContainerSupport_D1 = new ZoneContainer() ;
ZoneContainer* zoneContainerSupport_H4 = new ZoneContainer() ;
ZoneContainer* zoneContainerSupport_H1 = new ZoneContainer() ;
ZoneContainer* zoneContainerSupport_M30 = new ZoneContainer() ;



// ALGORITHM CLASSES INITIALIZATION
MarketObserverTiger* marketObserverTiger = new MarketObserverTiger();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
NewCandleDetector newCandleDetectorWeekly("PERIOD_W1");
NewCandleDetector newCandleDetectorDaily("PERIOD_D1");
NewCandleDetector newCandleDetector4H("PERIOD_H4");
NewCandleDetector newCandleDetector1H("PERIOD_H1");
NewCandleDetector newCandleDetector30M("PERIOD_M30");
NewCandleDetector newCandleDetectorM15("PERIOD_M15");
NewCandleDetector newCandleDetectorM1("PERIOD_M1");
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

Zone* temporaryRestestSupportZone = new Zone();



// TRADE CLASSES
BuyEntryManager buyEntryManager ;
SellEntryManager sellEntryManager ;


// LotSizeCalculator class

LotSizeCalculator lsCalc ;


// TRADE VARIABLS
bool securedRisk = false ;
ulong activeTradeId ;
BuyTradeManagerTiger* BuyActiveTradesArray[NUM_MAX_ALLOWED_TRADES];
SellTradeManagerTiger* SellActiveTradesArray[NUM_MAX_ALLOWED_TRADES];
int buysCount = 0 ;
int sellsCount = 0 ;
bool waitForBottomWickToForm = false ;
bool bottomWickFormed = false;
bool topWickFormed = false;
int bottomWickValidationState = -2 ;
int topWickValidationState = -2;
bool waitForTopWickToForm = false ;
int wickLengthCounter = 0 ;
double buyStopPrice = -1 ;
double sellStopPrice = -1 ;
bool wickTradeTaken = false ;


// Zone variables
int weekCounter = 0 ;

// HTF Variables
bool last_H4_candle_broke_structure = false ;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double supportExtendBelowCandleActual = supportExtendBelowCandle * Point();
double supportHigherEdgeExtendActual = supportHigherEdgeExtend * Point();
double resistanceExtendAboveCandleActual = resistanceExtendAboveCandle * Point();
double resistanceLowerEdgeExtendActual = resistanceLowerEdgeExtend * Point();


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double stopLossAboveWickByActual = stopLossAboveWickBy * Point() ;
double stopLossUnderWickByActual = stopLossUnderWickBy *  Point() ;


double cleanRangeUponEntryActual = cleanRangeUponEntry * Point() ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double rangeDistanceBetweenZonesActual_H4 = rangeDistanceBetweenZones_4H * Point();
double rangeDistanceBetweenZonesActual_H1 = rangeDistanceBetweenZones_H1 * Point();
double rangeDistanceBetweenZonesActual_M30 = rangeDistanceBetweenZones_M30 * Point();

double maxPipsRiskAmountActual = maxPipsRiskAmount * Point();

double firstPartialProfitInPipsActual = firstPartialProfitInPips * Point();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool detectAndDrawResistanceOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color,ZoneContainer& zoneContainer, double _rangeDistanceBetweenZonesActual, int _timeFrameZoneCounterFactor)
  {


   if(resistancePatternFormed(timeFrame))   // if resistance formed
     {

      //  create a rectangle  with a unique name
      int currentIdCounter = zoneContainer.getZonesIdCounter() + _timeFrameZoneCounterFactor;


      datetime _leftEdge = iTime(_Symbol,timeFrame,2);
      //datetime _rightEdge = D'2023.11.01 00:00:00';
      datetime _rightEdge = rightEdge;
      double resistancePrice = iOpen(_Symbol,timeFrame,1);
      double _higherEdgePrice  = resistancePrice + resistanceExtendAboveCandleActual;
      double _lowerEdgePrice = resistancePrice - resistanceLowerEdgeExtendActual ;
      string _zoneId = IntegerToString(currentIdCounter);



      if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice >= _rangeDistanceBetweenZonesActual))   // check if it has a clean range above
        {

         Zone* newZone = new Zone(_zoneId,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_BREAKOUT") ;
         zoneContainer.addResistanceZoneTiger(newZone);
         zoneContainer.incrementZonesIdCounter();
         objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandleActual,resistancePrice - resistanceLowerEdgeExtendActual,BOS_zone_color);

        }

      else
         if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice < _rangeDistanceBetweenZonesActual))   // if it doesnt have a clean range, just add it as a blue zone
           {

            Zone* newZone = new Zone(_zoneId,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_NORMAL") ;
            zoneContainer.addResistanceZoneTiger(newZone);
            zoneContainer.incrementZonesIdCounter();


           }

         else
            if(zoneContainer.getNumberOfActiveZones() == 0)   // this means this is the first zone to add to the data strucutre
              {
               int result = detectAndDrawFirstResistanceZoneHigherThan(resistancePrice + resistanceExtendAboveCandleActual, timeFrame,firstZoneShift, zoneContainer, timeFrameStr,BOS_zone_color,_rangeDistanceBetweenZonesActual,_timeFrameZoneCounterFactor);
               if(result == 1)
                 {

                  int currentIdCounter = zoneContainer.getZonesIdCounter() + _timeFrameZoneCounterFactor ;
                  string currentIdCounterStr = IntegerToString(currentIdCounter);
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_BREAKOUT") ;
                  zoneContainer.addResistanceZoneTiger(newZone);
                  zoneContainer.incrementZonesIdCounter();
                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandleActual,resistancePrice - resistanceLowerEdgeExtendActual,BOS_zone_color);

                 }
               else
                  if(result == 0)
                    {
                     int currentIdCounter = zoneContainer.getZonesIdCounter() + _timeFrameZoneCounterFactor ;
                     string currentIdCounterStr = IntegerToString(currentIdCounter);

                     Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_NORMAL") ;

                     zoneContainer.addResistanceZoneTiger(newZone);
                     zoneContainer.incrementZonesIdCounter();

                    }
                  else
                     if(result == 2)
                       {
                        int currentIdCounter = zoneContainer.getZonesIdCounter() + _timeFrameZoneCounterFactor ;
                        string currentIdCounterStr = IntegerToString(currentIdCounter);
                        Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_BREAKOUT") ;
                        zoneContainer.addResistanceZoneTiger(newZone);
                        zoneContainer.incrementZonesIdCounter();

                        objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandleActual,resistancePrice - resistanceLowerEdgeExtendActual,BOS_zone_color);

                       }

              }




      if(allResistancesAreNormalType(zoneContainer))   // if all resistances are type normal , then find the first resistance higher than the current highest resistance
        {

         double highestResistanceZonePrice = zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge() ;
         int res = detectAndDrawFirstResistanceZoneHigherThan(highestResistanceZonePrice, timeFrame,firstZoneShift, zoneContainer, timeFrameStr,BOS_zone_color,_rangeDistanceBetweenZonesActual,_timeFrameZoneCounterFactor);



         if(res == 1)
           {
            if((zoneContainer.getNumberOfActiveZones()-2) >= 0)
              {

               zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-2).setType("TYPE_RESISTANCE_BREAKOUT"); // we choose the second cell from the end, because in the last index now sits the new higher zone created by the previous function call.
              }


           }
         else
            if(res == 0)
              {

               if((zoneContainer.getNumberOfActiveZones()-2) >= 0)
                 {
                  deleteZoneGuiOnly(zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-2).getId(),zoneContainer);
                 }

              }

            else
               if(res == 2)
                 {
                  zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).setType("TYPE_RESISTANCE_BREAKOUT");

                 }

        }

      return true ;

     }
   return false ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool detectAndDrawSupportOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color,ZoneContainer& zoneContainer, double _rangeDistanceBetweenZonesAcual, int _timeFrameZoneCounterFactor)
  {


   if(supportPatternFormed(timeFrame))   // if support formed
     {

      //  create a rectangle  with a unique name
      int currentIdCounter = zoneContainer.getSupportZonesIdCounter() + _timeFrameZoneCounterFactor;


      datetime _leftEdge = iTime(_Symbol,timeFrame,2);
      datetime _rightEdge =rightEdge;
      double supportPrice = iOpen(_Symbol,timeFrame,1);
      double _higherEdgePrice  = supportPrice + supportHigherEdgeExtendActual;
      double _lowerEdgePrice = supportPrice - supportExtendBelowCandleActual;
      string _zoneId = IntegerToString(currentIdCounter);



      if((zoneContainer.getNumberOfActiveZones() != 0) && (supportPrice - zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge() >= _rangeDistanceBetweenZonesAcual))   // check if it has a clean range down
        {

         Zone* newZone = new Zone(_zoneId,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_BREAKOUT") ;

         zoneContainer.addSupportZoneTiger(newZone);
         zoneContainer.incrementZonesIdCounterSupport();

         objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice + supportHigherEdgeExtendActual,supportPrice- supportExtendBelowCandleActual,BOS_zone_color);

        }

      else
         if((zoneContainer.getNumberOfActiveZones() != 0) && (supportPrice - zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge() < _rangeDistanceBetweenZonesAcual))   // if it doesnt have a clean range, just add it as a blue zone
           {
            Zone* newZone = new Zone(_zoneId,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_NORMAL") ;
            zoneContainer.addSupportZoneTiger(newZone);
            zoneContainer.incrementZonesIdCounterSupport();

           }

         else
            if(zoneContainer.getNumberOfActiveZones() == 0)   // this means this is the first zone to add to the data strucutre
              {

               // Add the old lower support zone before adding the new support zone.

               int result = detectAndDrawFirstSupportZoneLowerThan(supportPrice - supportExtendBelowCandleActual, timeFrame,firstZoneShift, zoneContainer, timeFrameStr,BOS_zone_color,_rangeDistanceBetweenZonesAcual,_timeFrameZoneCounterFactor);
               if(result == 1)   // means if found a lower zone and the range is clean
                 {
                  int currentIdCounter = zoneContainer.getSupportZonesIdCounter() + _timeFrameZoneCounterFactor;
                  string currentIdCounterStr = IntegerToString(currentIdCounter);
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_BREAKOUT") ;
                  zoneContainer.addSupportZoneTiger(newZone);
                  zoneContainer.incrementZonesIdCounterSupport();

                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice + supportHigherEdgeExtendActual,supportPrice - supportExtendBelowCandleActual,BOS_zone_color);

                 }
               else
                  if(result == 0)   // means found a lower zone but the range is not clean
                    {

                     int currentIdCounter = zoneContainer.getSupportZonesIdCounter() + _timeFrameZoneCounterFactor;
                     string currentIdCounterStr = IntegerToString(currentIdCounter);

                     Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_NORMAL") ;
                     zoneContainer.addSupportZoneTiger(newZone);
                     zoneContainer.incrementZonesIdCounterSupport();

                    }
                  else
                     if(result == 2)   // means didnt find a lower zone
                       {

                        int currentIdCounter = zoneContainer.getSupportZonesIdCounter() + _timeFrameZoneCounterFactor;
                        string currentIdCounterStr = IntegerToString(currentIdCounter);

                        Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_BREAKOUT") ;
                        zoneContainer.addSupportZoneTiger(newZone);
                        zoneContainer.incrementZonesIdCounterSupport();

                        objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice + supportHigherEdgeExtendActual,supportPrice - supportExtendBelowCandleActual,BOS_zone_color);
                       }



              }



      if(allSupportsAreNormalType(zoneContainer))   // if all supports are type normal , then find the first support lower than the current lowest.
        {


         double lowestSupportPrice = zoneContainer.getZoneByIndex(0).getLowerEdge() ;
         int res = detectAndDrawFirstSupportZoneLowerThan(lowestSupportPrice, timeFrame,firstZoneShift, zoneContainer, timeFrameStr,BOS_zone_color,_rangeDistanceBetweenZonesAcual,_timeFrameZoneCounterFactor) ;

         if(res == 1)   // if we found lower support than the current lower, and the range is valid, then keep both
           {

            zoneContainer.getZoneByIndex(1).setType("TYPE_SUPPORT_BREAKOUT"); // we choose index 1, because in index 0 now sits the new lower zone created by the previous function call.
           }
         else
            if(res == 0)   // if we found a lower support than the current lowest but the range is not valid, then keep only the lower one
              {

               if(zoneContainer.getNumberOfActiveZones() > 1)
                 {
                  zoneContainer.getZoneByIndex(1).setType("TYPE_SUPPORT_NORMAL");
                  deleteZoneGuiOnly(zoneContainer.getZoneByIndex(1).getId(),zoneContainer);
                 }

              }

            else
               if(res == 0)
                 {
                  zoneContainer.getZoneByIndex(0).setType("TYPE_SUPPORT_NORMAL");
                 }

        }


      return true ;

     }
   return false ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int detectAndDrawFirstResistanceZoneHigherThan(double currentHigherResistancePrice, ENUM_TIMEFRAMES timeFrame,int _firstZoneShift,ZoneContainer& zoneContainer,string timeFrameStr, long BOS_zone_color,double _rangeDistanceBetweenZonesAcual, int _timeFrameZoneCounterFactor)
  {

   for(int i=3 ; i< _firstZoneShift; i++)
     {
      if(resistancePatternFormed(timeFrame,i))   // if old resistance found
        {

         //  create a rectangle  with a unique name
         int currentIdCounter = zoneContainer.getZonesIdCounter() + _timeFrameZoneCounterFactor ;
         string currentIdCounterStr = IntegerToString(currentIdCounter);
         datetime _leftEdge = iTime(_Symbol,timeFrame,i+2);
         datetime _rightEdge = rightEdge;
         double resistancePrice = iOpen(_Symbol,timeFrame,i+1);
         double _higherEdgePrice = resistancePrice + resistanceExtendAboveCandleActual;
         double _lowerEdgePrice = resistancePrice - resistanceLowerEdgeExtendActual ;

         if((resistancePrice > currentHigherResistancePrice) && ((resistancePrice - currentHigherResistancePrice) > _rangeDistanceBetweenZonesAcual))   // this means the range is valid
           {

            if(MODE_WICKS_INCLUDED)
              {
               Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_BREAKOUT") ;
               zoneContainer.addHistoryResistanceZoneOnTop(newZone);
               zoneContainer.incrementZonesIdCounter();
               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);

              }
            else
              {
               Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_NORMAL") ;
               zoneContainer.addHistoryResistanceZoneOnTop(newZone);
               zoneContainer.incrementZonesIdCounter();
               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);
              }


            return 1 ; // range is valid so return 1
           }
         else
            if((resistancePrice > currentHigherResistancePrice) && !((resistancePrice - currentHigherResistancePrice) > _rangeDistanceBetweenZonesAcual))   // the range is not valid, this means draw only the old one
              {

               if(MODE_WICKS_INCLUDED)
                 {
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_BREAKOUT") ;
                  zoneContainer.addHistoryResistanceZoneOnTop(newZone);
                  zoneContainer.incrementZonesIdCounter();
                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);

                 }
               else
                 {
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_RESISTANCE_NORMAL") ;
                  zoneContainer.addHistoryResistanceZoneOnTop(newZone);
                  zoneContainer.incrementZonesIdCounter();
                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);
                 }




               return 0 ; // range is not valid , so return 0

              }
        }
     }
   return 2; // this is the case that we didnt find a zone above the current highest zone, which means the current highest zone now, will be breakout zone

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int detectAndDrawFirstSupportZoneLowerThan(double currentLowerSupportPrice,  ENUM_TIMEFRAMES timeFrame,int _firstZoneShift,ZoneContainer& zoneContainer,string timeFrameStr, long BOS_zone_color, double _rangeDistanceBetweenZonesAcual, int _timeFrameZoneCounterFactor)
  {

   int result = 2 ;
   for(int i=3 ; i< _firstZoneShift; i++)
     {
      if(supportPatternFormed(timeFrame,i))   // if old support found
        {
         //  create a rectangle  with a unique name
         int currentIdCounter = zoneContainer.getSupportZonesIdCounter() + _timeFrameZoneCounterFactor ;
         string currentIdCounterStr = IntegerToString(currentIdCounter);
         datetime _leftEdge = iTime(_Symbol,timeFrame,i+2);
         datetime _rightEdge = rightEdge;
         double supportPrice = iOpen(_Symbol,timeFrame,i+1);
         double _higherEdgePrice = supportPrice + supportHigherEdgeExtendActual;
         double _lowerEdgePrice = supportPrice - supportExtendBelowCandleActual ;

         if((supportPrice < currentLowerSupportPrice) && ((currentLowerSupportPrice - supportPrice) > _rangeDistanceBetweenZonesAcual))   // this means the range is valid
           {

            if(MODE_WICKS_INCLUDED)
              {
               Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_BREAKOUT") ;
               zoneContainer.addHistorySupportZoneAtBottom(newZone);
               zoneContainer.incrementZonesIdCounterSupport();
               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);


              }
            else
              {
               Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_NORMAL") ;
               zoneContainer.addHistorySupportZoneAtBottom(newZone);
               zoneContainer.incrementZonesIdCounterSupport();
               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);

              }

            return 1 ;
           }
         else
            if((supportPrice < currentLowerSupportPrice)  && !((currentLowerSupportPrice - supportPrice) > _rangeDistanceBetweenZonesAcual))   // the range is not valid, this means draw only the old one
              {

               if(MODE_WICKS_INCLUDED)
                 {
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_BREAKOUT") ;
                  zoneContainer.addHistorySupportZoneAtBottom(newZone);
                  zoneContainer.incrementZonesIdCounterSupport();
                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);

                 }
               else
                 {
                  Zone* newZone = new Zone(currentIdCounterStr,_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,timeFrameStr,"TYPE_SUPPORT_NORMAL") ;
                  zoneContainer.addHistorySupportZoneAtBottom(newZone);
                  zoneContainer.incrementZonesIdCounterSupport();
                  objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,newZone.getHigherEdge(),newZone.getLowerEdge(),BOS_zone_color);
                 }


               return 0 ;

              }
        }
     }
   return 2 ;  // this is the case that we didnt find a zone below the current lowest zone, which means the lowest zone now, will be breakout zone

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allSupportsAreNormalType(ZoneContainer& zoneContainer)
  {
   for(int i=0 ; i< zoneContainer.getNumberOfActiveZones() ; i++)
     {
      if(zoneContainer.getZoneByIndex(i).getType() == "TYPE_SUPPORT_BREAKOUT")
        {
         return false ;
        }


     }
   return true ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allResistancesAreNormalType(ZoneContainer& zoneContainer)
  {

   for(int i=0 ; i< zoneContainer.getNumberOfActiveZones() ; i++)
     {
      if(zoneContainer.getZoneByIndex(i).getType() == "TYPE_RESISTANCE_BREAKOUT")
        {
         return false ;
        }


     }
   return true ;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  updateNormalZonesSupport(ZoneContainer& zoneContainer_Support,ENUM_TIMEFRAMES timeFrame,string timeFrameStr, long _color, double _rangeDistanceBetweenZonesAcual, int _timeFrameZoneCounterFactor)
  {

   if(allSupportsAreNormalType(zoneContainer_Support))   // if all supports are type normal , then find the first support lower than the current lowest.
     {


      double lowestSupportPrice = zoneContainer_Support.getZoneByIndex(0).getLowerEdge() ;
      int res = detectAndDrawFirstSupportZoneLowerThan(lowestSupportPrice, timeFrame,firstZoneShift, zoneContainer_Support, timeFrameStr,_color,_rangeDistanceBetweenZonesAcual,_timeFrameZoneCounterFactor) ;

      if(res == 1)   // if we found lower support than the current lower, and the range is valid, then keep both
        {

         zoneContainer_Support.getZoneByIndex(1).setType("TYPE_SUPPORT_BREAKOUT"); // we choose index 1, because in index 0 now sits the new lower zone created by the previous function call.
        }
      else
         if(res == 0)   // if we found a lower support than the current lowest but the range is not valid, then keep only the lower one
           {

            if(zoneContainer_Support.getNumberOfActiveZones() > 1)
              {
               zoneContainer_Support.getZoneByIndex(1).setType("TYPE_SUPPORT_NORMAL");
               deleteZoneGuiOnly(zoneContainer_Support.getZoneByIndex(1).getId(),zoneContainer_Support);
              }

           }
         else
            if(res == 2)
              {
               zoneContainer_Support.getZoneByIndex(0).setType("TYPE_SUPPORT_BREAKOUT");

              }

     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateNormalZonesResistance(ZoneContainer& zoneContainer_Resistance,ENUM_TIMEFRAMES timeFrame,string timeFrameStr, long _color, double _rangeDistanceBetweenZonesAcual, int _timeFrameZoneCounterFactor)
  {
   if(allResistancesAreNormalType(zoneContainer_Resistance))   // if all resistances are type normal , then find the first resistance higher than the current highest resistance
     {

      double highestResistanceZonePrice = zoneContainer_Resistance.getZoneByIndex(zoneContainer_Resistance.getNumberOfActiveZones()-1).getHigherEdge() ;
      int res = detectAndDrawFirstResistanceZoneHigherThan(highestResistanceZonePrice, timeFrame,firstZoneShift, zoneContainer_Resistance, timeFrameStr,_color,_rangeDistanceBetweenZonesAcual,_timeFrameZoneCounterFactor);


      if(res == 1)
        {
         if((zoneContainer_Resistance.getNumberOfActiveZones()-2) >= 0)
           {

            zoneContainer_Resistance.getZoneByIndex(zoneContainer_Resistance.getNumberOfActiveZones()-2).setType("TYPE_RESISTANCE_BREAKOUT"); // we choose the second cell from the end, because in the last index now sits the new higher zone created by the previous function call.
           }


        }
      else
         if(res == 0)
           {

            if((zoneContainer_Resistance.getNumberOfActiveZones()-2) >= 0)
              {
               deleteZoneGuiOnly(zoneContainer_Resistance.getZoneByIndex(zoneContainer_Resistance.getNumberOfActiveZones()-2).getId(),zoneContainer_Resistance);
              }

           }

         else
            if(res == 2)
              {
               zoneContainer_Resistance.getZoneByIndex(zoneContainer_Resistance.getNumberOfActiveZones()-1).setType("TYPE_RESISTANCE_BREAKOUT");

              }

     }

  }





//+------------------------------------------------------------------+
void deleteZoneWithGUI(string _id, ZoneContainer& zoneContainer)
  {


   zoneContainer.deleteZone(_id);

   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }


   Print("Deleted the zone with gui!");

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteZoneGuiOnly(string _id,ZoneContainer& zoneContainer)
  {


   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }

   Print("Deleted the zone gui!");

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool updateBreakAboveStructureAndDelete(ZoneContainer& zoneContainer, ENUM_TIMEFRAMES timeFrame, string timeFrameStr, double& brokenResistanceLowerEdge, string& type)
  {
   bool finishedDeleting = false ;

   if(zoneContainer.getNumberOfActiveZones() != 0)   // if there are zones found
     {
      if(marketObserverTiger.candleClosedAboveResistanceByIndex(0,timeFrame,zoneContainer))   // check if candle closed above the zone
        {


         datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
         datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';


         while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0)   // this while is used in the case of a candle closing above more than 1 zone at once
           {


            if(zoneContainer.getNumberOfActiveZones() != 0 && marketObserverTiger.candleClosedAboveResistanceByIndex(0,timeFrame,zoneContainer))
              {
               zoneContainer.getZoneByIndex(0).getHigherEdge();
               temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(0).getHigherEdge());
               temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(0).getLowerEdge());
               temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
               temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
               temporaryRestestSupportZone.setId("999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
               temporaryRestestSupportZone.setTimeFrame(timeFrameStr);

               type = zoneContainer.getZoneByIndex(0).getType();
               temporaryRestestSupportZone.setType("TYPE_SUPPORT_TEMPORARY");

               brokenResistanceLowerEdge = zoneContainer.getZoneByIndex(0).getLowerEdge(); // save the lower edge of the broken zone, in order to return it in the parameter

               deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId()),zoneContainer); // delete the zone with the GUI
              }
            else
              {
               finishedDeleting = true ;
              }


           }


         return true ;

        }


     }
   return false ;

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool updateBreakBelowStructureAndDelete(ZoneContainer& zoneContainer, ENUM_TIMEFRAMES timeFrame, string timeFrameStr, double& brokenSupportHigherEdge, string& type)
  {
   bool finishedDeleting = false ;

   if(zoneContainer.getNumberOfActiveZones() != 0)   // if there are zones found
     {

      if(marketObserverTiger.candleClosedBelowSupportByIndex(zoneContainer.getNumberOfActiveZones() -1,timeFrame,zoneContainer))   // check if candle closed below the zone
        {

         datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
         datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';


         while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0)   // this while is used in the case of a candle closing above more than 1 zone at once
           {


            if(zoneContainer.getNumberOfActiveZones() != 0 && marketObserverTiger.candleClosedBelowSupportByIndex(zoneContainer.getNumberOfActiveZones()-1,timeFrame,zoneContainer))
              {
               zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge();
               temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge());
               temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getLowerEdge());
               temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
               temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
               temporaryRestestSupportZone.setId("9999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
               temporaryRestestSupportZone.setTimeFrame(timeFrameStr);

               type = zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getType();
               temporaryRestestSupportZone.setType("TYPE_RESISTANCE_TEMPORARY");

               brokenSupportHigherEdge = zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge();

               deleteZoneWithGUI((zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getId()),zoneContainer); // delete the zone with the GUI
              }
            else
              {
               finishedDeleting = true ;
              }


           }


         return true ;


        }


     }

   return false ;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double findClosestResistancePrice(ZoneContainer& zoneContainer)
  {

   double closestResistancePrice = -1;
   if(zoneContainer.getNumberOfActiveZones() != 0)
     {

      closestResistancePrice = zoneContainer.getZoneByIndex(0).getLowerEdge();
     }

   return closestResistancePrice ;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double findClosestSupportPrice(ZoneContainer& zoneContainer)
  {

   double closestSupportPrice = -1 ;
   if(zoneContainer.getNumberOfActiveZones() != 0)
     {

      closestSupportPrice = zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getLowerEdge();
     }

   return closestSupportPrice ;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool buyStopLossUnderZone(double resistanceZoneLowerEdge, double stopLossValue)
  {

   if(stopLossValue < resistanceZoneLowerEdge)
     {
      return true ;
     }
   else
     {
      Comment("stop loss is not under the zone im not taking a buy");
      return false ;

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sellStopLossAboveZone(double supportZoneHigherEdge, double stopLossValue)
  {

   if(stopLossValue > supportZoneHigherEdge)
     {
      return true ;
     }
   else
     {
      Comment("stop loss is not above the zone, so im not taking a sell");
      return false ;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageRiskIfNeeded()
  {

   if(PositionsTotal()!= 0)   // There is an active trade
     {
      manageRiskOnBuysIfNeeded();
      manageRiskOnSellsIfNeeded();

     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageRiskOnBuysIfNeeded()
  {
   if(candleClosedBearish(PERIOD_M15,1) && !bearishCandleIsWeak(PERIOD_M15,1, WICK_RATIO_REJECTION))
     {

      for(int i = 0 ; i < NUM_MAX_ALLOWED_TRADES ; i++)
        {
         if((BuyActiveTradesArray[i] != NULL) && !(BuyActiveTradesArray[i].riskAlreadyManaged()))   // if the trade still hasnt managead risk , then do it now.
           {
            closePartialFromSpecificPosition(BuyActiveTradesArray[i].getTradeId(),riskManagementPartial);
            BuyActiveTradesArray[i].manageRisk();
           }
        }

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageRiskOnSellsIfNeeded()
  {

   if(candleClosedBullish(PERIOD_M15,1) && !bullishCandleIsWeak(PERIOD_M15,1, WICK_RATIO_REJECTION))
     {
      for(int i = 0 ; i < NUM_MAX_ALLOWED_TRADES ; i++)
        {
         if((SellActiveTradesArray[i] != NULL) && !(SellActiveTradesArray[i].riskAlreadyManaged()))   // if the trade still hasnt managead risk , then do it now.
           {
            closePartialFromSpecificPosition(SellActiveTradesArray[i].getTradeId(),riskManagementPartial);
            SellActiveTradesArray[i].manageRisk();
           }
        }

     }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void secureProfitIfNeeded()
  {

   if(PositionsTotal() != 0)   // if there are active trades
     {

      secureProfitOnBuysIfNeeded();
      secureProfitOnSellsIfNeeded();

     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void secureProfitOnBuysIfNeeded()
  {

   for(int i=0 ; i< NUM_MAX_ALLOWED_TRADES ; i++)
     {

      if((BuyActiveTradesArray[i] != NULL) && !(BuyActiveTradesArray[i].firstPartialIsSecured()))   // if first partial is not yet secured for the current position
        {

         double currentProfit = positionProfitInPips(BuyActiveTradesArray[i].getTradeId());
         if(currentProfit >= firstPartialProfitInPipsActual)
           {
            closePartialFromSpecificPosition(BuyActiveTradesArray[i].getTradeId(),firstPartialCloseFactor) ;
            BuyActiveTradesArray[i].secureFirstPartial();
           }

        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void secureProfitOnSellsIfNeeded()
  {

   for(int i=0 ; i< NUM_MAX_ALLOWED_TRADES ; i++)
     {

      if((SellActiveTradesArray[i] != NULL) && !(SellActiveTradesArray[i].firstPartialIsSecured()))   // if first partial is not yet secured for the current position
        {

         double currentProfit = positionProfitInPips(SellActiveTradesArray[i].getTradeId());
         if(currentProfit >= firstPartialProfitInPipsActual)
           {
            closePartialFromSpecificPosition(SellActiveTradesArray[i].getTradeId(),firstPartialCloseFactor) ;
            SellActiveTradesArray[i].secureFirstPartial();
           }
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findAvailableSpotInBuyManagerArr()   // returns the index , or -1 if all are full
  {

   for(int i=0 ; i < NUM_MAX_ALLOWED_TRADES ; i++)
     {
      if(BuyActiveTradesArray[i] == NULL)
        {
         return i;

        }

     }
   return -1 ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findAvailableSpotInSellManagerArr()   // returns the index , or -1 if all are full
  {

   for(int i=0 ; i<NUM_MAX_ALLOWED_TRADES ; i++)
     {
      if(SellActiveTradesArray[i] == NULL)
        {

         return i ;
        }
     }
   return -1;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cleanBuyTradesArr()
  {

   for(int i=0 ; i< NUM_MAX_ALLOWED_TRADES ; i++)   // iterate over the trade managers array
     {
      //Print("arrived here iteration " + i);
      bool currentPositionFound = false ;
      for(int j = 0 ; j < PositionsTotal() ; j++)   // iterate over all the active positions
        {
         //Print("arrived here iteration " + j);
         ulong posTicket = PositionGetTicket(j);
         if((BuyActiveTradesArray[i] != NULL) && (BuyActiveTradesArray[i].getTradeId() == posTicket))   // found the current trade , in the active trades.
           {
            currentPositionFound = true ;
           }

        }

      if(!currentPositionFound)
        {

         delete BuyActiveTradesArray[i] ; // free the allocated memory for the object
         BuyActiveTradesArray[i] = NULL;
        }

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cleanSellTradesArr()
  {

   for(int i=0 ; i< NUM_MAX_ALLOWED_TRADES ; i++)   // iterate over the trade managers array
     {
      bool currentPositionFound = false ;
      for(int j = 0 ; j< PositionsTotal() ; j++)   // iterate over all the active positions
        {
         ulong posTicket = PositionGetTicket(j);
         if((SellActiveTradesArray[i] != NULL) && (SellActiveTradesArray[i].getTradeId() == posTicket))   // found the current trade , in the active trades.
           {
            currentPositionFound = true ;
           }

        }

      if(!currentPositionFound)
        {

         delete SellActiveTradesArray[i] ; // free the allocated memory for the object
         SellActiveTradesArray[i] = NULL;
        }

     }


  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trailAllOpenPositionsIfNeeded(ENUM_TIMEFRAMES _timeFrame)
  {

   for(int i=0 ; i< NUM_MAX_ALLOWED_TRADES ; i++)   // CHECK TRAIL FOR BUYS
     {
      if((BuyActiveTradesArray[i] != NULL))
        {
         double newStopLoss = iLow(_Symbol,_timeFrame,1);
         newStopLoss = newStopLoss - stopLossUnderWickByActual ;
         if(newStopLoss > positionStopLoss(BuyActiveTradesArray[i].getTradeId()))   // if new stop loss is higher than the current position's stop loss
           {
            if(SymbolInfoDouble(_Symbol,SYMBOL_BID) <= newStopLoss){ // close the trade because the bid is lower than the stop loss (and the modify will fail))
               tradeLong.PositionClose(BuyActiveTradesArray[i].getTradeId());
            }
            positionTrailStopLoss(BuyActiveTradesArray[i].getTradeId(),newStopLoss,0);
           }
        }



      if((SellActiveTradesArray[i] != NULL))   // CHECK TRAIL FOR SELLS
        {
         double newStopLoss = iHigh(_Symbol,_timeFrame,1);
         newStopLoss = newStopLoss + stopLossAboveWickByActual ;
         if(newStopLoss < positionStopLoss(SellActiveTradesArray[i].getTradeId()))   // if new stop loss is lower than the current position's stop loss
           {
            if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) >= newStopLoss){ // close the trade because the ask is higher than the stop loss (and the modify will fail))
               tradeShort.PositionClose(SellActiveTradesArray[i].getTradeId());
            }
            positionTrailStopLoss(SellActiveTradesArray[i].getTradeId(),newStopLoss,0);
           }
        }


     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/*int bottomWickIsValid()
  {
   double previousCandleBodySize = iClose(_Symbol,PERIOD_M30,1) - iOpen(_Symbol,PERIOD_M30,1) ;
   double currentWickSize =  iOpen(_Symbol,PERIOD_M30,0) - iLow(_Symbol,PERIOD_M30,0);
   if((iHigh(_Symbol,PERIOD_M30,0) - iOpen(_Symbol,PERIOD_M30,0)) > preWickPush)   // this case we would not take the trade at all, because pushed too much in the beggining of the candle
     {
      return 0;
     }
   else
      if(currentWickSize < previousCandleBodySize * retracementWickFibMeasure)  // this case we would wait until the wick size becomes valid
        {

         return 1 ;
        }


      else
         if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) > iOpen(_Symbol,PERIOD_M30,0))
           {

            return -1 ;
           }

   return 2 ; // this case means the wick that was formed is healthy and we only need the price to reach the candle open in order to check the trade and execute
  } */





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
int handleBottomWickValidation()
  {

   int result = bottomWickIsValid() ;
   if(result == 0)  // not considering the trade
     {
      Comment("not considering the trade");
     }
   else
      if(result == 1)  // the wick was formed however its not big enough, so we need to wait more (call bottomWickIsValid() again))
        {
         Comment("bottom wick is too small, lets wait to see if it becomes valid");
        }
      else
         if(result == 2)  // the wick was formed and it satisfies the conditions, so now just wait for the price to reach the candle open
           {

            Comment("bottom wick is valid, im waiting the price to reach the candle open in order to consider executing");
           }

         else
            if(result == -1)
              {

               Comment("Price has already moved !");
              }


   return result ;
  } */

/*void updateBottomWickState(int bottomWickValidationState)
  {
   datetime currTime = TimeCurrent();
   switch(bottomWickValidationState)
     {
      case -1 : // not considering the trade because price already moved
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": not considering the trade because price already moved");
         waitForBottomWickToForm = false ;
         wickLengthCounter = 0;
         break;

      case 0 : // not considering the trade because price pushed too much upwards before the wick formed
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": not considering the trade because price pushed too much upwards before the wick formed");
         waitForBottomWickToForm = false ;
         wickLengthCounter = 0;
         break;
      case 1: // bottom wick has formed but its too small, lets wait for it to become valid
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": bottom wick has formed but its too small, lets wait for it to become valid");

         break;

      case 2 : // bottom wick has formed and its healthy, lets wait for price to reach candle entry, in order to check sl
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": bottom wick has formed and its healthy, lets wait for price to reach candle entry, in order to check sl");
         waitForBottomWickToForm = false ;
         wickLengthCounter = 0;
         bottomWickFormed = true ;
         buyStopPrice = iHigh(_Symbol,PERIOD_CURRENT,0) + stopOrderFactor ;
         break;
     }
  } */


/*int topWickIsValid()
  {
   double previousCandleBodySize = iOpen(_Symbol,PERIOD_M30,1) - iClose(_Symbol,PERIOD_M30,1);
   double currentWickSize = iHigh(_Symbol,PERIOD_M30,0) - iOpen(_Symbol,PERIOD_M30,0);
   if((iOpen(_Symbol,PERIOD_M30,0) - iLow(_Symbol,PERIOD_M30,0)) > preWickPush)   // this case we would not take the trade at all
     {
      return 0;
     }
   else
      if(currentWickSize < retracementWickFibMeasure * previousCandleBodySize)   // this case we would wait until the wick size becomes valid
        {

         return 1 ;
        }
      else
         if(SymbolInfoDouble(_Symbol,SYMBOL_BID) < iOpen(_Symbol,PERIOD_M30,0))
           {

            return -1 ;
           }
   return 2 ; // this case means the wick that was formed is healthy and we only need the price to reach the candle open in order to check the trade and execute

  } */
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* int handleTopWickValidation()
  {
   int result = topWickIsValid() ;
   if(result == 0)  // not considering the trade
     {
      Comment("not considering the trade");
     }
   else
      if(result == 1)  // the wick was formed however its not big enough, so we need to wait more
        {
         Comment("top wick is too small, lets wait to see if it becomes valid");
        }
      else
         if(result == 2)  // the wick was formed and it satisfies the conditions, so now just wait for the price to reach the candle open
           {

            Comment("top wick is valid, im waiting the price to reach the candle open in order to consider executing");
           }

         else
            if(result == -1)
              {
               Comment("Price has already moved !");
              }


   return result ;

  } */
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* void updateTopWickState(int topWickValidationState)
  {
   datetime currTime = TimeCurrent();
   switch(topWickValidationState)
     {
      case -1 : // not considering the trade because price already moved
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": not considering the trade because price already moved");
         waitForTopWickToForm = false ;
         wickLengthCounter = 0;
         break;

      case 0 : // not considering the trade because price pushed too much downwards before the wick formed
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": not considering the trade because price pushed too much downwards before the wick formed");
         waitForTopWickToForm = false ;
         wickLengthCounter = 0;
         break;
      case 1: // top wick has formed but its too small, lets wait for it to become valid
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": top wick has formed but its too small, lets wait for it to become valid");

         break;

      case 2 : // top wick has formed and its healthy, lets wait for price to reach candle low, in order to check sl
         Comment(TimeToString(currTime,TIME_MINUTES) +  ": top wick has formed and its healthy, lets wait for price to reach candle low, in order to check sl");
         waitForTopWickToForm = false ;
         wickLengthCounter = 0;
         topWickFormed = true ;
         sellStopPrice = iLow(_Symbol,PERIOD_CURRENT,0) - stopOrderFactor ;
         break;
     }


  } */

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleBullishBreakouts(ZoneContainer& _zoneContainer, ENUM_TIMEFRAMES _timeFrame,string _timeFrameStr)
  {
   double brokenResistanceLowerPrice = -1 ;
   string brokenZoneTypeResistance = "" ;
   if(updateBreakAboveStructureAndDelete(_zoneContainer,_timeFrame,_timeFrameStr,brokenResistanceLowerPrice,brokenZoneTypeResistance))
     {
      if(_timeFrameStr == "PERIOD_H4")
        {
         last_H4_candle_broke_structure = true ;
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleBearishBreakouts(ZoneContainer& _zoneContainer, ENUM_TIMEFRAMES _timeFrame,string _timeFrameStr)
  {
   double brokenSupportHigherPrice = -1;
   string brokenZoneTypeSupport = "" ;

   if(updateBreakBelowStructureAndDelete(_zoneContainer,_timeFrame,_timeFrameStr,brokenSupportHigherPrice,brokenZoneTypeSupport))
     {
      if(_timeFrameStr == "PERIOD_H4")
        {
         last_H4_candle_broke_structure = true ;
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleBuys(ZoneContainer& _zoneContainer, ENUM_TIMEFRAMES _timeFrame,string _timeFrameStr, double _cleanRangeUponEntryActual)
  {

   double brokenResistanceLowerPrice = -1 ;
   string brokenZoneTypeResistance = "" ;

   if(updateBreakAboveStructureAndDelete(_zoneContainer,_timeFrame,_timeFrameStr,brokenResistanceLowerPrice,brokenZoneTypeResistance)
      && buyBreakerCandleIsValid(_timeFrame, SIZE_OF_BREAKER_CANDLE_BODY)
      && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED) || (sessionIsTokyo() && TRADE_TOKYO_ALLOWED)) && BUYS_ALLOWED)   // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
     {


      if(brokenZoneTypeResistance == "TYPE_RESISTANCE_BREAKOUT")
        {

         

         
         int indexToNewTrade ;
         if((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1)    // find a spot in the trades array, and save the result
           {

            if(H4TimeFrameConfirmedBuys() && validateCleanRangeBuys_H4() && validateCleanRangeBuys_H1() && validateCleanRangeBuys_M30())
              {
              
               double stopLossPrice ;
               if((stopLossPrice = findAndValidateStopLossBuys(_timeFrameStr,maxPipsRiskAmountActual))!= -1)
                 {
                  
                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
                  activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToEnter,stopLossPrice) ;

                  BuyTradeManagerTiger* tempTigerManager= new BuyTradeManagerTiger(activeTradeId); // create an object of type buyTradeManagerTiger
                  BuyActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                  buysCount++;

                  Comment("Took a buy. stop loss: based on "+ _timeFrameStr + " Active trade id: " + activeTradeId);


                 }


              }

           }
         else
           {

            Comment("I cant take a buy because the trades array is full");
           }


        }

      else
        {
         datetime currTime = TimeCurrent();
         string timeInStr = TimeToString(currTime,TIME_MINUTES);
         Comment(timeInStr+ ": Cant take a buy, because the broken resistance zone is not a break out zone !");

        }
     }


  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double findAndValidateStopLossBuys(string _timeFrameStr,double _maxPipsRiskAmountActual)
  {

   if(_timeFrameStr == "PERIOD_H4")
     {

      double stopLossBased_H4 = iLow(_Symbol,PERIOD_H4,1);
      stopLossBased_H4 = stopLossBased_H4 - stopLossUnderWickByActual ;
      if(stopLossIsValidBuys(stopLossBased_H4,_maxPipsRiskAmountActual))
        {
         return stopLossBased_H4 ;
        }
      Comment("Cant take a buy, because stop loss is not valid");
      return -1 ;

     }
   else
      if(_timeFrameStr == "PERIOD_H1")
        {
         double stopLossBased_H1 = iLow(_Symbol,PERIOD_H1,1);
         stopLossBased_H1 = stopLossBased_H1 - stopLossUnderWickByActual ;

         double stopLossBased_M30 = iLow(_Symbol,PERIOD_M30,1);
         stopLossBased_M30 = stopLossBased_M30 - stopLossUnderWickByActual ;

         if(stopLossIsValidBuys(stopLossBased_H1,_maxPipsRiskAmountActual))
           {
            return stopLossBased_H1 ;
           }
         else
            if(stopLossIsValidBuys(stopLossBased_M30,_maxPipsRiskAmountActual))
              {
               return stopLossBased_M30 ;
              }
         Comment("Cant take a buy, because stop loss is not valid");
         return -1 ;
        }
      else
         if(_timeFrameStr == "PERIOD_M30")
           {

            double stopLossBased_M30 = iLow(_Symbol,PERIOD_M30,1);
            stopLossBased_M30 = stopLossBased_M30 - stopLossUnderWickByActual ;

            double stopLossBased_M15 = iLow(_Symbol,PERIOD_M15,1);
            stopLossBased_M15 = stopLossBased_M15 - stopLossUnderWickByActual ;

            if(stopLossIsValidBuys(stopLossBased_M30,_maxPipsRiskAmountActual))
              {
               return stopLossBased_M30 ;
              }
            else
               if(stopLossIsValidBuys(stopLossBased_M15,_maxPipsRiskAmountActual))
                 {
                  return stopLossBased_M15 ;
                 }
            Comment("Cant take a buy, because stop loss is not valid");
            return -1 ;
           }
   Comment("Cant take a buy, because stop loss is not valid");
   return -1 ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleSells(ZoneContainer& _zoneContainer, ENUM_TIMEFRAMES _timeFrame,string _timeFrameStr, double _cleanRangeUponEntryActual)
  {

   double brokenSupportHigherPrice = -1;
   string brokenZoneTypeSupport = "" ;

   if(updateBreakBelowStructureAndDelete(_zoneContainer,_timeFrame,_timeFrameStr,brokenSupportHigherPrice,brokenZoneTypeSupport)
      && sellBreakerCandleIsValid(_timeFrame, SIZE_OF_BREAKER_CANDLE_BODY)
      && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED) || (sessionIsTokyo() && TRADE_TOKYO_ALLOWED)) && SELLS_ALLOWED)   // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
     {


      if(brokenZoneTypeSupport == "TYPE_SUPPORT_BREAKOUT")
        {

         

         int indexToNewTrade ;
         if((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1)   // find a spot in the trades array, and save the result
           {

            if(H4TimeFrameConfirmedSells() && validateCleanRangesSells_H4() && validateCleanRangeSells_H1() && validateCleanRangeSells_M30())
              {
               double stopLossPrice ;
               if((stopLossPrice = findAndValidateStopLossSells(_timeFrameStr,maxPipsRiskAmountActual))!= -1)
                 {
                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
                  activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToEnter,stopLossPrice) ;
                  SellTradeManagerTiger* tempTigerManager= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                  SellActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                  sellsCount++;
                  Comment("Took a sell. stop loss: based on  "+ _timeFrameStr + " Active trade id: " + activeTradeId);

                 }


              }

           }
         else
           {

            Comment("I cant take a sell because the trades array is full");
           }



        }

      else
        {
         datetime currTime = TimeCurrent();
         string timeInStr = TimeToString(currTime,TIME_MINUTES);
         Comment(timeInStr+ ": Cant take a sell, because the broken resistance zone is not a break out zone !");

        }

     }


  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double findAndValidateStopLossSells(string _timeFrameStr,double _maxPipsRiskAmountActual)
  {

   if(_timeFrameStr == "PERIOD_H4")
     {

      double stopLossBased_H4 = iHigh(_Symbol,PERIOD_H4,1);
      stopLossBased_H4 = stopLossBased_H4 + stopLossUnderWickByActual ;
      if(stopLossIsValidSells(stopLossBased_H4,_maxPipsRiskAmountActual))
        {
         return stopLossBased_H4 ;
        }
      Comment("Cant take a sell because stop loss is not valid !");
      return -1 ;

     }
   else
      if(_timeFrameStr == "PERIOD_H1")
        {
         double stopLossBased_H1 = iHigh(_Symbol,PERIOD_H1,1);
         stopLossBased_H1 = stopLossBased_H1 + stopLossAboveWickByActual ;

         double stopLossBased_M30 = iHigh(_Symbol,PERIOD_M30,1);
         stopLossBased_M30 = stopLossBased_M30 + stopLossAboveWickByActual ;

         if(stopLossIsValidSells(stopLossBased_H1,_maxPipsRiskAmountActual))
           {
            return stopLossBased_H1 ;
           }
         else
            if(stopLossIsValidSells(stopLossBased_M30,_maxPipsRiskAmountActual))
              {
               return stopLossBased_M30 ;
              }
         Comment("Cant take a sell because stop loss is not valid !");
         return -1 ;
        }
      else
         if(_timeFrameStr == "PERIOD_M30")
           {

            double stopLossBased_M30 = iHigh(_Symbol,PERIOD_M30,1);
            stopLossBased_M30 = stopLossBased_M30 + stopLossUnderWickByActual ;

            double stopLossBased_M15 = iHigh(_Symbol,PERIOD_M15,1);
            stopLossBased_M15 = stopLossBased_M15 + stopLossUnderWickByActual ;

            if(stopLossIsValidSells(stopLossBased_M30,_maxPipsRiskAmountActual))
              {
               return stopLossBased_M30 ;
              }
            else
               if(stopLossIsValidSells(stopLossBased_M15,_maxPipsRiskAmountActual))
                 {
                  return stopLossBased_M15 ;
                 }
            Comment("Cant take a sell because stop loss is not valid !");
            return -1 ;
           }
   Comment("Cant take a sell because stop loss is not valid !");
   return -1 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool H4TimeFrameConfirmedBuys()
  {


   if(!H4_Break_Confirmation && !H4_Closure_Confirmation)  // if the user doesnt want any 4H  confirmation, return true . now the code understands that its not necessecary to look at the 4H confirmation.
     {
      return true ;
     }

   if((H4_Closure_Confirmation && candleClosedBullish(PERIOD_H4,1)) && !H4_Break_Confirmation)  // if the user wants only 4H closure confirmation
     {

      return true ;
     }
   else
      if(candleClosedBullish(PERIOD_H4,1) && (H4_Break_Confirmation && last_H4_candle_broke_structure))  // if the user wants a 4H  breakout confirmation (which includes the closure confirmation too)
        {
         Print("Price broke structure on H4");
         return true ;
        }


   return false ; // all other cases return false, which means the 4H confirmation conditon wast not satisfied.
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool H4TimeFrameConfirmedSells()
  {


   if(!H4_Break_Confirmation && !H4_Closure_Confirmation)  // if the user doesnt want any 4H  confirmation, return true . now the code understands that its not necessecary to look at the 4H confirmation.
     {
      return true ;
     }

   if((H4_Closure_Confirmation && candleClosedBearish(PERIOD_H4,1)) && !H4_Break_Confirmation)  // if the user wants only 4H closure confirmation
     {

      return true ;
     }
   else
      if(candleClosedBearish(PERIOD_H4,1) && (H4_Break_Confirmation && last_H4_candle_broke_structure))  // if the user wants a 4H  breakout confirmation (which includes the closure confirmation too)
        {
         Print("Price broke structure on H4");
         return true ;
        }


   return false ; // all other cases return false, which means the 4H confirmation conditon wast not satisfied.
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangesBuys()
  {
   double nearest_H4_Resistance = findClosestResistancePrice(zoneContainer_H4);
   double nearest_H1_Resistance = findClosestResistancePrice(zoneContainer_H1);
   double nearest_M30_Resistance = findClosestResistancePrice(zoneContainer_M30);

   if((nearest_H4_Resistance >= cleanRangeUponEntryActual) && (nearest_H1_Resistance >= cleanRangeUponEntryActual) && (nearest_M30_Resistance >= cleanRangeUponEntryActual))
     {
      return true ;

     }

   return false ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangeBuys_H4()
  {
   double nearest_H4_Resistance = findClosestResistancePrice(zoneContainer_H4);
   double cleanRangeValue_H4 = nearest_H4_Resistance -  SymbolInfoDouble(_Symbol,SYMBOL_ASK) ;
   if(((cleanRangeValue_H4 >= cleanRangeUponEntryActual) && (cleanRangeValue_H4 > 0))|| (nearest_H4_Resistance == -1))
     {
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a buy, Reason: No Clean Range on H4");
   return false ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangeBuys_H1()
  {
   double nearest_H1_Resistance = findClosestResistancePrice(zoneContainer_H1);
   double cleanRangeValue_H1 = nearest_H1_Resistance -  SymbolInfoDouble(_Symbol,SYMBOL_ASK) ;
   if(((cleanRangeValue_H1 >= cleanRangeUponEntryActual) && (cleanRangeValue_H1 > 0))|| (nearest_H1_Resistance == -1))
     {
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a buy, Reason: No Clean Range on H1");
   return false ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangeBuys_M30()
  {
   double nearest_M30_Resistance = findClosestResistancePrice(zoneContainer_M30);
   double cleanRangeValue_M30 = nearest_M30_Resistance -  SymbolInfoDouble(_Symbol,SYMBOL_ASK) ;
   if(((cleanRangeValue_M30 >= cleanRangeUponEntryActual) && (cleanRangeValue_M30 > 0))|| (nearest_M30_Resistance == -1))
     {
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a buy, Reason: No Clean Range on M30");
   return false ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangesSells_H4()
  {
   double nearest_H4_Support = findClosestSupportPrice(zoneContainerSupport_H4);
   double cleanRangeValue_H4 = SymbolInfoDouble(_Symbol,SYMBOL_BID) - nearest_H4_Support ;
   if(((cleanRangeValue_H4 >= cleanRangeUponEntryActual) && (cleanRangeValue_H4 > 0))|| (nearest_H4_Support == -1))
     {
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a sell, Reason: No Clean Range on H4");
   return false ;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangeSells_H1()
  {
   double nearest_H1_Support = findClosestSupportPrice(zoneContainerSupport_H1);
   double cleanRangeValue_H1 = SymbolInfoDouble(_Symbol,SYMBOL_BID) - nearest_H1_Support ;
   if(((cleanRangeValue_H1 >= cleanRangeUponEntryActual) && (cleanRangeValue_H1 > 0))|| (nearest_H1_Support == -1))
     {
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a sell, Reason: No Clean Range on H1");
   return false ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool validateCleanRangeSells_M30()
  {
   double nearest_M30_Support = findClosestSupportPrice(zoneContainerSupport_M30);
   double cleanRangeValue_M30 = SymbolInfoDouble(_Symbol,SYMBOL_BID) - nearest_M30_Support ;
   if(((cleanRangeValue_M30 >= cleanRangeUponEntryActual) && (cleanRangeValue_M30 > 0))|| (nearest_M30_Support == -1))
     {
      Print("Closest support is: "+ nearest_M30_Support);
      return true ;
     }
   datetime currTime = TimeCurrent();
   string timeInStr = TimeToString(currTime,TIME_MINUTES);
   Comment(timeInStr + ": Cant Take a sell, Reason: No Clean Range on M30");
   return false ;
  }




//+------------------------------------------------------------------+
