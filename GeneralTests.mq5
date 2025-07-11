//+------------------------------------------------------------------+
//|                                                  ZoneScanner.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


// INPUT VARIABLES
//input ENUM_TIMEFRAMES inputTimeFrameFractals ;



// FRACTALS DATA

//input int leftPeriod;
//input int rightPeriod;
//input int weekPeriodToInitialize;
//input int initFractalsPeriod ;
//int lowFractalIndex ;
//int highFractalIndex ;
//#include  "LowFractal.mqh"
//#include  "HighFractal.mqh"
//#include  "LowFractalContainer.mqh"
//#include  "HighFractalContainer.mqh"



#property script_show_inputs

input datetime InpStartTime = __DATETIME__;
input bool REJECTION_M1_ONLY ;

// GUI CLASSES INCLUDES
#include "GraphicalObjectsManager.mqh"
#include "ObjectConfirmationUnit.mqh"
#include "TempObjectAttributes.mqh"
#include "TempLineObjectAttributes.mqh"


// DATA STRUCTURE CLASSES INCLUDES
#include  "Zone.mqh"
#include  "ZoneContainer.mqh"



// ALGORITHM CLASSES INCLUDES

#include "NewCandleDetector.mqh"
#include  "MarketObserver.mqh"
#include  "LotSizeCalculator.mqh"


// TRADE RELATED CLASSES INCLUDES
#include "BuyEntryManager.mqh"
#include "SellEntryManager.mqh"
#include "BuyTradeManager.mqh"
#include "SellTradeManager.mqh"

// LIBRARIES INCLUDES
#include  <library_functions.mqh>

// Telegram Connection  include
#include <Telegram_Handler.mqh>

// SCRIPTS INCLUDES




// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();
ObjectConfirmationUnit* objectConfUnit = new ObjectConfirmationUnit();
TempObjectAttributes* tempObjectAttr = new TempObjectAttributes();
TempLineObjectAttributes* tempLineObjectAttr = new TempLineObjectAttributes();


// CONTAINERS INITIALIZATION
ZoneContainer* zoneContainer = new ZoneContainer() ;
//LowFractalContainer* lowsContainer = new LowFractalContainer(inputTimeFrameFractals) ;

//HighFractalContainer* highsContainer = new HighFractalContainer(inputTimeFrameFractals) ;


// ALGORITHM CLASSES INITIALIZATION
MarketObserver* marketObserver = new MarketObserver(zoneContainer);
LotSizeCalculator lotSizeCalculator ;



// GENERAL CHART VARIABLES INITIALIZATION
bool initialized = false ;
bool firstCandleAfterStart = true ;


// ENTRY VARIABLES
string entryZoneType ;
bool lookForBuy = false ;
bool lookForSell = false ;


// LIVE FORMING FRACTALS HANDLER CLASS
NewCandleDetector* newCandleDetectorLive ;


// NEW CANDLE CLASSES INITIALIZATION
NewCandleDetector* newCandleDetector_H4;
NewCandleDetector* newCandleDetector_H1;
NewCandleDetector* newCandleDetector_M30;
NewCandleDetector* newCandleDetector_M15;
NewCandleDetector* newCandleDetector_M5;
NewCandleDetector* newCandleDetector_M1;



// Trade MANAGING VARIABLES
bool priceInMiddle = true ;
bool buyOnWait = false ;
bool buyOnAction = false;
bool sellOnWait = false;
bool sellOnAction = false ;

bool telegramTested = false ;
input bool testTelegram ;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
// Added because bmp files seem to have stopped working, possibly a file format issue
//fileType = "png";
//fileName = "MyScreenshot." + fileType;


   if(telegramTested == false && testTelegram == true)
     {
      ChartRedraw(); // Make sure the chart is up to date
      ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
      SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"This is just a test ! " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
      telegramTested = true ;
     }


// THIS IS FOR SETTING THE NEW CANDLE DETECTOR TIMEFRAME FOR THE LIVE FRACTALS . (IN ORDER TO KNOW WHICH TIMEFRAME OF THE LIVE FRACTALS TO TAKE)





   /* if(inputTimeFrameFractals == PERIOD_M1)
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

                        } */


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

      //lowFractalIndex = rightPeriod+1 ; // this is used for the fractals
      //highFractalIndex = rightPeriod+1; // this is used for the fractals
      //initLowFractalsFromIndex(initFractalsPeriod,inputTimeFrameFractals);
      //initHighFractalsFromIndex(initFractalsPeriod,inputTimeFrameFractals);

      // INITIALIZATION FLAG


      newCandleDetector_H4 = new NewCandleDetector("PERIOD_H4");
      newCandleDetector_H1 = new NewCandleDetector("PERIOD_H1");
      newCandleDetector_M30 = new NewCandleDetector("PERIOD_M30");
      newCandleDetector_M15 = new NewCandleDetector("PERIOD_M15");
      newCandleDetector_M5 = new NewCandleDetector("PERIOD_M5");
      newCandleDetector_M1 = new NewCandleDetector("PERIOD_M1");

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


   if(!IsTradeAllowed())
     {

      return ;
     }

   if(!IsMarketOpen2(Symbol(),TimeCurrent()))
     {

      return ;
     }



   if((marketObserver.getClosestResistanceZone() != NULL) && (marketObserver.getClosestResistanceZone().sellEntryManager.sellTradeTaken()))
     {
      marketObserver.getClosestResistanceZone().sellTradeManager.checkAndSecureTradeIfNeeded(firstSecureRatio,riskDollars);
     }

   if((marketObserver.getClosestSupportZone() != NULL) && (marketObserver.getClosestSupportZone().buyEntryManager.buyTradeTaken()))
     {
      marketObserver.getClosestSupportZone().buyTradeManager.checkAndSecureTradeIfNeeded(firstSecureRatio,riskDollars);
     }




   /*if(newCandleDetector_M1.isNewCandle())
     {


      handleBuys(PERIOD_M1);
      handleSells(PERIOD_M1);
     }*/


   if(REJECTION_M1_ONLY == true)
     {
      if(newCandleDetector_M1.isNewCandle())
        {

         /* ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
          SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"this is just a test " + _Symbol  + " "  + TimeToString(TimeLocal()), fileName); */
          Print("Im in new candle !");
         handleBuys(PERIOD_M1);
         handleSells(PERIOD_M1);
        }
     }
   else
     {

      if(newCandleDetector_H1.isNewCandle())
        {

         /* ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
          SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"this is just a test " + _Symbol  + " "  + TimeToString(TimeLocal()), fileName); */
         handleBuys(PERIOD_H1);
         handleSells(PERIOD_H1);
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


                              double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK) ;
                              double higherEdge = tempObjectAttr.getHigherEdgePrice();

                              Print("higher edge is: " + higherEdge + " ask is: " + ask);
                              if(tempObjectAttr.getHigherEdgePrice() < ask)   // means its a support zone
                                {
                                 newZone.setType("TYPE_SUPPORT");
                                }


                              double bid =   SymbolInfoDouble(_Symbol, SYMBOL_BID);
                              double lowerEdge = tempObjectAttr.getLowerEdgePrice();
                              Print("lower edge is: "+lowerEdge + " bidd i: " + bid);
                              if(tempObjectAttr.getLowerEdgePrice() >  bid)  // means its a resistance zone
                                {

                                 newZone.setType("TYPE_RESISTANCE");
                                }
                              // add the zone to the data structure
                              if(zoneContainer.addZone(newZone) == 1)
                                {
                                 zoneContainer.findOrUpdatePivotEdgesOnConfirm(ask,bid); // update the pivot edges
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

                                    ChartRedraw();
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
                                       ChartRedraw();
                                      }
                                    else
                                       if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "rl")
                                         {

                                          Print("Relational level line for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                          ChartRedraw();

                                         }
                                       else
                                          if(StringSubstr(tempLineObjectAttr.getId(),0,2) == "dl")
                                            {

                                             Print("Daily indecision line for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                             ChartRedraw();

                                            }
                                          else
                                             if(StringSubstr(tempLineObjectAttr.getId(),0,3) == "bos")
                                               {

                                                Print("Break of structure line for zone: " + StringSubstr(tempLineObjectAttr.getId(),3,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                                ChartRedraw();

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
                                 zoneContainer.findOrUpdatePivotEdgesOnDelete();
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
                           //delete lowsContainer;
                           //delete highsContainer;

                           delete newCandleDetectorLive;
                           delete tempLineObjectAttr;
                           delete marketObserver;


                           zoneContainer.freeZonesSortedArray();
                           delete zoneContainer ;

                           delete newCandleDetector_H4;
                           delete newCandleDetector_H1;
                           delete newCandleDetector_M30;
                           delete newCandleDetector_M15;
                           delete newCandleDetector_M5 ;
                           delete newCandleDetector_M1;






                           ExpertRemove();
                          }
                        else
                           if(sparam == "PRINT_FRACTAL_BTN")
                             {
                              Print("Low Fractals:");
                              //lowsContainer.printLowFractals();
                              Print("High Fractals:");
                              //highsContainer.printHighFractals();
                             }

                           else
                              if(sparam == "PRINT_ZONES_BTN")
                                {

                                 zoneContainer.printZonesSortedArray();
                                }

                              else
                                 if(sparam == "SET_TP_BTN")
                                   {
                                    if(objectConfUnit.getObjectType() != "OBJ_HLINE")
                                      {
                                       Print("Please select a TP line first !");

                                      }
                                    else
                                      {
                                       if(zoneContainer.searchZoneById(StringSubstr(tempLineObjectAttr.getId(),2,-1)).setTakeProfit(tempLineObjectAttr.getPrice()))
                                         {
                                          Print("TP for zone: " + StringSubstr(tempLineObjectAttr.getId(),2,-1) + " has been set at: " + tempLineObjectAttr.getPrice());
                                         }
                                       else
                                         {
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


/*void initLowFractalsFromIndex(int _index,ENUM_TIMEFRAMES timeFramePeriod)
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


  } */


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/*void initHighFractalsFromIndex(int _index,ENUM_TIMEFRAMES timeFramePeriod)
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

  } */


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


/*void handleLowFractals(ENUM_TIMEFRAMES tf)
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

  } */


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


/*void handleHighFractals(ENUM_TIMEFRAMES tf)
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


  } */


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MarketTest(string symbol, datetime testTime)
  {

   return symbol + " " + TimeToString(testTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + " " + IsMarketOpen(symbol, testTime) + " " + IsMarketOpen2(symbol, testTime);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {

   return ((bool)MQLInfoInteger(MQL_TRADE_ALLOWED)                   // Trading allowed in input dialog
           && (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)     // Trading allowed in terminal
           && (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)       // Is account able to trade, not locked out
           && (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT)        // Is account able to auto trade
          );
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpen(string symbol, datetime time)
  {

   MqlDateTime mtime;
   TimeToStruct(time, mtime);
   datetime seconds = mtime.hour*3600+mtime.min*60+mtime.sec;

   datetime fromTime;
   datetime toTime;

   for(int session = 0;; session++)
     {
      if(!SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)mtime.day_of_week, session, fromTime, toTime))
         return false;
      if(fromTime<=seconds && seconds<=toTime)
         return true;
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpen2(string symbol, datetime time)
  {

   static string lastSymbol = "";
   static bool isOpen = false;
   static datetime sessionStart = 0;
   static datetime sessionEnd = 0;

   if(lastSymbol==symbol && sessionEnd>sessionStart)
     {
      if((isOpen && time>=sessionStart && time<=sessionEnd)
         || (!isOpen && time>sessionStart && time<sessionEnd))
         return isOpen;
     }

   lastSymbol = symbol;

   MqlDateTime mtime;
   TimeToStruct(time, mtime);
   datetime seconds = mtime.hour*3600+mtime.min*60+mtime.sec;

   mtime.hour = 0;
   mtime.min = 0;
   mtime.sec = 0;
   datetime dayStart = StructToTime(mtime);
   datetime dayEnd = dayStart + 86400;

   datetime fromTime;
   datetime toTime;

   sessionStart = dayStart;
   sessionEnd = dayEnd;

   for(int session = 0;; session++)
     {

      if(!SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)mtime.day_of_week, session, fromTime, toTime))
        {
         sessionEnd = dayEnd;
         isOpen = false;
         return isOpen;
        }

      if(seconds<fromTime)    // not inside a session
        {
         sessionEnd = dayStart + fromTime;
         isOpen = false;
         return isOpen;
        }

      if(seconds>toTime)    // maybe a later session
        {
         sessionStart = dayStart + toTime;
         continue;
        }

      // at this point must be inside a session
      sessionStart = dayStart + fromTime;
      sessionEnd = dayStart + toTime;
      isOpen = true;
      return isOpen;

     }

   return false;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteZoneWithGUI(string _id)
  {


   if(zoneContainer.deleteZone(_id) == 1)
     {
      // delete from data structure
      zoneContainer.findOrUpdatePivotEdgesOnDelete();
      Print("Deleted the object: " +

            "\n ID: " + _id);

      ChartRedraw();
     }
   else
     {

     }


   if(!ObjectDelete(_Symbol,_id))
     {
      Print("Failed to delete object error: " + GetLastError());
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void handleBuys(ENUM_TIMEFRAMES _timeFrame)
  {

// BUY CASE

   if((marketObserver.getClosestSupportZone() != NULL) && !(marketObserver.getClosestSupportZone().buyEntryManager.isWaitingForRejectionCandle()) && !(marketObserver.getClosestSupportZone().buyEntryManager.buyTradeTaken()) && !(marketObserver.getClosestSupportZone().buyEntryManager.isWaitingForRetracement())) // FIRST CASE : PRICE IS IN THE MIDDLE
     {
      if(marketObserver.bearishCandleClosedInsideClosestSupportZone(_timeFrame))
        {
         Print("Bearish Candle closed inside closest support zone !");
         marketObserver.getClosestSupportZone().buyEntryManager.setWaitingForRejectionCandle(true);

         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
         SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** M1 Bearish candle closed inside the closest support zone, Symbol: " + _Symbol  + " "  + TimeToString(TimeLocal()), fileName);
        }

     }

   else
      if((marketObserver.getClosestSupportZone() != NULL) && (marketObserver.getClosestSupportZone().buyEntryManager.isWaitingForRejectionCandle()) && !(marketObserver.getClosestSupportZone().buyEntryManager.buyTradeTaken()))  // SECOND CASE : PRICE HAS CLOSED IN THE ZONE AND WAITING FOR REJECTION, AND THE TRADE HAS NOT BEEN TAKEN YET
        {
         if(marketObserver.getClosestSupportZone().buyEntryManager.buyRejectionDetector.rejectionByOneCandleFormed(_timeFrame))
           {


            marketObserver.getClosestSupportZone().buyEntryManager.setWaitingForRejectionCandle(false);
            double lastBullishCandleClosePrice = iClose(_Symbol,_timeFrame,1);
            // let the market observer check where the rejection candle closed, was it inside the zone ? or outside ? if outside the zone was it too close to the zone? if too

            if(lastBullishCandleClosePrice > marketObserver.getClosestSupportZone().getHigherEdge())  // closed above the zone
              {

               // now we need to check if closed twice as the zone height


               if(lastBullishCandleClosePrice - marketObserver.getClosestSupportZone().getHigherEdge() > marketObserver.getClosestSupportZone().getZoneHeight())
                 {

                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bullish rejection candle was formed, Price closed above the zone in a distance more than the height of the zone, in these cases i take an entry on imbalance fill or a retracement but at the moment im not trading these cases , Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
                  marketObserver.getClosestSupportZone().buyEntryManager.setWaitingForRetracement(true);
                 }
               else
                 {

                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bullish rejection candle was formed, Price Closed above the zone  in a distance less than the height of the zone, im taking a buy now ! , Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);

                  double stopLossPrice = marketObserver.getClosestSupportZone().getStopLossPrice();
                  double lotsToTrade = lotSizeCalculator.calculateLotSize(riskDollars,stopLossPrice);
                  for(int i=0 ; i<3 ; i++) // after this loop, the trade id's array will be filled, and the 3 trades will be taken
                    {
                     double partialLotPercent ;
                     if(i == 0)
                       {
                        partialLotPercent = 0.5 ;
                       }
                     if(i == 1 || i == 2)
                       {
                        partialLotPercent = 0.25;
                       }
                     ulong currentEntryId = marketObserver.getClosestSupportZone().buyEntryManager.takeBuyTrade(partialLotPercent * lotsToTrade,stopLossPrice);
                     marketObserver.getClosestSupportZone().buyTradeManager.fillRejectionByOneCandleTradeArray(i,currentEntryId);
                    }
                  marketObserver.getClosestSupportZone().buyEntryManager.setTradeTakenStatus(true);
                 }

              }
            else
               if(lastBullishCandleClosePrice < marketObserver.getClosestSupportZone().getHigherEdge() && lastBullishCandleClosePrice > marketObserver.getClosestSupportZone().getLowerEdge())  // closed inside the zone
                 {

                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bullish Rejection Candle Closed inside the zone, im taking a buy now !, Symbol: " + _Symbol  + " "  + TimeToString(TimeLocal()), fileName);
                  double stopLossPrice = marketObserver.getClosestSupportZone().getStopLossPrice();
                  double lotsToTrade = lotSizeCalculator.calculateLotSize(riskDollars,stopLossPrice);
                  for(int i=0 ; i<3 ; i++) // after this loop, the trade id's array will be filled, and the 3 trades will be taken
                    {
                     double partialLotPercent ;
                     if(i == 0)
                       {
                        partialLotPercent = 0.5 ;
                       }
                     if(i == 1 || i == 2)
                       {
                        partialLotPercent = 0.25;
                       }
                     ulong currentEntryId = marketObserver.getClosestSupportZone().buyEntryManager.takeBuyTrade(partialLotPercent * lotsToTrade,stopLossPrice);
                     marketObserver.getClosestSupportZone().buyTradeManager.fillRejectionByOneCandleTradeArray(i,currentEntryId);
                    }
                  marketObserver.getClosestSupportZone().buyEntryManager.setTradeTakenStatus(true);
                 }

            // call trade manager
           }
        }

      else
         if((marketObserver.getClosestSupportZone() != NULL) && (marketObserver.getClosestSupportZone().buyEntryManager.isWaitingForRetracement()))   // THIRD CASE: WAITING FOR A RETRACEMENT BECAUSE THE REJECTION CANDLE CLOSED MORE THAN THE HEIGHT OF THE ZONE
           {

            Print("Im waiting for retracement because the rejection candle closed more than the height of the zone, ** this messaage is just for testing, because i still do not take trades on these kind of setups **");

           }

   if((marketObserver.getClosestSupportZone() != NULL) && marketObserver.candleClosedBelowClosestSupportZone(_timeFrame)  && !(marketObserver.getClosestSupportZone().buyEntryManager.buyTradeTaken()))  // FOURTH CASE: PRICE CLOSED UNDER THE ZONE, AND THE BUY IS STILL NOT TAKEN , SO WE DONT WANT TO ENTER
     {

      ChartRedraw(); // Make sure the chart is up to date
      ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
      SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THIS ZONE ** A candle closed below the support zone, the trade is still not taken and im not gonna take it, Symbol: " + _Symbol + " " + TimeToString(TimeLocal()), fileName);
      string _idToDelete = marketObserver.getClosestSupportZone().getId();
      deleteZoneWithGUI(_idToDelete);

     }
   else
      if((marketObserver.getClosestSupportZone() != NULL) && marketObserver.candleClosedBelowClosestSupportZone(_timeFrame)  && (marketObserver.getClosestSupportZone().buyEntryManager.buyTradeTaken()))  // FIFTH CASE: PRICE CLOSED UNDER THE ZONE, AND THE BUY IS TAKEN , SO WE WANNA CLOSE THE ORDER
        {

         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
         SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THIS ZONE ** A candle closed below the support zone, i am in a buy trade and im gonna close the position and delete the zone, Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
         marketObserver.getClosestSupportZone().buyEntryManager.setTradeTakenStatus(false);

         // Make sure that the trades didnt hit the stop loss first
         marketObserver.getClosestSupportZone().buyTradeManager.cleanOrderDataStructures();
         for(int i=0; i<3; i++)
           {
            marketObserver.getClosestSupportZone().buyTradeManager.closeTrade(i);
           }

         string _idToDelete = marketObserver.getClosestSupportZone().getId();
         deleteZoneWithGUI(_idToDelete);
        }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleSells(ENUM_TIMEFRAMES _timeFrame)
  {




// SELL CASE

   if((marketObserver.getClosestResistanceZone() != NULL) && !(marketObserver.getClosestResistanceZone().sellEntryManager.isWaitingForRejectionCandle()) && !(marketObserver.getClosestResistanceZone().sellEntryManager.sellTradeTaken()) && !(marketObserver.getClosestResistanceZone().sellEntryManager.isWaitingForRetracement()))  // FIRST CASE : PRICE IS IN THE MIDDLE
     {
      if(marketObserver.bullishCandleClosedInsideClosestResistanceZone(_timeFrame))
        {
         marketObserver.getClosestResistanceZone().sellEntryManager.setWaitingForRejectionCandle(true);
         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
         SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** M1 Bullish candle closed inside the resistance zone on " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);

        }

     }

   else
      if((marketObserver.getClosestResistanceZone() != NULL) && (marketObserver.getClosestResistanceZone().sellEntryManager.isWaitingForRejectionCandle()) && !(marketObserver.getClosestResistanceZone().sellEntryManager.sellTradeTaken()))  // SECOND CASE : PRICE HAS CLOSED IN THE ZONE AND WAITING FOR REJECTION, AND THE TRADE HAS NOT BEEN TAKEN YET
        {

         if(marketObserver.getClosestResistanceZone().sellEntryManager.sellRejectionDetector.rejectionByOneCandleFormed(_timeFrame))
           {


            marketObserver.getClosestResistanceZone().sellEntryManager.setWaitingForRejectionCandle(false);
            // let the market observer check where the rejection candle closed, was it inside the zone ? or outside ? if outside the zone was it too close to the zone? if too
            double lastBearishCandleClosePrice = iClose(_Symbol,_timeFrame,1);
            if(lastBearishCandleClosePrice < marketObserver.getClosestResistanceZone().getLowerEdge())  // rejection candle closed under the zone
              {

               // now we need to check if closed twice as the zone height

               if((marketObserver.getClosestResistanceZone().getLowerEdge() - lastBearishCandleClosePrice) > marketObserver.getClosestResistanceZone().getZoneHeight())  // rejection candle closed in a distance more than the height of the zone
                 {

                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bearish rejection candle was formed, Price closed under the zone in a distance more than the height of the zone, in these cases i take an entry on imbalance fill or a retracement but at the moment im not trading these cases , Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
                  marketObserver.getClosestResistanceZone().sellEntryManager.setWaitingForRetracement(true);
                 }
               else  // previous candle closed in a distance less than the height of the zone
                 {
                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bearish rejection candle was formed, Price closed under the zone in a distance less than the height of the zone, im taking a sell now , Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);

                  double stopLossPrice = marketObserver.getClosestResistanceZone().getStopLossPrice();
                  double lotsToTrade = lotSizeCalculator.calculateLotSize(riskDollars,stopLossPrice);
                  for(int i=0 ; i<3 ; i++) // after this loop, the trade id's array will be filled, and the 3 trades will be taken
                    {
                     double partialLotPercent ;
                     if(i == 0)
                       {
                        partialLotPercent = 0.5 ;
                       }
                     if(i == 1 || i == 2)
                       {
                        partialLotPercent = 0.25;
                       }
                     ulong currentEntryId = marketObserver.getClosestResistanceZone().sellEntryManager.takeSellTrade(partialLotPercent * lotsToTrade,stopLossPrice);
                     marketObserver.getClosestResistanceZone().sellTradeManager.fillRejectionByOneCandleTradeArray(i,currentEntryId);
                    }
                  marketObserver.getClosestResistanceZone().sellEntryManager.setTradeTakenStatus(true);


                 }

              }
            else
               if(lastBearishCandleClosePrice < marketObserver.getClosestResistanceZone().getHigherEdge() && lastBearishCandleClosePrice > marketObserver.getClosestResistanceZone().getLowerEdge())  // rejection candle closed inside the zone
                 {

                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** Bearish Rejection Candle Closed inside the zone, im taking a sell now ! , Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
                  double stopLossPrice = marketObserver.getClosestResistanceZone().getStopLossPrice();
                  double lotsToTrade = lotSizeCalculator.calculateLotSize(riskDollars,stopLossPrice);
                  for(int i=0 ; i<3 ; i++) // after this loop, the trade id's array will be filled , and the 3 trades will be taken
                    {
                     double partialLotPercent ;
                     if(i == 0)
                       {
                        partialLotPercent = 0.5 ;
                       }
                     if(i == 1 || i == 2)
                       {
                        partialLotPercent = 0.25;
                       }
                     ulong currentEntryId = marketObserver.getClosestResistanceZone().sellEntryManager.takeSellTrade(partialLotPercent * lotsToTrade,stopLossPrice);
                     marketObserver.getClosestResistanceZone().sellTradeManager.fillRejectionByOneCandleTradeArray(i,currentEntryId);
                    }
                  marketObserver.getClosestResistanceZone().sellEntryManager.setTradeTakenStatus(true);
                 }

            // call trade manager
           }

        }

      else
         if((marketObserver.getClosestResistanceZone() != NULL) && marketObserver.getClosestResistanceZone().sellEntryManager.isWaitingForRetracement())    // THIRD CASE: WAITING FOR A RETRACEMENT BECAUSE THE REJECTION CANDLE CLOSED MORE THAN THE HEIGHT OF THE ZONE
           {

            Print("Im waiting for retracement because the rejection candle closed more than the height of the zone, ** this messaage is just for testing, because i still do not take trades on these kind of setups **");

           }





   if((marketObserver.getClosestResistanceZone() != NULL) &&   marketObserver.candleClosedAboveClosestResistanceZone(_timeFrame) && !(marketObserver.getClosestResistanceZone().sellEntryManager.sellTradeTaken()))  // FOURTH CASE: PRICE CLOSED ABOVE THE ZONE, WE STILL HAVNT TOOK A TRADE, AND WE ARE NOT GONNA TAKE IT
     {



      marketObserver.setClosestResistanceWaiting(true);
      ChartRedraw(); // Make sure the chart is up to date
      ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
      SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** A candle closed above the resistance zone i havnet took a trade, im gonna delete the zone , Symbol: " + _Symbol  + " "  + TimeToString(TimeLocal()), fileName);

      string _idToDelete = marketObserver.getClosestResistanceZone().getId();
      deleteZoneWithGUI(_idToDelete);


     }
   else
      if((marketObserver.getClosestResistanceZone() != NULL) && marketObserver.candleClosedAboveClosestResistanceZone(_timeFrame) && (marketObserver.getClosestResistanceZone().sellEntryManager.sellTradeTaken()))   // FIFTH CASE: PRICE CLOSED ABOVE THE ZONE, WE TOOK THE TRADE, AND WE NEED TO CLOSE IT
        {
         marketObserver.setClosestResistanceWaiting(true);

         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
         SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,"** THIS MESSAGE SHOULD BE SEEN ONCE FOR THE CURRENT ZONE ** A candle closed above the resistance zone im in a sell and im gonna close it, and delete the zone, Symbol: " + _Symbol  + " " + TimeToString(TimeLocal()), fileName);
         marketObserver.getClosestResistanceZone().sellEntryManager.setTradeTakenStatus(false);

         // Make sure that the trades didnt hit the stop loss first
         marketObserver.getClosestResistanceZone().sellTradeManager.cleanOrderDataStructures();
         for(int i=0; i<3; i++)
           {
            marketObserver.getClosestResistanceZone().sellTradeManager.closeTrade(i);
           }

         string _idToDelete = marketObserver.getClosestResistanceZone().getId();
         deleteZoneWithGUI(_idToDelete);


        }


  }
//+------------------------------------------------------------------+
