//+------------------------------------------------------------------+
//|                                                  ZoneScanner.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


// INPUT VARIABLES
input ENUM_TIMEFRAMES inputTimeFrameFractals ;



// FRACTAL VARIABLES INITIALIZATION

input int leftPeriod;
input int rightPeriod;
input int weekPeriodToInitialize;
input int initFractalsPeriod ;
int lowFractalIndex ;
int highFractalIndex ;




// GUI CLASSES INCLUDES
#include "GraphicalObjectsManager.mqh"
#include "ObjectConfirmationUnit.mqh"
#include "TempObjectAttributes.mqh"
#include "TempLineObjectAttributes.mqh"


// DATA STRUCTURE CLASSES INCLUDES
#include  "Zone.mqh"
#include  "ZoneContainer.mqh"
#include  "LowFractal.mqh"
#include  "HighFractal.mqh"
#include  "LowFractalContainer.mqh"
#include  "HighFractalContainer.mqh"


// ALGORITHM CLASSES INCLUDES

#include "NewCandleDetector.mqh"
#include  "MarketObserver.mqh"


// TRADE RELATED CLASSES INCLUDES
#include "BuyEntryManager.mqh"
#include "SellEntryManager.mqh"
#include "BuyTradeManager.mqh"
#include "SellTradeManager.mqh"

// LIBRARIES INCLUDES
#include  <library_functions.mqh>


// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();
ObjectConfirmationUnit* objectConfUnit = new ObjectConfirmationUnit();
TempObjectAttributes* tempObjectAttr = new TempObjectAttributes();
TempLineObjectAttributes* tempLineObjectAttr = new TempLineObjectAttributes();


// CONTAINERS INITIALIZATION
ZoneContainer zoneContainer ;
LowFractalContainer* lowsContainer = new LowFractalContainer(inputTimeFrameFractals) ;

HighFractalContainer* highsContainer = new HighFractalContainer(inputTimeFrameFractals) ;


// ALGORITHM CLASSES INITIALIZATION
 MarketObserver marketObserver = new MarketObserver();



// TRADE RELATED CLASSES INITIALIZATION
BuyEntryManager buyEntryManager = new BuyEntryManager();
BuyTradeManager buyTradeManager = new BuyTradeManager();

SellEntryManager sellEntryManager = new SellEntryManager();
SellTradeManager sellTradeManager = new SellTradeManager();


// GENERAL CHART VARIABLES INITIALIZATION
bool initialized = false ;
bool firstCandleAfterStart = true ;


// ENTRY VARIABLES
string entryZoneType ;
bool lookForBuy = false ;
bool lookForSell = false ;

// NEW CANDLE CLASSES INITIALIZATION

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/*NewCandleDetector* newCandleDetectorM1 = new NewCandleDetector("PERIOD_M1");
NewCandleDetector* newCandleDetectorM5 = new NewCandleDetector("PERIOD_M5");
NewCandleDetector* newCandleDetectorM15 = new NewCandleDetector("PERIOD_M15");
NewCandleDetector* newCandleDetectorM30 = new NewCandleDetector("PERIOD_M30");
NewCandleDetector* newCandleDetectorH1 = new NewCandleDetector("PERIOD_H1");
NewCandleDetector* newCandleDetectorH4 = new NewCandleDetector("PERIOD_H4");
NewCandleDetector* newCandleDetectorD1 = new NewCandleDetector("PERIOD_D1"); */



// LIVE FORMING FRACTALS HANDLER CLASS
NewCandleDetector* newCandleDetectorLive ;



// Trade MANAGING VARIABLES
bool priceInMiddle = true ;
bool buyOnWait = false ;
bool buyOnAction = false;
bool sellOnWait = false;
bool sellOnAction = false ;





//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//Print("the ask is: " +  SymbolInfoDouble(_Symbol, SYMBOL_ASK));

// THIS IS FOR SETTING THE NEW CANDLE DETECTOR TIMEFRAME FOR THE LIVE FRACTALS . (IN ORDER TO KNOW WHICH TIMEFRAME OF THE LIVE FRACTALS TO TAKE)

   if(inputTimeFrameFractals == PERIOD_M1)
     {

      newCandleDetectorLive = new NewCandleDetector("PERIOD_M1");

     }
   else
      if(inputTimeFrameFractals == PERIOD_M5)
        {

         newCandleDetectorLive = new NewCandleDetector("PERIOD_M5");
        }
      else
         if(inputTimeFrameFractals == PERIOD_M15)
           {
            newCandleDetectorLive = new NewCandleDetector("PERIOD_M15");

           }
         else
            if(inputTimeFrameFractals == PERIOD_M30)
              {

               newCandleDetectorLive = new NewCandleDetector("PERIOD_M30");
              }
            else
               if(inputTimeFrameFractals == PERIOD_H1)
                 {
                  newCandleDetectorLive = new NewCandleDetector("PERIOD_H1");

                 }
               else
                  if(inputTimeFrameFractals == PERIOD_H4)
                    {
                     newCandleDetectorLive = new NewCandleDetector("PERIOD_H4");

                    }
                  else
                     if(inputTimeFrameFractals == PERIOD_D1)
                       {
                        newCandleDetectorLive = new NewCandleDetector("PERIOD_D1");

                       }


   if(initialized == false)
     {
      Print("Shark Initialized successfully on " + Symbol());

      // ADD THE BUTTONS TO THE SCREEN
      objectsManager.addZoneButton();
      objectsManager.addConfirmButton();
      objectsManager.addDeleteButton();
      objectsManager.addExitExperAdvisorButton();
      objectsManager.addPrintFractalsButton();
      objectsManager.addPrintZonesButton();
      objectsManager.addStopLossButton();
      objectsManager.addTakeProfitButton();
      objectsManager.addSetTakeProfitButton();

      // INIT FRACTAL VARIABLES
      lowFractalIndex = rightPeriod+1 ; // this is used for the fractals
      highFractalIndex = rightPeriod+1; // this is used for the fractals
      initLowFractalsFromIndex(initFractalsPeriod,inputTimeFrameFractals);
      initHighFractalsFromIndex(initFractalsPeriod,inputTimeFrameFractals);

      // INITIALIZATION FLAG
      initialized = true ;


     }




//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   /*Print("Low Fractals:");
   lowsContainer.printLowFractals();
   Print(" ");
   Print("High Fractals:");
   highsContainer.printhighFractals();
   Print(" "); */









   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   if(newCandleDetectorLive.isNewCandle())
     {
      handleLowFractals(inputTimeFrameFractals); // scans low fractals that are forming and adds them to the container
      handleHighFractals(inputTimeFrameFractals); // scans high fractals that are forming and adds them to the container
     }
   
   
   
   
  /* if((priceInMiddle == true) && (buyOnAction == true)){ // THIS CASE MEANS WE ARE IN THE MIDDLE OF TWO ZONES , AND A BUY TRADE IS OPEN
         buyTradeManager.handleTrade(); // this is responsible for exiting and taking partials
         
         if(marketObserver.candleClosedBelowSupportZone(&zoneContainer) == true){
            buyTradeManager.closeTrade();
            
            buyOnAction = false ;
            
         }
         else if(marketObserver.zoneReached(&zoneContainer) == "TYPE_RESISTANCE"){
            // close the buy
            buyTradeManager.closeTrade();
            
            buyOnAction = false ;
            sellEntryManager.setLookingForSell(true) ;
         }
      
   } */
   
   /*else if((priceInMiddle == true) && (sellOnAction == true)){ // THIS CASE MEANS WE ARE IN THE MIDDLE OF TWO ZONES , AND A SELL TRADE IS OPEN
      sellTradeManager.handleTrade();// this is responsible for exiting and taking partials
      
      if(marketObserver.candleClosedAboveResistanceZone(&zoneContainer) == true){
         sellTradeManager.closeTrade();
         
         sellOnAction = false ;
      }
      else if(marketObserver.zoneReached(&zoneContainer) == "TYPE_SUPPORT"){
         // close the sell
         sellTradeManager.closeTrade();
         
         sellOnAction = false;
         buyEntryManager.setLookingForBuy(true) ;
         
      }
   
   } */
   
   
   
   
   
   if(priceInMiddle == true){ // THIS CASE MEANS WE ARE IN THE MIDDLE OF TWO ZONES , AND NO CURRENT TRADE IS OPEN
     if(marketObserver.reachedClosestSupportZone(&zoneContainer)){ // we reached a support zone so looking for buys
         Print("Reached a support zone ! i will inform you if a buy confiramtion happens ");
         priceInMiddle = false;
         buyEntryManager.setLookingForBuy(true) ;
         sellEntryManager.setLookingForSell(false);
         
         
      }
      else if(marketObserver.reachedClosestResistanceZone(&zoneContainer)){ // we reached resistance zone so  looking for sells
      Print("Reached a resistance zone ! i will inform you if a sell confirmation happens ");
      priceInMiddle = false; 
      sellEntryManager.setLookingForSell(true) ;
      buyEntryManager.setLookingForBuy(false) ;
      
      }
      else{ // we are still in the middle so do nothing
         
      }
      
   }
   
   
   
   
   /*if(buyEntryManager.isLookingForBuy() == true){
      if(marketObserver.candleClosedBelowSupportZone(&zoneContainer) == true){ // trade idea is invalid , so wait the user to confirm the break of the zone
         buyEntryManager.setLookingForBuy(false) ;
         
      }
      else if(buyEntryManager.buyTaken() == true ){
           priceInMiddle = true ; 
           buyOnAction = true ;
           buyEntryManager.setLookingForBuy(false) ; 
           
      }
      
      else if(marketObserver.reachedClosestResistanceZone() == true){
          
          buyEntryManager.setLookingForBuy(false);
      }
   } */
   
   
   
   /*if(sellEntryManager.isLookingForSell() == true){
      if(marketObserver.candleClosedAboveResistanceZone(&zoneContainer) == true){
         sellEntryManager.setLookingForSell(false);
      }
      else if(sellEntryManager.sellTaken() == true){
         priceInMiddle = true ;
         sellOnAction = true ;
         sellEntryManager.setLookingForSell(false) ;
         
      }
   } */




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
//--- left-clicking on a chart

   switch(id)
     {

      case CHARTEVENT_CLICK:
        {

         break;
        }




      //--- clicking on a graphical object
      case CHARTEVENT_OBJECT_CLICK:
        {
         if(sparam == "ZONE_ADD_BTN")
           {

            if(objectConfUnit.getWaitingStatus() == false)  // THIS IS TO MAKE SURE THERE IS NO OTHER OBJECT SELECTED
              {

               //  create a rectangle  with a unique name
               int currentIdCounter = zoneContainer.getZonesIdCounter();
               objectsManager.drawRectangle(currentIdCounter); // create a rectangle . set its name to be the current zonesIdCounter (and that would be the id of this current zone )
               objectConfUnit.setWaitingStatus(true);
               objectConfUnit.setObjectType("OBJ_RECTANGLE");
               objectConfUnit.setConfirmationObjectId(currentIdCounter);
               zoneContainer.incrementZonesIdCounter();



              }
            else
              {

               Print("Failed to Add a new Object, Make sure to confirm the previous object first! .");
              }



           }

         else
            if(sparam == "ADD_SL_BTN")
              {
               if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS A ZONE SELECTED TO ADD STOP LOSS TO
                 {

                  if(objectConfUnit.getObjectType() != "OBJ_RECTANGLE")
                    {
                     Print("Please select a zone object only !");
                    }
                  else
                    {

                     objectsManager.drawStopLossLine(objectConfUnit.getConfirmationObjectId());
                    }

                 }
               else
                 {

                  Print("Please select a zone in order to add a stop loss line !");
                 }


              }
            else
               if(sparam == "ADD_TP_BTN")
                 {

                  if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS A ZONE SELECTED TO ADD STOP LOSS TO
                    {

                     if(objectConfUnit.getObjectType() != "OBJ_RECTANGLE")
                       {
                        Print("Please select a zone object only !");
                       }
                     else
                       {

                        objectsManager.drawTakeProfitLine(objectConfUnit.getConfirmationObjectId());
                       }

                    }
                  else
                    {

                     Print("Please select a zone in order to add a stop loss line !");
                    }

                 }
               else
                  if(sparam == "CONFIRM_BTN")
                    {

                     if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS SOMETHING SELECTED TO BE CONFIRMED
                       {


                        if(objectConfUnit.getObjectType() == "OBJ_RECTANGLE")   // CASE OF ZONE
                          {

                           if(zoneContainer.getZoneIndex(objectConfUnit.getConfirmationObjectId()) != -1)  // means the zone already in the data structure, in this case we just need to update it
                             {

                              // update the zone attributes
                              // zoneContainer.UpdateZone(int id);
                              Zone* tempZone = new Zone();

                              tempZone.setHigherEdgePrice(tempObjectAttr.getHigherEdgePrice()) ;
                              tempZone.setLowerEdgePrice(tempObjectAttr.getLowerEdgePrice());
                              tempZone.setLeftEdge(tempObjectAttr.getLeftEdgeTime());
                              tempZone.setRightEdge(tempObjectAttr.getRightEdgeTime());
                              tempZone.setTimeFrame(tempObjectAttr.getTimeFrame());

                              string idOfOriginalZone = objectConfUnit.getConfirmationObjectId();
                              // no need to set the ID here because the ID belongs to the original zone and not this new temp one (this is just a temporary zone to check if the adjustment is valid or no)

                              if(zoneContainer.updateZone(tempZone, idOfOriginalZone) ==1)
                                {
                                 // in this case we successfully updated the zone

                                 Print("Updated the object:" +
                                       "\n ID: " + objectConfUnit.getConfirmationObjectId() +
                                       "\n Type: " + objectConfUnit.getObjectType() +
                                       "\n Asset: " +  tempObjectAttr.getSymbol() +
                                       "\n Time Frame:" + tempObjectAttr.getTimeFrame() +
                                       "\n Higher Edge Price: " + tempObjectAttr.getHigherEdgePrice() +
                                       "\n Lower Edge Price: " + tempObjectAttr.getLowerEdgePrice() +
                                       "\n Left Edge Date: " + tempObjectAttr.getLeftEdgeTime() +
                                       "\n Right Edge Date: " + tempObjectAttr.getRightEdgeTime()
                                      );

                                 delete tempZone;
                                 if(ObjectSetInteger(_Symbol,objectConfUnit.getConfirmationObjectId(),OBJPROP_SELECTED,false) == true)  // this is to unselect the object once we finish using it
                                   {
                                   }
                                 else
                                   {
                                    Print("Failed to unselect the object. Error: " + GetLastError());
                                   }

                                 // THIS IS TO CLEAN THE objectConfUnit
                                 objectConfUnit.setWaitingStatus(false);
                                 ChartRedraw();
                                }
                              else
                                {

                                 Print("Failed to update the zone, please reposition it");
                                }

                             }

                           else   // means the zone is new so we need to add it
                             {
                              Zone* newZone = new Zone() ;
                              newZone.setHigherEdgePrice(tempObjectAttr.getHigherEdgePrice());
                              newZone.setLowerEdgePrice(tempObjectAttr.getLowerEdgePrice());
                              newZone.setLeftEdge(tempObjectAttr.getLeftEdgeTime());
                              newZone.setRightEdge(tempObjectAttr.getRightEdgeTime());
                              newZone.setId(objectConfUnit.getConfirmationObjectId());
                              newZone.setTimeFrame(tempObjectAttr.getTimeFrame());
                              if(tempObjectAttr.getHigherEdgePrice() < SymbolInfoDouble(_Symbol, SYMBOL_ASK))   // means its a support zone
                                {
                                 newZone.setType("TYPE_SUPPORT");
                                }
                              if(tempObjectAttr.getLowerEdgePrice() >  SymbolInfoDouble(_Symbol, SYMBOL_ASK))  // means its a resistance zone
                                {
                                 newZone.setType("TYPE_RESISTANCE");
                                }
                              // add the zone to the data structure
                              if(zoneContainer.addZone(newZone) == 1)
                                {
                                 zoneContainer.findOrUpdatePivotEdges(); // update the pivot edges
                                 Print("Added the object:" +
                                       "\n ID: " + objectConfUnit.getConfirmationObjectId() +
                                       "\n Type: " + objectConfUnit.getObjectType() +
                                       "\n Asset: " +  tempObjectAttr.getSymbol() +
                                       "\n Time Frame:" + tempObjectAttr.getTimeFrame() +
                                       "\n Higher Edge Price: " + tempObjectAttr.getHigherEdgePrice() +
                                       "\n Lower Edge Price: " + tempObjectAttr.getLowerEdgePrice() +
                                       "\n Left Edge Date: " + tempObjectAttr.getLeftEdgeTime() +
                                       "\n Right Edge Date: " + tempObjectAttr.getRightEdgeTime()
                                      );



                                 if(ObjectSetInteger(_Symbol,objectConfUnit.getConfirmationObjectId(),OBJPROP_SELECTED,false) == true)  // this is to unselect the object once we finish using it
                                   {
                                   }
                                 else
                                   {
                                    Print("Failed to unselect the object. Error: " + GetLastError());
                                   }

                                 // THIS IS TO CLEAN THE objectConfUnit
                                 objectConfUnit.setWaitingStatus(false);
                                }
                              else
                                {
                                 Print("Failed to add the zone, Error: 2 or more zones are crossing");
                                }

                              ChartRedraw();
                             }





                          }

                        else
                           if(objectConfUnit.getObjectType() == "OBJ_TRENDLINE")  // CASE OF TRENDLINE
                             {




                             }
                           else
                              if(objectConfUnit.getObjectType() == "OBJ_HLINE")  // CASE OF HORIZNOTAL LINE
                                {

                                 if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "sl")
                                   {

                                    zoneContainer.searchZoneById(StringSubstr(tempLineObjectAttr.getId(),2,-1)).setStopLossPrice(tempLineObjectAttr.getPrice());
                                    Print("Stop loss for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                    if(ObjectDelete(_Symbol,tempLineObjectAttr.getId()))
                                      {

                                      }
                                    else
                                      {
                                       Print("Failed to delete the stop loss line ! Error: "+ GetLastError());
                                      }

                                    // THIS IS TO CLEAN THE objectConfUnit
                                    objectConfUnit.setWaitingStatus(false);


                                   }
                                 else
                                    if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "tp")
                                      {

                                       
                                       if(ObjectDelete(_Symbol,tempLineObjectAttr.getId()))
                                         {

                                         }
                                       else
                                         {
                                          Print("Failed to delete the stop loss line ! Error: "+ GetLastError());
                                         }

                                       // THIS IS TO CLEAN THE objectConfUnit
                                       objectConfUnit.setWaitingStatus(false);

                                      }
                                    else
                                       if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "rl")
                                         {

                                          Print("Relational level line for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());


                                         }
                                       else
                                          if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "dl")
                                            {

                                             Print("Daily indecision line for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());


                                            }
                                          else
                                             if(StringSubstr(tempLineObjectAttr.getId(),0,3) == "bos")
                                               {

                                                Print("Break of structure line for zone: " + StringSubstr(tempLineObjectAttr.getId(),3,-1) + " has been set at: " + tempLineObjectAttr.getPrice());


                                               }

                                }



                       }
                     else
                       {

                        Print("Cannot confirm, Please select an object first !");
                       }

                    }

                  else
                     if(sparam == "DELETE_BTN")
                       {
                        if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS SOMETHING SELECTED TO BE DELETED
                          {
                           if(ObjectDelete(_Symbol,objectConfUnit.getConfirmationObjectId()))
                             {
                              if(zoneContainer.deleteZone(objectConfUnit.getConfirmationObjectId()) == 1)
                                {
                                 // delete from data structure
                                 zoneContainer.findOrUpdatePivotEdges();
                                 Print("Deleted the object: " +
                                       "\n Type: " + objectConfUnit.getObjectType() +
                                       "\n ID: " + objectConfUnit.getConfirmationObjectId());

                                 objectConfUnit.setWaitingStatus(false);
                                 objectConfUnit.setObjectType("NO_OBJECT");
                                 objectConfUnit.setConfirmationObjectId(-2);

                                 ChartRedraw();
                                }
                              else
                                {
                                 objectConfUnit.setWaitingStatus(false);
                                 objectConfUnit.setObjectType("NO_OBJECT");
                                 objectConfUnit.setConfirmationObjectId(-2);
                                }
                             }

                          }
                        else
                          {

                           Print("Cannot delete, Please select an object first !");
                          }

                       }
                     else
                        if(sparam == "EXIT_BTN")
                          {
                           delete objectsManager ;
                           delete objectConfUnit;
                           delete tempObjectAttr;
                           delete lowsContainer;
                           delete highsContainer;

                           delete newCandleDetectorLive;
                           zoneContainer.freeZonesSortedArray();
                           /*delete newCandleDetectorD1;
                           delete newCandleDetectorM5;
                           delete newCandleDetectorM30;
                           delete newCandleDetectorM15;
                           delete newCandleDetectorM1;
                           delete newCandleDetectorH4;
                           delete newCandleDetectorH1; */





                           ExpertRemove();
                          }
                        else
                           if(sparam == "PRINT_FRACTAL_BTN")
                             {
                              Print("Low Fractals:");
                              lowsContainer.printLowFractals();
                              Print("High Fractals:");
                              highsContainer.printHighFractals();
                             }

                           else
                              if(sparam == "PRINT_ZONES_BTN")
                                {

                                 zoneContainer.printZonesSortedArray();
                                }
                                
                            else if(sparam == "SET_TP_BTN"){
                              if(objectConfUnit.getObjectType() != "OBJ_HLINE"){
                                 Print("Please select a TP line first !");
                              
                              }
                              else{
                                 if(zoneContainer.searchZoneById(StringSubstr(tempLineObjectAttr.getId(),2,-1)).setTakeProfit(tempLineObjectAttr.getPrice())){
                                       Print("TP for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                 }
                                 else{
                                       Print("You have reached the max take profit lines !");
                                 }
                                 
                              }
                              
                            
                            }
                              else   // THIS is the case were we click on any object except for main Buttons on screen
                                {

                                 if(objectConfUnit.getWaitingStatus() == true)  //  THIS IS TO MAKE SURE THERE IS NO OTHER OBJECT SELECTED
                                   {
                                    Print("Cannot select the object clicked, Make sure to confirm a previous selected object first !");
                                   }


                                 else
                                   {
                                    ObjectSetInteger(_Symbol,sparam,OBJPROP_SELECTED,true);

                                    if(ObjectGetInteger(_Symbol,sparam,OBJPROP_TYPE,0) == OBJ_RECTANGLE) // CASE OF SELECTING A RECTANGLE
                                      {
                                       Print("Selected the object:" +
                                             "\n Type:  OBJ_RECTANGLE" +
                                             "\n ID: " + sparam);
                                       objectConfUnit.setWaitingStatus(true) ;
                                       objectConfUnit.setConfirmationObjectId(StringToInteger(sparam));
                                       objectConfUnit.setObjectType("OBJ_RECTANGLE");

                                       double _higherEdgePrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,1);
                                       double _lowerEdgePrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,0);
                                       datetime _leftEdgeTime = (datetime)ObjectGetInteger(_Symbol,sparam,OBJPROP_TIME,0);
                                       datetime _rightEdgeTime = (datetime)ObjectGetInteger(_Symbol,sparam,OBJPROP_TIME,1);

                                       tempObjectAttr.setHigherEdgePrice(_higherEdgePrice);
                                       tempObjectAttr.setLowerEdgePrice(_lowerEdgePrice);

                                       tempObjectAttr.setLeftEdgeTime(_leftEdgeTime);
                                       tempObjectAttr.setRightEdgeTime(_rightEdgeTime);
                                       tempObjectAttr.setSymbol();
                                       tempObjectAttr.setTimeFrame(getChartTimeFrameInString());
                                       ChartRedraw();
                                      }


                                    else
                                       if(ObjectGetInteger(_Symbol,sparam,OBJPROP_TYPE,0) == OBJ_HLINE) // CASE OF SELECTING A HORIZONTAL LINE
                                         {

                                          objectConfUnit.setWaitingStatus(true) ;
                                          objectConfUnit.setConfirmationObjectId(StringToInteger(sparam));
                                          objectConfUnit.setObjectType("OBJ_HLINE");
                                          
                                          //tempLineObjectAttr.setId(sparam);
                                          //tempLineObjectAttr.setPrice( ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,0));
                                          ChartRedraw();
                                         }





                                   }

                                }


         break;
        }


      //--- object moved or anchor point coordinates changed
      case CHARTEVENT_OBJECT_DRAG:
        {

         if(ObjectGetInteger(_Symbol,sparam,OBJPROP_TYPE,0) == OBJ_RECTANGLE)
           {


            double _higherEdgePrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,1);
            double _lowerEdgePrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,0);

            datetime _leftEdgeTime = (datetime)ObjectGetInteger(_Symbol,sparam,OBJPROP_TIME,0);
            datetime _rightEdgeTime = (datetime)ObjectGetInteger(_Symbol,sparam,OBJPROP_TIME,1);

            if(_higherEdgePrice < _lowerEdgePrice)  // this is the case were the user flips the rectangle while adjusting it.
              {
               tempObjectAttr.setHigherEdgePrice(_lowerEdgePrice);
               tempObjectAttr.setLowerEdgePrice(_higherEdgePrice);
              }
            else
              {
               tempObjectAttr.setHigherEdgePrice(_higherEdgePrice);
               tempObjectAttr.setLowerEdgePrice(_lowerEdgePrice);
              }

            tempObjectAttr.setLeftEdgeTime(_leftEdgeTime);
            tempObjectAttr.setRightEdgeTime(_rightEdgeTime);
            tempObjectAttr.setSymbol();
            tempObjectAttr.setTimeFrame(getChartTimeFrameInString());
            break;
           }

         else
            if(ObjectGetInteger(_Symbol,sparam,OBJPROP_TYPE,0) == OBJ_HLINE)
              {

               if(StringSubstr(sparam,0,2) == "sl")   // case of sl line (attached to a zone)
                 {
                  double stopLossPrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,0);
                  tempLineObjectAttr.setId(sparam);
                  tempLineObjectAttr.setPrice(stopLossPrice);
                 }
               else
                  if(StringSubstr(sparam,0,2) == "tp")  // case of tp line (attached to a zone)
                    {
                     double takeProfitPrice = ObjectGetDouble(_Symbol,sparam,OBJPROP_PRICE,0);
                     tempLineObjectAttr.setId(sparam);
                     tempLineObjectAttr.setPrice(takeProfitPrice);
                    }
                  else
                     if(StringSubstr(sparam,0,2) == "rl")  // case of relational point line (attached to a zone)
                       {
                        Print("dragging a relational point line");
                       }
                     else
                        if(StringSubstr(sparam,0,2) == "dl")  // case of daily line
                          {
                           Print("dragging a daily line");
                          }
                        else
                           if(StringSubstr(sparam,0,3) == "bos")  // case of break of structure line
                             {
                              Print("dragging a break of structure line");
                             }

              }
        }
     }

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
void initLowFractalsFromIndex(int _index,ENUM_TIMEFRAMES timeFramePeriod)
  {

   for(int i=_index ; i> rightPeriod  ; i--)
     {

      bool accessDeniedLows = false ; // variable for dealing with equal consecutive fractals



      if(isLowFractalByIndex(i,leftPeriod,rightPeriod,timeFramePeriod) == true)
        {

         if(lowsContainer.getFreeIndex() > 0)
           {

            if(iLow(Symbol(),timeFramePeriod,i) == lowsContainer.getLowFractal(lowsContainer.getFreeIndex()-1).getPrice())  // if low fractal is equal to the previous low fractal
              {
               if(lowsContainer.getLowFractal(lowsContainer.getFreeIndex()-1).getDistance() - i < 2*rightPeriod) // if the 2 lows are inside the range of 2 times of right period
                 {
                  accessDeniedLows = true ;
                 }

              }
           }

         if(accessDeniedLows == false)
           {


            LowFractal* currentFractal = new LowFractal(iLow(Symbol(),timeFramePeriod,i),leftPeriod,rightPeriod,TimeCurrent(),timeFramePeriod);
            currentFractal.setDate(iTime(Symbol(),timeFramePeriod,i));
            currentFractal.setDistance(i);
            int NumberOfCandle = i-1;
            string NumberOfCandleText = IntegerToString(NumberOfCandle);
            currentFractal.setArrowObjName(NumberOfCandleText);
            lowsContainer.addLowFractal(currentFractal);

           }


        }

     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initHighFractalsFromIndex(int _index,ENUM_TIMEFRAMES timeFramePeriod)
  {

   for(int i=_index ; i> rightPeriod  ; i--)
     {

      bool accessDeniedHighs = false ; // variable for dealing with equal consecutive fractals



      if(isHighFractalByIndex(i,leftPeriod,rightPeriod,timeFramePeriod) == true)
        {

         if(highsContainer.getFreeIndex() > 0)
           {

            if(iHigh(Symbol(),timeFramePeriod,i) == highsContainer.getHighFractal(highsContainer.getFreeIndex()-1).getPrice())  // if high fractal is equal to the previous high fractal
              {

               if(highsContainer.getHighFractal(highsContainer.getFreeIndex()-1).getDistance() - i < 2*rightPeriod) // if the 2 highs are inside the range of 2 times of right period
                 {

                  accessDeniedHighs = true ;
                 }

              }
           }

         if(accessDeniedHighs == false)
           {


            HighFractal* currentFractal = new HighFractal(iHigh(Symbol(),timeFramePeriod,i),leftPeriod,rightPeriod,TimeCurrent(),timeFramePeriod);
            currentFractal.setDate(iTime(Symbol(),timeFramePeriod,i));
            currentFractal.setDistance(i);
            int NumberOfCandle = i-1;
            string NumberOfCandleText = IntegerToString(NumberOfCandle);
            currentFractal.setArrowObjName(NumberOfCandleText);
            highsContainer.addHighFractal(currentFractal);

           }


        }

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleLowFractals(ENUM_TIMEFRAMES tf)
  {

   bool accessDeniedLows = false ; // variable for dealing with equal consecutive fractals if its true, then the current fractal will not be added

   for(int x=0 ; x<lowsContainer.getFreeIndex(); x++)
     {

      lowsContainer.getLowFractal(x).updateDistance(); // update the distance for every fractal in the  container

     }


   if(isLowFractalByIndex(lowFractalIndex,leftPeriod,rightPeriod,tf) == true)
     {

      if(lowsContainer.getFreeIndex() > 0)
        {

         if(iLow(Symbol(),tf,lowFractalIndex) == lowsContainer.getLowFractal(lowsContainer.getFreeIndex()-1).getPrice())  // if low fractal is equal to the previous low fractal
           {

            if(lowsContainer.getLowFractal(lowsContainer.getFreeIndex()-1).getDistance() <= 2*rightPeriod) // if the 2 lows are inside the range of 2 times of right period
              {

               accessDeniedLows = true ;
              }

           }
        }

      if(accessDeniedLows == false)
        {

         LowFractal* currentFractal = new LowFractal(iLow(Symbol(),tf,lowFractalIndex),leftPeriod,rightPeriod,TimeCurrent(),tf);

         int NumberOfCandle = Bars(Symbol(),tf);
         string NumberOfCandleText = IntegerToString(NumberOfCandle);
         currentFractal.setArrowObjName(NumberOfCandleText);
         lowsContainer.addLowFractal(currentFractal);
         Print("added a new low fractal !");

        }


     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleHighFractals(ENUM_TIMEFRAMES tf)
  {


   bool accessDeniedHighs = false ; // variable for dealing with equal consecutive fractals

   for(int x=0 ; x<highsContainer.getFreeIndex(); x++)
     {

      highsContainer.getHighFractal(x).updateDistance(); // update the distance for every fractal in the  container

     }


   if(isHighFractalByIndex(highFractalIndex,leftPeriod,rightPeriod,tf) == true)
     {

      if(highsContainer.getFreeIndex() > 0)
        {

         if(iHigh(Symbol(),tf,highFractalIndex) == highsContainer.getHighFractal(highsContainer.getFreeIndex()-1).getPrice())  // if high fractal is equal to the previous high fractal
           {
            if(highsContainer.getHighFractal(highsContainer.getFreeIndex()-1).getDistance() <= 2*rightPeriod) // if the 2 highs are inside the range of 2 times of right period
              {
               accessDeniedHighs = true ;
              }

           }
        }

      if(accessDeniedHighs == false)
        {


         HighFractal* currentFractal = new HighFractal(iHigh(Symbol(),tf,highFractalIndex),leftPeriod,rightPeriod,TimeCurrent(),tf);

         int NumberOfCandle = Bars(Symbol(),tf);
         string NumberOfCandleText = IntegerToString(NumberOfCandle);
         currentFractal.setArrowObjName(NumberOfCandleText);
         highsContainer.addHighFractal(currentFractal);
         Print("added a new high fractal !");
        }


     }


  }



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
