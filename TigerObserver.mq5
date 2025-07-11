//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "NewCandleDetector.mqh"
#include "GraphicalObjectsManager.mqh"
#include  "Zone.mqh"
#include "ZoneContainer.mqh"

#include  "MarketObserverTiger.mqh"


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


// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();

// CONTAINERS INITIALIZATION


ZoneContainer* zoneContainer_W1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_D1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_H4 = new ZoneContainer() ;
ZoneContainer* zoneContainer_H1 = new ZoneContainer() ;
ZoneContainer* zoneContainer_M30 = new ZoneContainer() ;


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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

Zone* temporaryRestestSupportZone = new Zone();

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

   /*if(newCandleDetector30M.isNewCandle())
     {
      
      detectAndDrawResistanceOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrPink,clrBlue,zoneContainer_M30);
      updateBreakAboveStructureAndDelete(zoneContainer_M30,PERIOD_M30,"PERIOD_M30");
      
      detectAndDrawSupportOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrYellow,clrGreen,zoneContainerSupport_M30);
      updateBreakBelowStructureAndDelete(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30");
      
      
      datetime currTime = TimeCurrent();
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));

     } */
     
   
   /*if(newCandleDetector1H.isNewCandle()){
   
         
         MqlDateTime mqldt ;
      datetime currTime = TimeCurrent(mqldt);
      if(mqldt.hour == 13){
         
         objectsManager.drawVerticalLine(clrAzure,TimeCurrent());
      
      }
         detectAndDrawResistanceOnTimeFrame(PERIOD_H1,"PERIOD_H1",clrGray,clrRed,zoneContainer_H1);         
         updateBreakAboveStructureAndDelete(zoneContainer_H1,PERIOD_H1,"PERIOD_H1");         
         
         detectAndDrawSupportOnTimeFrame(PERIOD_H1,"PERIOD_H1",clrWhite,clrRed,zoneContainerSupport_H1);        
         updateBreakBelowStructureAndDelete(zoneContainerSupport_H1,PERIOD_H1,"PERIOD_H1");
         
                
         //zoneContainer_H1.printZonesSortedArray();
         //zoneContainerSupport_H1.printZonesSortedArray();
         
   } */
   
   
   
   if(newCandleDetector4H.isNewCandle()){
   
      detectAndDrawResistanceOnTimeFrame(PERIOD_H4,"PERIOD_H4",clrPurple,clrGreen,zoneContainer_H4);
      updateBreakAboveStructureAndDelete(zoneContainer_H4,PERIOD_H4,"PERIOD_H4");
      
      detectAndDrawResistanceOnTimeFrame(PERIOD_H4,"PERIOD_H4",clrPink,clrBlue,zoneContainer_H4);
      updateBreakAboveStructureAndDelete(zoneContainer_H4,PERIOD_H4,"PERIOD_H4");
      
      detectAndDrawSupportOnTimeFrame(PERIOD_H4,"PERIOD_H4",clrYellow,clrGreen,zoneContainerSupport_H4);
      updateBreakBelowStructureAndDelete(zoneContainerSupport_H4,PERIOD_H4,"PERIOD_H4");
      
      
      datetime currTime = TimeCurrent();
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
   }
   
   if(newCandleDetectorDaily.isNewCandle()){
      
      //detectAndDrawResistanceOnTimeFrame(PERIOD_D1,"PERIOD_D1",clrYellow,clrYellow,zoneContainer_D1);
      //updateBreakAboveStructureAndDelete(zoneContainer_D1,PERIOD_D1,"PERIOD_D1");
      objectsManager.drawVerticalLine(clrAqua, TimeCurrent());
      
      
      
   }
   
   
   if(newCandleDetectorWeekly.isNewCandle()){
     
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
bool detectAndDrawResistanceOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color, long usual_zone_color,ZoneContainer& zoneContainer )
  {


   if(candleClosedBullish(timeFrame,2) && candleClosedBearish(timeFrame,1)) // if resistance formed
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

         Print("current id counter of, zoneContainer is: " + currentIdCounter );
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
  
  
   
  
  bool detectAndDrawSupportOnTimeFrame(ENUM_TIMEFRAMES timeFrame, string timeFrameStr, long BOS_zone_color, long usual_zone_color,ZoneContainer& zoneContainer )
  {


   if(candleClosedBearish(timeFrame,2) && candleClosedBullish(timeFrame,1)) // if support formed
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

         Print("current id counter of, zoneContainer_support is: " + currentIdCounter );
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



void deleteZoneWithGUI(string _id, ZoneContainer& zoneContainer)
  {


   zoneContainer.deleteZone(_id);

   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }
     
     
    Print("Deleted the zone with gui!");

  }
  
  
  
  void deleteZoneGuiOnly(string _id,ZoneContainer& zoneContainer)
  {


   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }
     
    Print("Deleted the zone gui!");

  }
  
  
  
  
  
  
  
void updateBreakAboveStructureAndDelete(ZoneContainer& zoneContainer, ENUM_TIMEFRAMES timeFrame, string timeFrameStr){
      bool finishedDeleting = false ;
      
      if(zoneContainer.getNumberOfActiveZones() != 0)  // if there are zones found
        {
         if(marketObserverTiger.candleClosedAboveResistanceByIndex(0,timeFrame,zoneContainer))  // check if candle closed above the zone
           {
           
           
                  
            datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
            datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';
                      
            
            while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0 ) // this while is used in the case of a candle closing above more than 1 zone at once
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
                  temporaryRestestSupportZone.setType("TYPE_SUPPORT");
                  deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId()),zoneContainer); // delete the zone with the GUI
                 }
               else
                 {
                  finishedDeleting = true ;
                   ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"");
                   ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"");
                   ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"Candle Closed Above the zone");
                 }


              }
                  
                  /*if(zoneContainer.getNumberOfActiveZones() != 0 && zoneContainer.getZoneByIndex(0).getType() == "TYPE_RESISTANCE_NORMAL"){
                     
                     Zone* tempZone = zoneContainer.getZoneByIndex(0);
                     string zoneIdStr = tempZone.getId();
                     int zoneIdInteger = StringToInteger(zoneIdStr);
                     
                     objectsManager.drawRectangleInStrategyTester(zoneIdInteger,tempZone.getLeftEdge(),tempZone.getRightEdge(),tempZone.getHigherEdge(),tempZone.getLowerEdge(),clrRed);
                     Print("Retrieved the zone succesfully!");
                     
                  
                  } */
                  
                  
           }


        }

}





void updateBreakBelowStructureAndDelete(ZoneContainer& zoneContainer, ENUM_TIMEFRAMES timeFrame, string timeFrameStr){
      bool finishedDeleting = false ;
      
      if(zoneContainer.getNumberOfActiveZones() != 0)  // if there are zones found
        {
         
         if(marketObserverTiger.candleClosedBelowSupportByIndex(zoneContainer.getNumberOfActiveZones() -1 ,timeFrame,zoneContainer))  // check if candle closed below the zone
           {
                    
                  
            datetime _leftEdgeRestestZone = iTime(_Symbol,timeFrame,4);
            datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';
                     
            
            while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0 ) // this while is used in the case of a candle closing above more than 1 zone at once
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
                  temporaryRestestSupportZone.setType("TYPE_RESISTANCE");
                  
                  deleteZoneWithGUI((zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getId()),zoneContainer); // delete the zone with the GUI
                  
                 }
               else
                 {
                  //Print("Lower edge is: " + zoneContainer.getZoneByIndex(zoneContainer.getNumberOfActiveZones()-1).getLowerEdge());
                  finishedDeleting = true ;
                  ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"");
                   ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"");
                   ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"Candle Closed Below the zone");
                 }


              }
                  
                  /*if(zoneContainer.getNumberOfActiveZones() != 0 && zoneContainer.getZoneByIndex(0).getType() == "TYPE_RESISTANCE_NORMAL"){
                     
                     Zone* tempZone = zoneContainer.getZoneByIndex(0);
                     string zoneIdStr = tempZone.getId();
                     int zoneIdInteger = StringToInteger(zoneIdStr);
                     
                     objectsManager.drawRectangleInStrategyTester(zoneIdInteger,tempZone.getLeftEdge(),tempZone.getRightEdge(),tempZone.getHigherEdge(),tempZone.getLowerEdge(),clrRed);
                     Print("Retrieved the zone succesfully!");
                     
                  
                  } */
                  
                  
           }


        }

}