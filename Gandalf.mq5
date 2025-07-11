//+------------------------------------------------------------------+
//|                                                      Gandalf.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "GraphicalObjectsManager.mqh"
#include  "TempLineObjectAttributes.mqh"
#include "ObjectConfirmationUnit.mqh"
#include  "BuyGandalf.mqh"
#include  "SellGandalf.mqh"
#include  "LotSizeCalculator.mqh"



LotSizeCalculator lsCalc;
GraphicalObjectsManager graphicalObjectsManager ;
ObjectConfirmationUnit objectConfUnit ;
BuyGandalf buyGandalfGray ;
SellGandalf SellGandalfGray ;

bool buyCase = false ;
bool sellCase = false ;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

TempLineObjectAttributes tempLineObjectAttr ;
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   
   graphicalObjectsManager.addTotalRiskText();
   graphicalObjectsManager.addTakeBuyTradeButton();
   graphicalObjectsManager.addTakeSellTradeButton();
   graphicalObjectsManager.addText();
   graphicalObjectsManager.addConfirmButton();
   
   //ObjectSetString(0,"totalRiskText",OBJPROP_TEXT,"the new ext is : !");



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
      
      updateOverAllRiskText();

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



   switch(id)
     {

      case CHARTEVENT_CLICK:
        {

         break;
        }




      //--- clicking on a graphical object
      case CHARTEVENT_OBJECT_CLICK:
        {


         if(sparam == "BUY_BTN")
           {
            buyCase = true ;

            graphicalObjectsManager.drawStopLossLineGandalf();
            objectConfUnit.setWaitingStatus(true);

           }
           
           else if(sparam == "SELL_BTN"){
            sellCase = true ;
            graphicalObjectsManager.drawStopLossLineGandalf();
            objectConfUnit.setWaitingStatus(true);
           
           
           }

         else
            if(sparam == "CONFIRM_BTN")
              {
               if(buyCase == true)
                 {
                  if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS SOMETHING SELECTED TO BE CONFIRMED
                    {
                     double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK) ;
                     string textRecieved;
                     graphicalObjectsManager.EditTextGet(textRecieved,0,"textName");
                     double riskAsDouble = StringToDouble(textRecieved);
                     
                     double stopLossPrice = tempLineObjectAttr.getPrice();

                    

                     if(ObjectDelete(_Symbol,"sl"))
                       {

                       }
                     else
                       {
                        Print("Failed to delete the stop loss line ! Error: "+ GetLastError());
                       }

                     //Print("Buy info has been set, SL price: " + stopLossPrice + " risk is: " + riskAsDouble);
                     
                     double lotsToTrade = lsCalc.calculateLotSize(riskAsDouble,stopLossPrice);
                     
                     buyGandalfGray.takeBuyTradeGandalf(lotsToTrade,stopLossPrice);
                     
                      objectConfUnit.setWaitingStatus(false);
                      buyCase = false ;
                      
                      // change the risk text 
                      //updateOverAllRiskText();
                      

                    }

                 }
               else
                  if(sellCase == true)
                    {

                     if(objectConfUnit.getWaitingStatus() == true)  // THIS IS TO MAKE SURE THAT THERE IS SOMETHING SELECTED TO BE CONFIRMED
                       {

                        double bid =   SymbolInfoDouble(_Symbol, SYMBOL_BID);
                        string textRecieved;
                        graphicalObjectsManager.EditTextGet(textRecieved,0,"textName");
                        double riskAsDouble = StringToDouble(textRecieved);
                        
                        double stopLossPrice = tempLineObjectAttr.getPrice();
                        
                        if(ObjectDelete(_Symbol,"sl")){
                        
                        
                        }
                        else{
                        
                           Print("Failed to delete the stop loss line ! Error: "+ GetLastError());
                        }
                        double lotsToTrade = lsCalc.calculateLotSize(riskAsDouble,stopLossPrice);
                        SellGandalfGray.takeSellTradeGandalf(lotsToTrade,stopLossPrice);
                        
                        objectConfUnit.setWaitingStatus(false);
                        sellCase = false ;
                        
                        
                         // change the risk text 
                        //updateOverAllRiskText();
                        

                       }

                    }




              }
         break;
        }


      case CHARTEVENT_OBJECT_DRAG:
        {



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


           }


         break;
        }


      case CHARTEVENT_KEYDOWN:
        {

        }



         //---

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


void updateOverAllRiskText(){

   
   
   //double pointValue = lsCalc.PointValue(_Symbol);
   
   double pointValue = PointValueNew(_Symbol);
   double overAllRisk = 0 ;
   for(int i=PositionsTotal() -1 ;i >= 0 ; i--){
         //Print("entered here !");
         ulong ticket = PositionGetTicket(i);
         int positionType = PositionGetInteger(POSITION_TYPE);
         double positionStopLossPrice = PositionGetDouble(POSITION_SL);
         double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double positionLotSize = PositionGetDouble(POSITION_VOLUME);
               
       
         if(positionType == POSITION_TYPE_BUY){
             double positionStopLossInPoints = (positionOpenPrice - positionStopLossPrice) * MathPow(10 , SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)) ;
             double riskAmount = pointValue*positionLotSize*positionStopLossInPoints ;
             overAllRisk = overAllRisk + riskAmount ;
             string riskAsString = DoubleToString(overAllRisk);
             ObjectSetString(0,"totalRiskText",OBJPROP_TEXT,"Total Risk is:" + riskAsString);
         }
         else if(positionType == POSITION_TYPE_SELL){
             double positionStopLossInPoints = (positionStopLossPrice - positionOpenPrice) * MathPow(10 , SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)) ;
             double riskAmount = pointValue*positionLotSize*positionStopLossInPoints ;
             overAllRisk = overAllRisk + riskAmount ;
             string riskAsString = DoubleToString(overAllRisk);
             ObjectSetString(0,"totalRiskText",OBJPROP_TEXT,"Total Risk is:" + riskAsString);
            
         }
   }

}



double PointValueNew(string symbol){

   
   double tickSize = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);
   double ticksPerPoint = tickSize/point ;
   double pointValue = tickValue/ticksPerPoint ;
   
   return (pointValue);
}