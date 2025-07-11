//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "Algo_Skeleton_Functions.mqh"

long H4_SUPPORT_ZONE_CLR ;
long H4_RESISTANCE_ZONE_CLR ;
long H1_SUPPORT_ZONE_CLR;
long H1_RESISTANCE_ZONE_CLR;
long M30_SUPPORT_ZONE_CLR ;
long M30_RESISTANCE_ZONE_CLR ;

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
   
    H4_SUPPORT_ZONE_CLR = clrBlack ;
    H4_RESISTANCE_ZONE_CLR = clrBlack ;
   
   if(ENTRY_BASED_H1_STRUCTURE == true && ENTRY_BASED_M30_STRUCTURE == false){
      M30_SUPPORT_ZONE_CLR = clrBlack ;
      M30_RESISTANCE_ZONE_CLR = clrBlack ;
      
      H1_SUPPORT_ZONE_CLR = clrAliceBlue ;
      H1_RESISTANCE_ZONE_CLR = clrDarkGray ;
      
   }
   else if(ENTRY_BASED_H1_STRUCTURE == false && ENTRY_BASED_M30_STRUCTURE == true){
      M30_SUPPORT_ZONE_CLR = clrAliceBlue ;
      M30_RESISTANCE_ZONE_CLR = clrDarkGray ;
      
      H1_SUPPORT_ZONE_CLR = clrBlack ;
      H1_RESISTANCE_ZONE_CLR = clrBlack ;
      
   }
   

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

   if(newCandleDetectorM15.isNewCandle())
     {
      
       // UPDATING M30 ZONES
       if(zoneContainerSupport_M30.getNumberOfActiveZones()>0){
      updateNormalZonesSupport(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30",M30_SUPPORT_ZONE_CLR,rangeDistanceBetweenZonesActual_M30,0);
     }
     
     if(zoneContainer_M30.getNumberOfActiveZones()> 0){
        updateNormalZonesResistance(zoneContainer_M30,PERIOD_M30,"PERIOD_M30",M30_RESISTANCE_ZONE_CLR,rangeDistanceBetweenZonesActual_M30,0);
     } 
     } 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetector30M.isNewCandle())
     {   
      
      if(trail_based_m30){
          trailAllOpenPositionsIfNeeded(PERIOD_M30);
      }
      datetime currTime = TimeCurrent();
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
      
       detectAndDrawResistanceOnTimeFrame(PERIOD_M30,"PERIOD_M30",M30_RESISTANCE_ZONE_CLR,zoneContainer_M30,rangeDistanceBetweenZonesActual_M30,0);
       detectAndDrawSupportOnTimeFrame(PERIOD_M30,"PERIOD_M30",M30_SUPPORT_ZONE_CLR,zoneContainerSupport_M30,rangeDistanceBetweenZonesActual_M30,0);
      if(ENTRY_BASED_M30_STRUCTURE){
                
         handleBuys(zoneContainer_M30,PERIOD_M30,"PERIOD_M30",cleanRangeUponEntryActual);
         handleSells(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30",cleanRangeUponEntryActual);
      }
      else{
      
          handleBullishBreakouts(zoneContainer_M30,PERIOD_M30,"PERIOD_M30");
         handleBearishBreakouts(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30");
      }
       
    
      
      // UPDATING H1 ZONES
       if(zoneContainerSupport_H1.getNumberOfActiveZones()>0){
      updateNormalZonesSupport(zoneContainerSupport_H1,PERIOD_H1,"PERIOD_H1",H1_SUPPORT_ZONE_CLR,rangeDistanceBetweenZonesActual_H1,1000);
     }
     
     if(zoneContainer_H1.getNumberOfActiveZones()> 0){
        updateNormalZonesResistance(zoneContainer_H1,PERIOD_H1,"PERIOD_H1",H1_RESISTANCE_ZONE_CLR,rangeDistanceBetweenZonesActual_H1,1000);
     } 
     


      zoneContainerSupport_M30.printZonesSortedArray();
      zoneContainer_M30.printZonesSortedArray();
     } 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   
    if(newCandleDetector1H.isNewCandle()){
      
      if(trail_based_h1){
         trailAllOpenPositionsIfNeeded(PERIOD_H1);
      }
      
     
     detectAndDrawResistanceOnTimeFrame(PERIOD_H1,"PERIOD_H1",H1_RESISTANCE_ZONE_CLR,zoneContainer_H1,rangeDistanceBetweenZonesActual_H1,1000);
     detectAndDrawSupportOnTimeFrame(PERIOD_H1,"PERIOD_H1",H1_SUPPORT_ZONE_CLR,zoneContainerSupport_H1,rangeDistanceBetweenZonesActual_H1,1000); 
     
      if(ENTRY_BASED_H1_STRUCTURE){
                        
          handleBuys(zoneContainer_H1,PERIOD_H1,"PERIOD_H1",cleanRangeUponEntryActual);
          handleSells(zoneContainerSupport_H1,PERIOD_H1,"PERIOD_H1",cleanRangeUponEntryActual);
      }
     
       else{
         handleBullishBreakouts(zoneContainer_H1,PERIOD_H1,"PERIOD_H1");
         handleBearishBreakouts(zoneContainerSupport_H1,PERIOD_H1,"PERIOD_H1");
       
       }
      
      
     // UPDATING H4 ZONES 
     if(zoneContainerSupport_H4.getNumberOfActiveZones()>0){
      updateNormalZonesSupport(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4",H4_SUPPORT_ZONE_CLR,rangeDistanceBetweenZonesActual_H4,2000);
     }
     
     if(zoneContainer_H4.getNumberOfActiveZones()> 0){
        updateNormalZonesResistance(zoneContainer_H4,PERIOD_H4,"PERIOD_H4",H4_RESISTANCE_ZONE_CLR,rangeDistanceBetweenZonesActual_H4,2000);
     } 
     
     Print("H1 zones :");
     //zoneContainerSupport_H1.printZonesSortedArray();
     //zoneContainer_H1.printZonesSortedArray();
      
   }
      
           
      
   
   if(newCandleDetector4H.isNewCandle()){
      last_H4_candle_broke_structure = false ; 
      
       if(trail_based_h4){
         trailAllOpenPositionsIfNeeded(PERIOD_H4);
       }
       
          
       detectAndDrawResistanceOnTimeFrame(PERIOD_H4,"PERIOD_H4",H4_RESISTANCE_ZONE_CLR,zoneContainer_H4,rangeDistanceBetweenZonesActual_H4,2000);
       detectAndDrawSupportOnTimeFrame(PERIOD_H4,"PERIOD_H4",H4_SUPPORT_ZONE_CLR,zoneContainerSupport_H4,rangeDistanceBetweenZonesActual_H4,2000);
                                                  
       // BREAK OF STRUCTURE HANDLING
       
       
       handleBullishBreakouts(zoneContainer_H4,PERIOD_H4,"PERIOD_H4");
       handleBearishBreakouts(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4");
       
       //handleBuys(zoneContainer_H4,PERIOD_H4,"PERIOD_H4",cleanRangeUponEntryActual);
       //handleSells(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4",cleanRangeUponEntryActual);
      
      //Print("H4, Zones:");
      //zoneContainerSupport_H4.printZonesSortedArray();
      //zoneContainer_H4.printZonesSortedArray();
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

