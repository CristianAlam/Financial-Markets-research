//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "Algo_Skeleton_Functions.mqh"

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

   for(int i=0; i<NUM_MAX_ALLOWED_TRADES ; i++)
     {
      BuyActiveTradesArray[i] = NULL ;
      SellActiveTradesArray[i] = NULL ;

     }






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
   Print("Buys Count: " + buysCount);
   Print("Sells Count: " + sellsCount);
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   cleanBuyTradesArr();
   cleanSellTradesArr();
   secureProfitIfNeeded();

   /*if(newCandleDetectorM15.isNewCandle())
     {
      
      
     } */

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetector30M.isNewCandle())
     {   

      datetime currTime = TimeCurrent();
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
     

     } 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   
   if(newCandleDetector1H.isNewCandle()){
      
     if(zoneContainerSupport_H4.getNumberOfActiveZones()>0){
      updateNormalZonesSupport(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4",clrAliceBlue,rangeDistanceBetweenZonesActual_H4);
     }
     
     if(zoneContainer_H4.getNumberOfActiveZones()){
        updateNormalZonesResistance(zoneContainer_H4,PERIOD_H4,"PERIOD_H4",clrPink,rangeDistanceBetweenZonesActual_H4);
     }
      
   }

   
   if(newCandleDetector4H.isNewCandle()){
       trailAllOpenPositionsIfNeeded(PERIOD_H4);
          
       detectAndDrawResistanceOnTimeFrame(PERIOD_H4,"PERIOD_H4",clrPink,zoneContainer_H4,rangeDistanceBetweenZonesActual_H4);
       detectAndDrawSupportOnTimeFrame(PERIOD_H4,"PERIOD_H4",clrAliceBlue,zoneContainerSupport_H4,rangeDistanceBetweenZonesActual_H4);
                                                  
       // BREAK OF STRUCTURE HANDLING
       handleBuys(zoneContainer_H4,PERIOD_H4,"PERIOD_H4",cleanRangeUponEntryActual);
       handleSells(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4",cleanRangeUponEntryActual);
      
      
      zoneContainerSupport_H4.printZonesSortedArray();
      zoneContainer_H4.printZonesSortedArray();
   }
   
   

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

      objectsManager.drawVerticalLine(clrRed, TimeCurrent());
      
      weekCounter++ ;
      
      if(weekCounter == deleteAllZonesAfter_Weeks){
      
         //deleteAllzonesWithGUI();
         weekCounter = 0;
      }
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

