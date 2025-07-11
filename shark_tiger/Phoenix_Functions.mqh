//+------------------------------------------------------------------+
//|                                            Phoenix_Functions.mqh |
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


//input group "Range Related Variables"
//input double rangeDistanceBetweenZones ;
//input double cleanRangeUponEntry ;
//input double potentialRR;

input group "Zone Related Settings"
input double resistanceExtendAboveCandle;
input double resistanceLowerEdgeExtend ;
input double supportExtendBelowCandle ;
input double supportHigherEdgeExtend;
input int    firstZoneShift ;
input datetime rightEdge ;

//input group "Zone TimeFrames"
//input bool APPLY_M30_STRUCTURE ;
//input bool APPLY_H1_STRUCTURE;



//input group "Candle Body Variables"
//input double WICK_RATIO_REJECTION;
//input double SIZE_OF_BREAKER_CANDLE_BODY;

input group "Trade Related Variables 2"
input double riskManagementPartial ;
input double firstPartialCloseFactor ;
input double firstPartialProfitInPips;
input bool BUYS_ALLOWED = true ;
input bool SELLS_ALLOWED = true ;
input double lotSize ;
input int riskManagementCandlesCount ;
input double rrFactor ;
input bool APPLY_TRAIL ;
input ENUM_TIMEFRAMES TRAIL_TIME_FRAME ;


//input group "Trading Sessions"
//input bool TRADE_NEW_YORK_ALLOWED = true  ;
//input bool TRADE_LONDON_ALLOWED = true ;

input group "Fractal Related Variables"
//input int leftFractalPeriod ;
//input int rightFractalPeriod ;
input ENUM_TIMEFRAMES TIME_FRAME_TO_TRADE;
input int fractalsPeriod ;
input int stopLossFractalsPeriod ;
input ENUM_TIMEFRAMES stopLossTimeFrame ;

// GUI CLASSES INITIALIZATION
GraphicalObjectsManager* objectsManager = new GraphicalObjectsManager();



// ALGORITHM CLASSES INITIALIZATION
MarketObserverTiger* marketObserverTiger = new MarketObserverTiger();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
NewCandleDetector newCandleDetectorWeekly("PERIOD_W1");
NewCandleDetector newCandleDetectorDaily("PERIOD_D1");
NewCandleDetector newCandleDetectorH4("PERIOD_H4");
NewCandleDetector newCandleDetectorH1("PERIOD_H1");
NewCandleDetector newCandleDetectorM30("PERIOD_M30");
NewCandleDetector newCandleDetectorM15("PERIOD_M15");
NewCandleDetector newCandleDetectorM5("PERIOD_M5");
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
bool waitForBottomWick = false ;
bool bottomWickFormed = false;
bool topWickFormed = false;
bool waitForTopWick = false ;


double currentResistanceHighEdge = -1 ;
double currentResistanceLowEdge = -1 ;
double currentSupportHighEdge = -1 ;
double currentSupportLowerEdge = -1;


double currentSupportZonePrice ;
double currentResistanceZonePrice;

int indexToNewTrade ;


// DATA STRUCTURES

double lastLowFractalPrice ;
double lastHighFractalPrice ;


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


//double cleanRangeUponEntryActual = cleanRangeUponEntry * Point() ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double rangeDistanceBetweenZonesActual_H4 = rangeDistanceBetweenZones_4H * Point();
//double rangeDistanceBetweenZonesActual_M30 = rangeDistanceBetweenZones_M30 * Point();

double maxPipsRiskAmountActual = maxPipsRiskAmount * Point();

double firstPartialProfitInPipsActual = firstPartialProfitInPips * Point();



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double detectSupportFromLastLowFractal(int _index)
  {
   double lastLowestSupportPrice = 99999;
   for(int i= _index ; i > 1 ; i--)
     {
      if((candleClosedBearish(PERIOD_CURRENT,i) && candleClosedBullish(PERIOD_CURRENT,i-1))|| (candleClosedBearish(PERIOD_CURRENT,i) && candleClosedDoji(PERIOD_CURRENT,i-1)))
        {
         if(iClose(_Symbol,PERIOD_CURRENT,i) < lastLowestSupportPrice)
           {
            lastLowestSupportPrice = iClose(_Symbol,PERIOD_CURRENT,i);

           }
        }
     }

   return lastLowestSupportPrice ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double detectResistanceFromLastHighFractal(int _index)
  {


   double lastHighestResistancePrice = -1;
   for(int i= _index ; i > 1 ; i--)
     {
      if((candleClosedBullish(PERIOD_CURRENT,i) && candleClosedBearish(PERIOD_CURRENT,i-1))|| (candleClosedBullish(PERIOD_CURRENT,i) && candleClosedDoji(PERIOD_CURRENT,i-1)))
        {
         if(iClose(_Symbol,PERIOD_CURRENT,i) > lastHighestResistancePrice)
           {
            lastHighestResistancePrice = iClose(_Symbol,PERIOD_CURRENT,i);

           }
        }
     }

   return lastHighestResistancePrice ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findAndDrawFractalsAndZones(ENUM_TIMEFRAMES _timeFrame, string _timeFrameStr)
  {
   if(isLowFractalByIndex(fractalsPeriod+1,fractalsPeriod,fractalsPeriod,_timeFrame))    // SUPPORTS
     {
      objectsManager.drawLowFractal(fractalsPeriod+1,clrRed);
      lastLowFractalPrice = iLow(_Symbol,PERIOD_CURRENT,fractalsPeriod+1);
      currentSupportZonePrice = detectSupportFromLastLowFractal(fractalsPeriod+5);

      datetime _leftEdge = iTime(_Symbol,PERIOD_CURRENT,fractalsPeriod+1);
      datetime _rightEdge =rightEdge;
      double _higherEdgePrice  = currentSupportZonePrice + supportHigherEdgeExtendActual;
      double _lowerEdgePrice = currentSupportZonePrice - supportExtendBelowCandleActual;

      currentSupportLowerEdge = _lowerEdgePrice;
      currentSupportHighEdge = _higherEdgePrice ;

      Zone* supportZoneObject = new Zone("support_zone",_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,_timeFrameStr,"TYPE_SUPPORT_BREAKOUT");
      objectsManager.drawRectangleInStrategyTester(1,_leftEdge,_rightEdge,_higherEdgePrice,_lowerEdgePrice,clrAliceBlue);

      if(candleClosedBelowSupportZone(_timeFrame))
        {
         Comment("Im taking a sell !");
         if(((indexToNewTrade = findAvailableSpotInSellManagerArr())!= -1))
           {


            double stopLossPrice ;
            if(currentResistanceHighEdge != -1)
              {
               //   stopLossPrice = currentResistanceHighEdge + stopLossAboveWickByActual ;
               stopLossPrice = lastHighFractalPrice + stopLossAboveWickByActual;
              }
            //stopLossPrice = iHigh(_Symbol,_timeFrame,1) + stopLossAboveWickByActual;

            if(stopLossIsValidSells(stopLossPrice,maxPipsRiskAmountActual))
              {
               double stopLossInPips = stopLossPrice - SymbolInfoDouble(_Symbol,SYMBOL_BID)  ;
               double netTp = rrFactor * stopLossInPips ;
               double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_BID)- netTp) ;

               SellTradeManagerTiger* tempTigerManagerSell= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger

               tempTigerManagerSell.setBrokenSupportHigherEdge(currentSupportHighEdge);
               tempTigerManagerSell.setBrokenSupportLowerEdge(currentSupportLowerEdge);
               SellActiveTradesArray[indexToNewTrade] = tempTigerManagerSell ;// put the new object in the array

               sellsCount++;
              }
            else
              {
               Print("stop loss is not valid sells!");
              }


           }
         else
           {

            Comment("i cant take a trade because the arrray is full");
           }

         currentSupportLowerEdge = -1;
         currentSupportHighEdge = -1 ;
        }



     }

   if(isHighFractalByIndex(fractalsPeriod+1,fractalsPeriod,fractalsPeriod,_timeFrame))  // RESISTANCES
     {
      objectsManager.drawHighFractal(fractalsPeriod+1,clrAliceBlue);
      lastHighFractalPrice = iHigh(_Symbol,PERIOD_CURRENT,fractalsPeriod+1);
      currentResistanceZonePrice = detectResistanceFromLastHighFractal(fractalsPeriod+5);

      datetime _leftEdge = iTime(_Symbol,PERIOD_CURRENT,fractalsPeriod+1);
      datetime _rightEdge =rightEdge;
      double _higherEdgePrice  = currentResistanceZonePrice + resistanceExtendAboveCandleActual;
      double _lowerEdgePrice = currentResistanceZonePrice - resistanceLowerEdgeExtendActual;

      currentResistanceHighEdge = _higherEdgePrice;
      currentResistanceLowEdge = _lowerEdgePrice;
      Zone* supportZoneObject = new Zone("resistance_zone",_higherEdgePrice,_lowerEdgePrice,_leftEdge,_rightEdge,_timeFrameStr,"TYPE_RESISTANCE_BREAKOUT");
      objectsManager.drawRectangleInStrategyTester(2,_leftEdge,_rightEdge,_higherEdgePrice,_lowerEdgePrice,clrAliceBlue);

      if(candleClosedAboveResistanceZone(_timeFrame))
        {
         Comment("Im taking a buy !");

         if(((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1))
           {

            Print("indexToNewTrade:--------------------------------------- " + indexToNewTrade);
            double stopLossPrice ;
            if(currentSupportLowerEdge != -1)
              {
               //   stopLossPrice = currentSupportLowerEdge - stopLossUnderWickByActual ;
               stopLossPrice = lastLowFractalPrice - stopLossUnderWickByActual ;
              }

            //stopLossPrice = iLow(_Symbol,_timeFrame,1) - stopLossUnderWickByActual; // if there is no lower zone , take the last m30 candle's low

            if(stopLossIsValidBuys(stopLossPrice,maxPipsRiskAmountActual))
              {
               double stopLossInPips = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - stopLossPrice ;
               double netTp = rrFactor * stopLossInPips ;
               double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+ netTp) ;

               BuyTradeManagerTiger* tempTigerManagerBuy= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
               tempTigerManagerBuy.setBrokenResistanceHigherEdge(currentResistanceHighEdge);
               tempTigerManagerBuy.setBrokenResistancetLowerEdge(currentResistanceLowEdge);
               BuyActiveTradesArray[indexToNewTrade] = tempTigerManagerBuy ;// put the new object in the array

               buysCount++;
              }
            else
              {
               Print("stop loss is not valid buys !");
              }

           }
         else
           {

            Comment("i cant take a trade because the arrray is full");
           }

         currentResistanceHighEdge = -1;
         currentResistanceLowEdge = -1 ;
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedBelowSupportZone(ENUM_TIMEFRAMES _timeFrame)
  {
   if(candleClosedBearish(_timeFrame,1) && (iClose(_Symbol,_timeFrame,1) < currentSupportLowerEdge) && (currentSupportLowerEdge != -1)  && (currentSupportZonePrice != 99999))
     {
      return true ;
     }
   return false ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedAboveResistanceZone(ENUM_TIMEFRAMES _timeFrame)
  {

   if(candleClosedBullish(_timeFrame,1) && (iClose(_Symbol,_timeFrame,1) > currentResistanceHighEdge) && (currentResistanceHighEdge != -1) && (currentResistanceZonePrice != 0))
     {

      return true ;
     }
   return false ;
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
         if(BuyActiveTradesArray[i]!= NULL)
           {
            Print("Cleaned the position with the id of: "+ BuyActiveTradesArray[i].getTradeId());
           }

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
//|                                                                  |
//+------------------------------------------------------------------+
void manageRiskIfNeededPhoenix()
  {

   for(int i=0; i<NUM_MAX_ALLOWED_TRADES; i++)
     {
      if(BuyActiveTradesArray[i] != NULL)
        {
         if(candleClosedBearish(PERIOD_M5,1) && (iClose(_Symbol,PERIOD_M5,1) < BuyActiveTradesArray[i].getBrokenResistanceLowerEdge()))
           {
            BuyActiveTradesArray[i].incrementRiskManagementCandleCoutner();
            Print("risk managment candle coutn is :" + BuyActiveTradesArray[i].getRiskManagementCandleCounter());
           }
         else
            if((iClose(_Symbol,PERIOD_M5,1)) > BuyActiveTradesArray[i].getBrokenResistanceHigherEdge())
              {
               BuyActiveTradesArray[i].setRiskManagementCandleCounter(0);
              }

         if(BuyActiveTradesArray[i].getRiskManagementCandleCounter() >= riskManagementCandlesCount)
           {
            // Close the trade
            tradeLong.PositionClose(BuyActiveTradesArray[i].getTradeId());
           }
        }




      if(SellActiveTradesArray[i] != NULL)
        {
         if(candleClosedBullish(PERIOD_M5,1) && (iClose(_Symbol,PERIOD_M5,1) > SellActiveTradesArray[i].getBrokenSupportHigherEdge()))
           {
            SellActiveTradesArray[i].incrementRiskManagementCandleCoutner();

           }
         else
            if((iClose(_Symbol,PERIOD_M5,1)) < SellActiveTradesArray[i].getBrokenSupportLowerEdge())
              {
               SellActiveTradesArray[i].setRiskManagementCandleCounter(0);
              }

         if(SellActiveTradesArray[i].getRiskManagementCandleCounter() >= riskManagementCandlesCount)
           {
            // Close the trade
            tradeShort.PositionClose(SellActiveTradesArray[i].getTradeId());
           }
        }
     }

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateStopLossBasedOnFractalsBuys(int _fractalsPeriod, ENUM_TIMEFRAMES _timeFrame)
  {



   for(int i=0 ; 300 ; i++) // scan the last 200 candles
     {
      if(isLowFractalByIndex(i,_fractalsPeriod,_fractalsPeriod,_timeFrame))
        {
         
         return iLow(_Symbol,_timeFrame,i);
        }
     }

   return -1 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateStopLossBasedOnFractalsSells(int _fractalsPeriod,ENUM_TIMEFRAMES _timeFrame)
  {
   for(int i=0 ; 300 ; i++) // scan the last 200 candles
     {
      if(isHighFractalByIndex(i,_fractalsPeriod,_fractalsPeriod,_timeFrame))
        {
         return iHigh(_Symbol,_timeFrame,i);
        }
     }

   return -1 ;
  }
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