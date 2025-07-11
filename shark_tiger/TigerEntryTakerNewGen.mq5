//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "library_functions.mqh"

#include "NewCandleDetector.mqh"
#include "GraphicalObjectsManager.mqh"
#include  "Zone.mqh"
#include "ZoneContainer.mqh"
#include "LotSizeCalculator.mqh"
#include  "MarketObserverTiger.mqh"

#include "BuyEntryManager.mqh"
#include "SellEntryManager.mqh"
#include "BuyTradeManager.mqh"
#include "SellTradeManager.mqh"


input group "Range Related Variables"
input double rangeDistanceBetweenZones ;
input double cleanRangeUponEntry ;
input double potentialRR;

input group "Zone Size Settings"
input double resistanceExtendAboveCandle;
input double resistanceLowerEdgeExtend ;
input double supportExtendBelowCandle ;
input double supportHigherEdgeExtend;

input group "Zone TimeFrames"
input bool APPLY_M30_STRUCTURE ;
input bool APPLY_H1_STRUCTURE;

input group "Candle Body Variables"
input double WICK_RATIO_REJECTION;
input double SIZE_OF_BREAKER_CANDLE_BODY;

input group "Trade Related Variables"
input double riskManagementPartial ;
input double firstPartialCloseFactor ;
input double firstPartialProfitInPips;

input group "Trading Sessions"
input bool TRADE_NEW_YORK_ALLOWED = true  ;
input bool TRADE_LONDON_ALLOWED = true ;

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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

Zone* temporaryRestestSupportZone = new Zone();



// TRADE CLASSES
BuyEntryManager buyEntryManager ;
SellEntryManager sellEntryManager ;


// LotSizeCalculator class

LotSizeCalculator lsCalc ;


string activeTradeType ; // its either , "BUY" , or "SELL"
bool securedRisk = false ;

ulong activeTradeId ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

// ONLY FOR VISULAZITAION ON STRATEGY TESTER
   iClose(_Symbol,PERIOD_W1,1);
   iClose(_Symbol,PERIOD_D1,1);
   iClose(_Symbol,PERIOD_H4,5);
   iClose(_Symbol,PERIOD_H1,5);
   iClose(_Symbol,PERIOD_M30,5);
   iClose(_Symbol,PERIOD_M15,5);

   objectsManager.addTextTiger();
   
   
//objectsManager.addMarketDescriptionTextTiger();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---


   
   if(newCandleDetectorM15.isNewCandle())
     {
      
     
        manageRiskIfNeeded();
        for(int i=0 ;i< PositionsTotal() ; i++){
      
      Print("active trade id is : " + PositionGetTicket(i));
        
     }
  
  
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(newCandleDetector30M.isNewCandle())
  {
//Print("number of opened orders are: " + PositionsTotal());
// DETECTING SUPPORTS AND RESISTANCES
   detectAndDrawResistanceOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrPink,clrBlue,zoneContainer_M30);
   detectAndDrawSupportOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrYellow,clrGreen,zoneContainerSupport_M30);

// VARIABLE PREPROCESSING FOR BOS
   double brokenResistanceLowerPrice = -1 ;
   string brokenZoneTypeResistance = "" ;

   double brokenSupportHigherPrice = -1;
   string brokenZoneTypeSupport = "" ;

// BREAK OF STRUCTURE HANDLING

   if(updateBreakAboveStructureAndDelete(zoneContainer_M30,PERIOD_M30,"PERIOD_M30",brokenResistanceLowerPrice,brokenZoneTypeResistance) 
       && buyBreakerCandleIsValid(PERIOD_M30, SIZE_OF_BREAKER_CANDLE_BODY)
        && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED) ))  // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
     {

      double firstResistancePrice = findClosestResistancePrice(zoneContainer_M30);
      double cleanRangeValueBuys = firstResistancePrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK);


      if(firstResistancePrice != -1 && brokenZoneTypeResistance == "TYPE_RESISTANCE_BREAKOUT")
        {
         Comment("M30 candle Broke and closed above the zone. the closest resistance price is:" + DoubleToString(firstResistancePrice));
         if(cleanRangeValueBuys >= cleanRangeUponEntry)
           {

            double stopLossBased_H1  = iLow(_Symbol,PERIOD_H1,1);
            double stopLossBased_M30  = iLow(_Symbol,PERIOD_M30,1);
            double stopLossBased_M15 = iLow(_Symbol,PERIOD_M15,1);

            stopLossBased_H1 = stopLossBased_H1 - stopLossUnderWickBy ;
            stopLossBased_M30 = stopLossBased_M30 - stopLossUnderWickBy ;
            stopLossBased_M15 = stopLossBased_M15 - stopLossUnderWickBy ;

            if(stopLossIsValidBuys(stopLossBased_M30, maxPipsRiskAmount))
              {

               double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M30);
               if(PositionsTotal() == 0)   // there are no active trades
                 {

                  activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToEnter,stopLossBased_M30, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + netTakeProfit) ;
                  activeTradeType = "BUY" ;
                  Comment("Took a buy. stop loss: based on M30, " + "Active trade id: " + activeTradeId);
                 }
               else
                 {

                  Comment("I cant take a trade because another trade is running");
                 }


              }
            else
               if(stopLossIsValidBuys(stopLossBased_M15,maxPipsRiskAmount)  && candleClosedBullish(PERIOD_M15,1))
                 {
                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M15);
                  if(PositionsTotal() == 0)
                    {
                     activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToEnter,stopLossBased_M15, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + netTakeProfit) ;
                     activeTradeType = "BUY" ;
                     Comment("Took a buy. stop loss: based on M15, " + "Active trade id: " + activeTradeId);
                    }
                  else
                    {

                     Comment("I cant take a trade because another trade is running");

                    }

                 }

               else
                 {


                  Comment("Failed to find a valid stop loss on both M30 and M15 !");
                 }

           }

         else
           {
            datetime currTime = TimeCurrent();
            string timeInStr = TimeToString(currTime,TIME_MINUTES);

            Comment(timeInStr + ": Price Broke the resitance zone, but not enough clean range to take a trade");

           }

        }
      else
        {
         datetime currTime = TimeCurrent();
         string timeInStr = TimeToString(currTime,TIME_MINUTES);
         Comment(timeInStr+ ": Price broke the resistance zone but i dont see the next target zone, Or the zone price broke was not a breakout zone ");

        }

     }


   if(updateBreakBelowStructureAndDelete(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30",brokenSupportHigherPrice,brokenZoneTypeSupport)
    && sellBreakerCandleIsValid(PERIOD_M30, SIZE_OF_BREAKER_CANDLE_BODY) 
     && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED) )) // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
     {

      
      double firstSupportPrice = findClosestSupportPrice(zoneContainerSupport_M30);
      double cleanRangeValueSells = SymbolInfoDouble(_Symbol, SYMBOL_BID) - firstSupportPrice;

      Print("firstSupport variable is: " + firstSupportPrice);
      Print("cleanRangeValueSells :" + cleanRangeValueSells);


      if(firstSupportPrice != -1 && brokenZoneTypeSupport == "TYPE_SUPPORT_BREAKOUT")
        {
         Comment("M30 candle Broke and closed below the zone. the closest support price is:" + DoubleToString(firstSupportPrice));
         if(cleanRangeValueSells >= cleanRangeUponEntry)
           {

            double stopLossBased_H1  = iHigh(_Symbol,PERIOD_H1,1);
            double stopLossBased_M30  = iHigh(_Symbol,PERIOD_M30,1);
            double stopLossBased_M15 = iHigh(_Symbol,PERIOD_M15,1);

            stopLossBased_H1 = stopLossBased_H1 + stopLossAboveWickBy ;
            stopLossBased_M30 = stopLossBased_M30 + stopLossAboveWickBy ;
            stopLossBased_M15 = stopLossBased_M15 + stopLossAboveWickBy ;

            if(stopLossIsValidSells(stopLossBased_M30, maxPipsRiskAmount))
              {

               double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M30);
               if(PositionsTotal() == 0)
                 {
                  activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToEnter,stopLossBased_M30, SymbolInfoDouble(_Symbol, SYMBOL_BID) - netTakeProfit) ;
                  activeTradeType = "SELL";
                  Comment("Took a sell. stop loss: based on M30, " + "Active trade id: " + activeTradeId);

                 }
               else
                 {

                  Comment("i cant take a trade since another one is running");
                 }


              }
            else
               if(stopLossIsValidSells(stopLossBased_M15,maxPipsRiskAmount) && candleClosedBearish(PERIOD_M15,1))
                 {
                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M15);

                  if(PositionsTotal() == 0)
                    {
                     activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToEnter,stopLossBased_M15, SymbolInfoDouble(_Symbol, SYMBOL_BID) - netTakeProfit) ;
                     activeTradeType = "SELL";
                     Comment("Took a sell. stop loss: based on M15, "+ "Active trade id: " + activeTradeId);
                    }
                  else
                    {
                     Comment("i cant take a trade since another one is running");
                    }
                 }

               else
                 {


                  Comment("Failed to find a valid stop loss on both M30 and M15 !");
                 }

           }

         else
           {
            datetime currTime = TimeCurrent();
            string timeInStr = TimeToString(currTime,TIME_MINUTES);
            

            Comment(timeInStr + ": Price Broke the support zone, but not enough clean range to take a trade");

           }

        }
      else
        {
         datetime currTime = TimeCurrent();
         string timeInStr = TimeToString(currTime,TIME_MINUTES);
         Comment(timeInStr+ ": Price broke the support zone but i dont see the next target zone, Or the zone price broke was not a breakout zone ");

        }



     }


   datetime currTime = TimeCurrent();
   ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
   
      
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(newCandleDetectorDaily.isNewCandle())
  {

//detectAndDrawResistanceOnTimeFrame(PERIOD_D1,"PERIOD_D1",clrYellow,clrYellow,zoneContainer_D1);
//updateBreakAboveStructureAndDelete(zoneContainer_D1,PERIOD_D1,"PERIOD_D1");
   objectsManager.drawVerticalLine(clrAqua, TimeCurrent());


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(newCandleDetectorWeekly.isNewCandle())
  {

   objectsManager.drawVerticalLine(clrRed, TimeCurrent());;
  }

  }
  
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool detectAndDrawResistanceOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color, long usual_zone_color,ZoneContainer& zoneContainer)
  {


   if((candleClosedBullish(timeFrame,2) && candleClosedBearish(timeFrame,1)) || (candleClosedBullish(timeFrame,3)  && candleClosedDoji(timeFrame,2) && candleClosedBearish(timeFrame,1)))   // if resistance formed
     {

      //  create a rectangle  with a unique name
      int currentIdCounter = zoneContainer.getZonesIdCounter();


      datetime _leftEdge = iTime(_Symbol,timeFrame,2);
      datetime _rightEdge = D'2023.11.01 00:00:00';
      double resistancePrice = iOpen(_Symbol,timeFrame,1);





      if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice >= rangeDistanceBetweenZones)) // check if it has a clean range above
        {

         Zone* newZone = new Zone() ;
         newZone.setHigherEdgePrice(resistancePrice + resistanceExtendAboveCandle);
         newZone.setLowerEdgePrice(resistancePrice - resistanceLowerEdgeExtend);
         newZone.setLeftEdge(_leftEdge);
         newZone.setRightEdge(_rightEdge);
         newZone.setId(IntegerToString(currentIdCounter));
         newZone.setTimeFrame(timeFrameStr);
         newZone.setType("TYPE_RESISTANCE_BREAKOUT");




         zoneContainer.addResistanceZoneTiger(newZone);
         zoneContainer.incrementZonesIdCounter();

         Print("current id counter of, zoneContainer is: " + currentIdCounter);
         objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandle,resistancePrice - resistanceLowerEdgeExtend,BOS_zone_color);
         //Print("Number of active zones is: " + zoneContainer.getNumberOfActiveZones());
         //zoneContainer.printZonesSortedArray();
        }

      else
         if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice < rangeDistanceBetweenZones)) // if it doesnt have a clean range, just add it as a blue zone
           {
            double currentHighEdge = resistancePrice + resistanceExtendAboveCandle ; // this is a high edge of a resistance, but its not considered as a zone, because it doesnt have clean range above
            double currentLowEdge  = resistancePrice - resistanceLowerEdgeExtend;   // this is a low edge of a resistance, but its not considered as a zone, because it doesnt have clean range above

            Zone* newZone = new Zone() ;
            newZone.setHigherEdgePrice(resistancePrice + resistanceExtendAboveCandle);
            newZone.setLowerEdgePrice(resistancePrice -  resistanceLowerEdgeExtend);
            newZone.setLeftEdge(_leftEdge);
            newZone.setRightEdge(_rightEdge);
            newZone.setId(IntegerToString(currentIdCounter));
            newZone.setTimeFrame(timeFrameStr);
            newZone.setType("TYPE_RESISTANCE_NORMAL");

            zoneContainer.addResistanceZoneTiger(newZone);
            zoneContainer.incrementZonesIdCounter();

            //objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandle,resistancePrice,usual_zone_color);

            /*if(zoneContainer.getZoneByIndex(1).getType() == "TYPE_RESISTANCE_NORMAL"){
                  string idOfZoneToHide = zoneContainer.getZoneByIndex(1).getId();
                  deleteZoneGuiOnly(idOfZoneToHide,zoneContainer);
            } */



           }

         else
            if(zoneContainer.getNumberOfActiveZones() == 0)  // this means this is the first zone to add to the data strucutre
              {

               //Print("Entered here 2");
               Zone* newZone = new Zone() ;
               newZone.setHigherEdgePrice(resistancePrice + resistanceExtendAboveCandle);
               newZone.setLowerEdgePrice(resistancePrice - resistanceLowerEdgeExtend);
               newZone.setLeftEdge(_leftEdge);
               newZone.setRightEdge(_rightEdge);
               newZone.setId(IntegerToString(currentIdCounter));
               newZone.setTimeFrame(timeFrameStr);
               newZone.setType("TYPE_RESISTANCE_BREAKOUT");



               zoneContainer.addResistanceZoneTiger(newZone);
               zoneContainer.incrementZonesIdCounter();


               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandle,resistancePrice - resistanceLowerEdgeExtend,BOS_zone_color);
               //zoneContainer.printZonesSortedArray();
              }

      return true ;

     }
   return false ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool detectAndDrawSupportOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color, long usual_zone_color,ZoneContainer& zoneContainer)
  {


   if((candleClosedBearish(timeFrame,2) && candleClosedBullish(timeFrame,1)) || (candleClosedBearish(timeFrame,3)  && candleClosedDoji(timeFrame,2) && candleClosedBullish(timeFrame,1)))   // if support formed
     {

      //  create a rectangle  with a unique name
      int currentIdCounter = zoneContainer.getSupportZonesIdCounter();


      datetime _leftEdge = iTime(_Symbol,timeFrame,2);
      datetime _rightEdge = D'2023.11.01 00:00:00';
      double supportPrice = iOpen(_Symbol,timeFrame,1);





      if((zoneContainer.getNumberOfActiveZones() != 0) && (supportPrice - zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge() >= rangeDistanceBetweenZones)) // check if it has a clean range down
        {

         Zone* newZone = new Zone() ;
         newZone.setLowerEdgePrice(supportPrice - supportExtendBelowCandle);
         newZone.setHigherEdgePrice(supportPrice + supportHigherEdgeExtend);
         newZone.setLeftEdge(_leftEdge);
         newZone.setRightEdge(_rightEdge);
         newZone.setId(IntegerToString(currentIdCounter));
         newZone.setTimeFrame(timeFrameStr);
         newZone.setType("TYPE_SUPPORT_BREAKOUT");




         zoneContainer.addSupportZoneTiger(newZone);
         zoneContainer.incrementZonesIdCounterSupport();

         Print("current id counter of, zoneContainer_support is: " + currentIdCounter);
         objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice + supportHigherEdgeExtend,supportPrice- supportExtendBelowCandle,BOS_zone_color);
         //Print("Number of active zones is: " + zoneContainer.getNumberOfActiveZones());
         //zoneContainer.printZonesSortedArray();
        }

      else
         if((zoneContainer.getNumberOfActiveZones() != 0) && (supportPrice - zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getHigherEdge() < rangeDistanceBetweenZones)) // if it doesnt have a clean range, just add it as a blue zone
           {
            double currentHighEdge = supportPrice + supportHigherEdgeExtend ; // this is a high edge of a resistance, but its not considered as a zone, because it doesnt have clean range above
            double currentLowEdge  = supportPrice - supportExtendBelowCandle;   // this is a low edge of a resistance, but its not considered as a zone, because it doesnt have clean range above

            Zone* newZone = new Zone() ;
            newZone.setHigherEdgePrice(supportPrice + supportHigherEdgeExtend);
            newZone.setLowerEdgePrice(supportPrice - supportExtendBelowCandle);
            newZone.setLeftEdge(_leftEdge);
            newZone.setRightEdge(_rightEdge);
            newZone.setId(IntegerToString(currentIdCounter));
            newZone.setTimeFrame(timeFrameStr);
            newZone.setType("TYPE_SUPPORT_NORMAL");

            zoneContainer.addSupportZoneTiger(newZone);
            zoneContainer.incrementZonesIdCounterSupport();
            //objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice,supportPrice - supportExtendBelowCandle,usual_zone_color);

           }

         else
            if(zoneContainer.getNumberOfActiveZones() == 0)  // this means this is the first zone to add to the data strucutre
              {

               //Print("Entered here 2");
               Zone* newZone = new Zone() ;
               newZone.setHigherEdgePrice(supportPrice + supportHigherEdgeExtend);
               newZone.setLowerEdgePrice(supportPrice - supportExtendBelowCandle);
               newZone.setLeftEdge(_leftEdge);
               newZone.setRightEdge(_rightEdge);
               newZone.setId(IntegerToString(currentIdCounter));
               newZone.setTimeFrame(timeFrameStr);
               newZone.setType("TYPE_SUPPORT_BREAKOUT");


               zoneContainer.addSupportZoneTiger(newZone);
               zoneContainer.incrementZonesIdCounterSupport();


               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,supportPrice + supportHigherEdgeExtend,supportPrice - supportExtendBelowCandle,BOS_zone_color);
               //zoneContainer.printZonesSortedArray();
              }


      return true ;

     }
   return false ;
  }









//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedBullish(ENUM_TIMEFRAMES _timeFrame, int _index)
  {
   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);


   if(candleClose >candleOpen)   // the candle closed bullish
     {

      return true ;
     }
   return false ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedBearish(ENUM_TIMEFRAMES _timeFrame,int _index)
  {


   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);


   if(candleClose < candleOpen)   // the candle closed bullish
     {

      return true ;
     }
   return false ;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedDoji(ENUM_TIMEFRAMES _timeFrame, int _index)
  {
   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);

   if(candleClose == candleOpen)
     {
      return true;
     }
   else
     {
      return false;
     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
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

   if(zoneContainer.getNumberOfActiveZones() != 0)  // if there are zones found
     {
      if(marketObserverTiger.candleClosedAboveResistanceByIndex(0,timeFrame,zoneContainer))  // check if candle closed above the zone
        {



         datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
         datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';


         while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0)  // this while is used in the case of a candle closing above more than 1 zone at once
           {
            /* temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(0).getHigherEdge());
             temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(0).getLowerEdge());
             temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
             temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
             temporaryRestestSupportZone.setId("999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
             temporaryRestestSupportZone.setTimeFrame("PERIOD_M30");
             temporaryRestestSupportZone.setType("TYPE_SUPPORT");
             deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId())); // delete the zone with the GUI */

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

         /*if(zoneContainer.getNumberOfActiveZones() != 0 && zoneContainer.getZoneByIndex(0).getType() == "TYPE_RESISTANCE_NORMAL"){

            Zone* tempZone = zoneContainer.getZoneByIndex(0);
            string zoneIdStr = tempZone.getId();
            int zoneIdInteger = StringToInteger(zoneIdStr);

            objectsManager.drawRectangleInStrategyTester(zoneIdInteger,tempZone.getLeftEdge(),tempZone.getRightEdge(),tempZone.getHigherEdge(),tempZone.getLowerEdge(),clrRed);
            Print("Retrieved the zone succesfully!");


         } */
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

   if(zoneContainer.getNumberOfActiveZones() != 0)  // if there are zones found
     {

      if(marketObserverTiger.candleClosedBelowSupportByIndex(zoneContainer.getNumberOfActiveZones() -1,timeFrame,zoneContainer))   // check if candle closed below the zone
        {


         datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
         datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';


         while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0)  // this while is used in the case of a candle closing above more than 1 zone at once
           {
            /* temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(0).getHigherEdge());
             temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(0).getLowerEdge());
             temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
             temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
             temporaryRestestSupportZone.setId("999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
             temporaryRestestSupportZone.setTimeFrame("PERIOD_M30");
             temporaryRestestSupportZone.setType("TYPE_SUPPORT");
             deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId())); // delete the zone with the GUI */

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

         /*if(zoneContainer.getNumberOfActiveZones() != 0 && zoneContainer.getZoneByIndex(0).getType() == "TYPE_RESISTANCE_NORMAL"){

            Zone* tempZone = zoneContainer.getZoneByIndex(0);
            string zoneIdStr = tempZone.getId();
            int zoneIdInteger = StringToInteger(zoneIdStr);

            objectsManager.drawRectangleInStrategyTester(zoneIdInteger,tempZone.getLeftEdge(),tempZone.getRightEdge(),tempZone.getHigherEdge(),tempZone.getLowerEdge(),clrRed);
            Print("Retrieved the zone succesfully!");


         } */


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



bool buyStopLossUnderZone(double resistanceZoneLowerEdge, double stopLossValue){

   if(stopLossValue < resistanceZoneLowerEdge){
      return true ;
   }
   else{
      Comment("stop loss is not under the zone im not taking a buy");
      return false ;
   
   }

}


bool sellStopLossAboveZone(double supportZoneHigherEdge, double stopLossValue){

   if(stopLossValue > supportZoneHigherEdge){
      return true ;
   }
   else{
      Comment("stop loss is not above the zone, so im not taking a sell");
      return false ;
   }
}


void manageRiskIfNeeded(){
      
       if(PositionsTotal()!= 0)  // There is an active trade
        {
         if(activeTradeType == "BUY")
           {
               
               if(candleClosedBearish(PERIOD_M15,1) && !bearishCandleIsWeak(PERIOD_M15,1, WICK_RATIO_REJECTION)){
                  Print("M15 , closed against my direction, we should close half");
                  if(securedRisk == false && closePartialFromAllPositions(riskManagementPartial)){
                     securedRisk = true ;
                  }
               }

           }
         else
            if(activeTradeType == "SELL")
              {
                if(candleClosedBullish(PERIOD_M15,1) && !bullishCandleIsWeak(PERIOD_M15,1, WICK_RATIO_REJECTION)){
                  Print("M15 , closed against my direction, we should close half");
                  if(securedRisk == false  && closePartialFromAllPositions(riskManagementPartial)){
                     securedRisk = true ;
                  }
                }

              }

        }
        else{
            securedRisk = false ; // return the risk secure flag to false , to be ready for the next trade
        
        }

}