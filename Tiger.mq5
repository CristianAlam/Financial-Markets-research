//+------------------------------------------------------------------+
//|                                                        Tiger.mq5 |
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

#include  "MarketObserver.mqh"
#include "BuyEntryManager.mqh"
#include  "LotSizeCalculator.mqh"
input double rangeDistance ;
input double resistanceExtendAboveCandle;
input double supportExtendBelowCandle ;
input double stopLossLimit ;
double input riskInDollars ;
double input netTakeProfit ;
bool input allowSecondChanceStopLoss ;
double input bottomWickSize ;
double input smallBottomWickSize ;
double input buyStopPipsTrigger ;
bool input MOD_CLEAN  = false ;


bool waitingForBottomWickToForm = false ;
bool waitingForSmallBottomWickToForm = false ;
bool buyStopValid = false ;
bool closedPartialOnNegativeDirection = false ;
bool securedTenPips  = false ;


#include <Trade\Trade.mqh>

CTrade tradeTiger ; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();

// CONTAINERS INITIALIZATION
ZoneContainer* zoneContainer = new ZoneContainer() ;




// ALGORITHM CLASSES INITIALIZATION
MarketObserver* marketObserver = new MarketObserver(zoneContainer);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
NewCandleDetector newCandleDetector("PERIOD_M30");
BuyEntryManager buyEntryMan ;
LotSizeCalculator lotSizeCalc ;


Zone* temporaryRestestSupportZone = new Zone();
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   iClose(_Symbol,PERIOD_M15,5);
   iClose(_Symbol,PERIOD_H1,5);

   /*datetime d1=D'2023.09.01 00:00:00';  // Year Month Day Hours Minutes Seconds
   Print("the dateTime is: " + d1);

   Zone* newZone = new Zone() ;
                              newZone.setHigherEdgePrice(1930);
                              newZone.setLowerEdgePrice(1925);
                              newZone.setLeftEdge(iTime(_Symbol,PERIOD_CURRENT,2));
                              newZone.setRightEdge(d1);
                              newZone.setId("1");
                              newZone.setTimeFrame("PERIOD_M30");


   zoneContainer.addZone(newZone);
   objectsManager.drawRectangleInStrategyTester(1,iTime(_Symbol,PERIOD_CURRENT,2),d1,1930,1925);
   zoneContainer.printZonesSortedArray(); */


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


   if(securedTenPips == false ){
      secureTenPips(0.3);
   }
   
   if(waitingForBottomWickToForm){
      if(iClose(_Symbol,PERIOD_CURRENT,1) - SymbolInfoDouble(_Symbol, SYMBOL_BID) >= bottomWickSize){
         
         waitingForBottomWickToForm = false ;
         Print("Bottom Wick in length of at least " + bottomWickSize + " was formed !");
         buyStopValid = true ;
         
      
      }
      
   }
   
   
   
   
   if(buyStopValid){
      if( SymbolInfoDouble(_Symbol, SYMBOL_ASK) > iHigh(_Symbol,PERIOD_CURRENT,1) + buyStopPipsTrigger){ // here we take a buy entry based on break and retest wick. the Algo will first try to put the stop loss under the low of the temporary support zone
      // if that stop loss was too high , then it will put it under the low of the wick that was recently made. (the wick should be at least bottomWickSize which is currently 1) 
      
            double stopLossUnderTemporarySupportZone = temporaryRestestSupportZone.getLowerEdge() - 0.5 ; // under the temporary support zone
            double stopLossUnderWick = iLow(_Symbol,PERIOD_CURRENT,0) - 0.5; // the low of the current candle
            
            if(!((SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossUnderTemporarySupportZone) > stopLossLimit)){ // on this case a wick was formed price starts to break the previous candle high, im taking a buy
            //and im putting the stop loss below the whole zone (which is support now)
             double lotsToEnter = lotSizeCalc.calculateLotSize(riskInDollars,stopLossUnderTemporarySupportZone);
                  buyEntryMan.takeBuyTradeTiger(lotsToEnter,stopLossUnderTemporarySupportZone,2);
                  closedPartialOnNegativeDirection = false ;
                  securedTenPips  = false ;
                  buyStopValid = false ;
                  Print("Took a wick retest buy type 1");
            
                  
            }
            else if(!((SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossUnderWick) > stopLossLimit)){ // on this case a wick was formed price starts to break the previous candle high, im taking a buy
            //and im putting the stop loss below the wick (which is at least bottomWickSize)
                  
                  double lotsToEnter = lotSizeCalc.calculateLotSize(riskInDollars,stopLossUnderWick);
                  buyEntryMan.takeBuyTradeTiger(lotsToEnter,stopLossUnderWick,2);
                  closedPartialOnNegativeDirection = false ;
                  securedTenPips  = false ;
                  buyStopValid = false ;
                  Print("Took a wick retest buy type 2");
            }
      }
   
   }
   
   if(newCandleDetector.isNewCandle())
     {
     
     
      if(iClose(_Symbol,PERIOD_CURRENT,1) < iOpen(_Symbol,PERIOD_CURRENT,1) &&  closedPartialOnNegativeDirection == false){ // if the m30 candle closed bearish
         closePartialsOfAllTrades(0.5);
         closedPartialOnNegativeDirection = true ;
      }
      
     
      buyStopValid = false ;
      waitingForBottomWickToForm = false ;
      bool finishedDeleting = false ;
      MqlDateTime mqldt ;
      datetime currTime = TimeCurrent(mqldt);
      
      
      
      if(candleClosedBelowRetestZone(PERIOD_CURRENT)){
            temporaryRestestSupportZone.setType("TYPE_INVALID");
            deleteZoneGuiOnly("999");
            
      }

      if(zoneContainer.getNumberOfActiveZones() != 0)  // if there are zones found
        {
         if(marketObserver.candleClosedAboveResistanceByIndex(0,PERIOD_CURRENT))  // check if candle closed above the zone
           {

            
            datetime _leftEdgeRestestZone = iTime(_Symbol,PERIOD_CURRENT,4);
            datetime _rightEdgeRetestZone = D'2023.11.01 00:00:00';
            
           
            
            while(!finishedDeleting && zoneContainer.getNumberOfActiveZones() != 0) // this while is used in the case of a candle closing above more than 1 zone at once
              {
              /* temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(0).getHigherEdge());
               temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(0).getLowerEdge());
               temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
               temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
               temporaryRestestSupportZone.setId("999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
               temporaryRestestSupportZone.setTimeFrame("PERIOD_M30");
               temporaryRestestSupportZone.setType("TYPE_SUPPORT");
               deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId())); // delete the zone with the GUI */

               if(zoneContainer.getNumberOfActiveZones() != 0 && marketObserver.candleClosedAboveResistanceByIndex(0,PERIOD_CURRENT))
                 {
                  zoneContainer.getZoneByIndex(0).getHigherEdge();
                  temporaryRestestSupportZone.setHigherEdgePrice(zoneContainer.getZoneByIndex(0).getHigherEdge());
                  temporaryRestestSupportZone.setLowerEdgePrice(zoneContainer.getZoneByIndex(0).getLowerEdge());
                  temporaryRestestSupportZone.setLeftEdge(_leftEdgeRestestZone);
                  temporaryRestestSupportZone.setRightEdge(_rightEdgeRetestZone);
                  temporaryRestestSupportZone.setId("999"); // the + "t" stands for temporary and it is made to keep the zones id's unique
                  temporaryRestestSupportZone.setTimeFrame("PERIOD_M30");
                  temporaryRestestSupportZone.setType("TYPE_SUPPORT");
                  deleteZoneWithGUI((zoneContainer.getZoneByIndex(0).getId())); // delete the zone with the GUI
                 }
               else
                 {
                  finishedDeleting = true ;
                 }


              }
              
              

            int idAsInt = StringToInteger(temporaryRestestSupportZone.getId());


            if((mqldt.hour > 13 && mqldt.hour < 22) || (mqldt.hour > 3 && mqldt.hour < 7)  || (mqldt.hour > 8 && mqldt.hour < 12) )
              {


               double stopLossPrice = iLow(_Symbol,PERIOD_CURRENT,1);
               stopLossPrice = stopLossPrice -1;

               double secondChanceStopLossPrice = iLow(_Symbol,PERIOD_M15,1);
               secondChanceStopLossPrice = secondChanceStopLossPrice -1;

               if(!(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossPrice > stopLossLimit))  // enter only if the M30 previous candle satisfied the condition of the proper stop loss
                 {
                  //Print("Entered here 2!");
                  double lotsToEnter = lotSizeCalc.calculateLotSize(riskInDollars,stopLossPrice);
                  buyEntryMan.takeBuyTradeTiger(lotsToEnter,stopLossPrice,netTakeProfit);
                  closedPartialOnNegativeDirection = false ;
                  securedTenPips  = false ;
                 }
               else
                  if(!(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - secondChanceStopLossPrice > stopLossLimit)  &&  secondChanceStopLossPrice < temporaryRestestSupportZone.getLowerEdge() - 0.5)  // if the M30 candle failed , then try the M15 candle
                    {

                     if(allowSecondChanceStopLoss == true)
                       {

                        double lotsToEnter = lotSizeCalc.calculateLotSize(riskInDollars,secondChanceStopLossPrice);
                        buyEntryMan.takeBuyTradeTiger(lotsToEnter,secondChanceStopLossPrice,netTakeProfit);
                        closedPartialOnNegativeDirection = false ;
                        securedTenPips  = false ;

                       }


                    }

                  else  // both M30 and M15 candles closed too far from the zone, so im gonna wait for retracement , and support to be built on the zone, or a bottom wick to form
                    {

                     objectsManager.drawRectangleInStrategyTester(idAsInt,_leftEdgeRestestZone,_rightEdgeRetestZone,
                           temporaryRestestSupportZone.getHigherEdge(),temporaryRestestSupportZone.getLowerEdge(),clrGray);
                           
                           
                           waitingForBottomWickToForm = true ;
                           
                         
                    }

              }



           }

        }



      if(candleClosedBullish(PERIOD_M30,2) && candleClosedBearish(PERIOD_M30,1))
        {

         //  create a rectangle  with a unique name
         int currentIdCounter = zoneContainer.getZonesIdCounter();


         datetime _leftEdge = iTime(_Symbol,PERIOD_CURRENT,2);
         datetime _rightEdge = D'2023.11.01 00:00:00';
         double resistancePrice = iOpen(_Symbol,PERIOD_CURRENT,1);

         
         
         

         if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice >= rangeDistance))
           {

            Zone* newZone = new Zone() ;
            newZone.setHigherEdgePrice(resistancePrice + resistanceExtendAboveCandle);
            newZone.setLowerEdgePrice(resistancePrice);
            newZone.setLeftEdge(_leftEdge);
            newZone.setRightEdge(_rightEdge);
            newZone.setId(IntegerToString(currentIdCounter));
            newZone.setTimeFrame("PERIOD_M30");
            newZone.setType("TYPE_RESISTANCE");




            zoneContainer.addResistanceZoneTiger(newZone);
            zoneContainer.incrementZonesIdCounter();


            objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandle,resistancePrice,clrBeige);
            //Print("Number of active zones is: " + zoneContainer.getNumberOfActiveZones());
            //zoneContainer.printZonesSortedArray();
           }
           
           else if((zoneContainer.getNumberOfActiveZones() != 0) && (zoneContainer.getZoneByIndex(0).getLowerEdge() - resistancePrice < rangeDistance)){
               double currentHighEdge = resistancePrice + resistanceExtendAboveCandle ; // this is a high edge of a resistance, but its not considered as a zone, because it doesnt have clean range above
               double currentLowEdge  = resistancePrice;   // this is a low edge of a resistance, but its not considered as a zone, because it doesnt have clean range above
           
           }

         else
            if(zoneContainer.getNumberOfActiveZones() == 0)  // this means this is the first zone to add to the data strucutre
              {

               //Print("Entered here 2");
               Zone* newZone = new Zone() ;
               newZone.setHigherEdgePrice(resistancePrice + resistanceExtendAboveCandle);
               newZone.setLowerEdgePrice(resistancePrice);
               newZone.setLeftEdge(_leftEdge);
               newZone.setRightEdge(_rightEdge);
               newZone.setId(IntegerToString(currentIdCounter));
               newZone.setTimeFrame("PERIOD_M30");
               newZone.setType("TYPE_RESISTANCE");



               zoneContainer.addResistanceZoneTiger(newZone);
               zoneContainer.incrementZonesIdCounter();


               objectsManager.drawRectangleInStrategyTester(currentIdCounter,_leftEdge,_rightEdge,resistancePrice + resistanceExtendAboveCandle,resistancePrice,clrBeige);
               //zoneContainer.printZonesSortedArray();
              }



        }
        
        
        Print("Number of active zones is: " + zoneContainer.getNumberOfActiveZones());
        Print("Zones are : ");
        zoneContainer.printZonesSortedArray();
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
bool resistanceIsFound()
  {

//if()

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
void deleteZoneWithGUI(string _id)
  {


   zoneContainer.deleteZone(_id);

   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }

  }
  
  
  
  void deleteZoneGuiOnly(string _id)
  {


   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }

  }
//+------------------------------------------------------------------+


bool candleClosedBelowRetestZone(ENUM_TIMEFRAMES tf){


   double previousCandleClose = iClose(_Symbol,tf,1);
      
       if(previousCandleClose < temporaryRestestSupportZone.getLowerEdge() ){
            
            return true ;
       } 
       
       return false ;
}




void closePartialsOfAllTrades(double partial){
   for(int i =  PositionsTotal()-1 ; i>=0 ; i--){
      ulong posTicket  = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)){
         double positionVolum = PositionGetDouble(POSITION_VOLUME);
         double partialToClose = positionVolum * partial ;
         tradeTiger.PositionClosePartial(posTicket,NormalizeDouble(partialToClose,2));
      
      }
      else{
         Print("Failed to select position, Error: " + GetLastError());
      }
      
     
      
   }
}



void secureTenPips(double partial){
   
   for(int i =  PositionsTotal()-1 ; i>=0 ; i--){
      ulong posTicket  = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)){
         double positionVolume = PositionGetDouble(POSITION_VOLUME);
          
         if((SymbolInfoDouble(_Symbol, SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN)) > 1){
            double partialToClose = positionVolume * partial ; 
            tradeTiger.PositionClosePartial(posTicket,NormalizeDouble(partialToClose,2));
            securedTenPips = true ;
            Print("secured 10 pips");
            
         }
         
      
      }
      else{
         Print("Failed to select position, Error: " + GetLastError());
      }
      
     
      
   }

}