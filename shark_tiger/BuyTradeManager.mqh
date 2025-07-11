//+------------------------------------------------------------------+
//|                                              BuyTradeManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include <TradeManagersAttributes.mqh>
//#include <Telegram_Handler.mqh>
#include  <Trade/Trade.mqh>
CTrade tradeLongInTradeManager;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BuyTradeManager
  {
private:
   int               tradeId;
   ulong             rejectionByOneCandleTradeArray[3];

   string            firstSecureMethod ;
   bool              firstSecureMethodFound;
   int               numberOfTakeProfits ;
   bool              securedFirstLevelProfit ;
   bool              securedSecondLevelProfit;
   double            partialToClose ;
   bool              isTradeRunning ;


public:
                     BuyTradeManager();
                    ~BuyTradeManager();

   void              fillRejectionByOneCandleTradeArray(int _index, int _id) {rejectionByOneCandleTradeArray[_index] = _id ;}
   ulong             getRejectionByOneCandleTradeTicket(int _index) {return rejectionByOneCandleTradeArray[_index] ;}
   void              printRejectionByOneCandleTradeArray();

   void              checkAndSecureTradeIfNeeded(double _ratio, double _riskInDollars);
   string            findFirstSecureMethod();

   bool              reachedProfitRatio(int _indexInArr);
   bool              closeTrade(int _indexInArr);
   bool              positionBreakEven(int _indexInArr);


   void              addTpAtIndex(int _index, double tpPrice) {tpArray[_index] = tpPrice;}
   int               countRemainingTakeProfits();
   bool              reachedClosestTakeProfit();
   void              deleteClosestTp();
   int               findClosestTpIndex();


   void              cleanOrderDataStructures();

   void              setTradeRunning(bool _setting) {isTradeRunning = _setting ;}
   bool              tradeIsRunning() {return isTradeRunning ;}

   double            tpArray[3];


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyTradeManager::BuyTradeManager()
  {

   for(int i=0; i<3; i++)
     {
      tpArray[i] = -1;
     }
   securedFirstLevelProfit = false ;
   securedSecondLevelProfit = false ;
   firstSecureMethodFound = false ;
   firstSecureMethod = "NOT_FOUND" ;
   partialToClose = -1 ;
   isTradeRunning = false ;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BuyTradeManager::~BuyTradeManager()
  {
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyTradeManager:: printRejectionByOneCandleTradeArray()
  {

   Print("Printing the tickets :");
   for(int i=0 ; i<3 ; i++)
     {
      Print((int)rejectionByOneCandleTradeArray[i]);
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyTradeManager:: checkAndSecureTradeIfNeeded(double _ratio, double _riskInDollars)
  {
   if(securedFirstLevelProfit == false)  // in this case im searching for 2 cases: either RR 1:1.5 , OR reaching the first TP , if any of them happened im gonna close half the order and updatae the remaining stop losses
     {


      if(!firstSecureMethodFound)
        {

         firstSecureMethod = findFirstSecureMethod();
         if(firstSecureMethod != "FAILED")
           {

            firstSecureMethodFound = true ;
           }
         else
            if(firstSecureMethod == "FAILED")
              {
               Print("Failed to find the first secure method, go check the function : findFirstSecureMehod() !");
              }

        }

      if(firstSecureMethodFound == true)
        {

         if(firstSecureMethod == "RATIO_METHOD")
           {
            cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
            if(reachedProfitRatio(0))
              {
               ChartRedraw(); // Make sure the chart is up to date
               //ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
               //SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                   //"If you see this message it means we reached the first secure method, which is ratio method, after this message, half of the order must be closed (2 trades will remain active), and the first quarter will be put into Break even " + TimeToString(TimeLocal()), fileName);
               if(closeTrade(0)) // close the half
                 {

                  rejectionByOneCandleTradeArray[0] = -1;
                  Print("Closed Half Of the position due to reaching the first secure Ratio!");
                 }
               else
                 {
                  Print("Failed Closing Half of the order by reaching the first secure Ratio !");
                 }

               cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
               if(positionBreakEven(1))  // put the first quarter at break even
                 {

                  Print(" First quarter has been put into break even due to reaching the first secure Ratio!");
                 }
               else
                 {
                  Print("Failed to Put the first quarter into break even");
                 }

               numberOfTakeProfits = countRemainingTakeProfits();

               Print("Number of remaining tps is: " + numberOfTakeProfits);

               securedFirstLevelProfit = true ;
              }





           }
         else
            if(firstSecureMethod == "FIRST_TP_METHOD")
              {
               if(countRemainingTakeProfits() > 1)   // there is at least 2 tp in the tp Array (because if this is the last tp then we want to close the whole order and not just a part of it)
                 {
                  if(reachedClosestTakeProfit())  // 2. Check if reached the first Tp
                    {
                     ChartRedraw(); // Make sure the chart is up to date
                     //ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                     //SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                         //"If you see this message it means we reached the first secure method which is tp1, after this message, half of the order must be closed (2 trades will remain active), and the first quarter will be put into Break even " + TimeToString(TimeLocal()), fileName);
                     // close the first half and update remaining partials sl's and delete the closest take profit from the array
                     cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
                     if(closeTrade(0)) // close the half
                       {

                        rejectionByOneCandleTradeArray[0] = -1;
                        Print("Closed Half Of the position due to reaching the first TP!");

                       }
                     else
                       {
                        Print("Failed Closing Half of the order by reaching the first TP !");
                       }
                     cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
                     if(positionBreakEven(1))  // put the first quarter at break even
                       {

                        Print(" First quarter has been put into break even due to reaching the first TP!");
                       }
                     else
                       {
                        Print("Failed to Put the first quarter into break even");
                       }
                     deleteClosestTp();
                     numberOfTakeProfits = countRemainingTakeProfits(); // update the number of remaining take profits
                     // calculate the remaining tps

                     Print("Number of remaining tps is: " + numberOfTakeProfits);
                     Print("TP ARRY: " + tpArray[0] + ", " + tpArray[1] + " , " + tpArray[2]);

                     securedFirstLevelProfit = true ;


                    }
                 }
               else
                  if(numberOfTakeProfits = countRemainingTakeProfits() == 1)
                    {
                     if(reachedClosestTakeProfit())
                       {
                        // close everything remained
                       }
                    }
              }

        }



     }
   else
      if(securedFirstLevelProfit == true)  // after securing the first level i just want to close the remaining partials by reaching the tp's
        {

         if(countRemainingTakeProfits() == 1)
           {
            if(reachedClosestTakeProfit())
              {
               // close everything
               cleanOrderDataStructures();
               for(int i=0 ; i<3 ; i++)
                 {
                  closeTrade(i);
                 }
               Print("Closed every thing because price reached the last Take Profit !");

               ChartRedraw(); // Make sure the chart is up to date
               //ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
               //SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                  // "If you see this message it means that all order are closed as a result of reaching the last tp " + TimeToString(TimeLocal()), fileName);
               deleteClosestTp();
              }
           }
         else
            if(countRemainingTakeProfits() > 1)
              {
               if(reachedClosestTakeProfit())
                 {
                  cleanOrderDataStructures();
                  if(PositionSelectByTicket(rejectionByOneCandleTradeArray[1])) // DEALING WITH THE FIRST QUARTER
                    {
                     double currentLot = PositionGetDouble(POSITION_VOLUME);
                     if(partialToClose == -1)
                       {
                        partialToClose = currentLot/numberOfTakeProfits ;
                       }
                     if(tradeLongInTradeManager.PositionClosePartial(rejectionByOneCandleTradeArray[1],NormalizeDouble(partialToClose,2)))
                       {
                        uint res = tradeLongInTradeManager.ResultRetcode();
                        if(res == 10009)
                          {
                           Print("Closed Partials successfully on the first quarter !");
                          }
                        else
                          {
                           Print("The returned code is: " + res + " go check what it means !");
                          }

                       }
                    }
                  else
                    {
                     Print("Failed to select position by ticket! , Error: " + GetLastError());
                     Print("The EA tried to close partials on the first quarter, but it is closed, probably due to break even and thats why it couldnt select the order !");
                    }


                  cleanOrderDataStructures();
                  if(PositionSelectByTicket(rejectionByOneCandleTradeArray[2])) // DEALING WITH THE SECOND QUARTER
                    {
                     if(PositionGetDouble(POSITION_SL) < PositionGetDouble(POSITION_PRICE_OPEN)) // this is to put the second quarter at break even if its not already at break even
                       {
                        positionBreakEven(2);

                       }
                     double currentLot = PositionGetDouble(POSITION_VOLUME);
                     if(partialToClose == -1)
                       {
                        partialToClose = currentLot/numberOfTakeProfits ;
                       }
                     if(tradeLongInTradeManager.PositionClosePartial(rejectionByOneCandleTradeArray[2],NormalizeDouble(partialToClose,2)))
                       {
                        uint res = tradeLongInTradeManager.ResultRetcode();
                        if(res == 10009)
                          {
                           Print("Closed Partials successfully on the second quarter!");
                          }
                        else
                          {
                           Print("The returned code is: " + res + " go check what it means !");
                          }

                       }

                    }
                  deleteClosestTp();
                  Print("Number Of Remained tps is: " + countRemainingTakeProfits());

                  ChartRedraw(); // Make sure the chart is up to date
                  //ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  //SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                    //  "If you see this message it means we reached a tp level (different than the first secure level), so partial positions will be closed, and the scond quarter must be in break even!" + TimeToString(TimeLocal()), fileName);
                 }

              }


        }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BuyTradeManager:: findFirstSecureMethod()
  {

   cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
   if(PositionSelectByTicket(rejectionByOneCandleTradeArray[0]))
     {
      double positionStopLoss = PositionGetDouble(POSITION_SL);
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double firstTakeProfit = tpArray[findClosestTpIndex()];
      if(((firstTakeProfit-positionOpenPrice)/(positionOpenPrice-positionStopLoss) > firstSecureRatio))  // firstTp > ratio
        {
         Print("Found the first profit secure method !");
         Print("The first TP RR is: 1:" + (firstTakeProfit-positionOpenPrice)/(positionOpenPrice-positionStopLoss) + "the firstSecureRatio is: 1:" + firstSecureRatio);
         Print("The tp ratio is greater than the firstSecure so:");
         Print("The first secure method is RATIO_METHOD");
         return"RATIO_METHOD";
        }
      else
         if((firstTakeProfit-positionOpenPrice)/(positionOpenPrice-positionStopLoss)< firstSecureRatio)
           {
            Print("Found the first profit secure method !");
            Print("The first TP RR is: 1:" + (firstTakeProfit-positionOpenPrice)/(positionOpenPrice-positionStopLoss) + "the firstSecureRatio is: 1:" + firstSecureRatio);
            Print("The tp ratio is less than the firstSecure so:");
            Print("The first secure method is FIRST_TP_METHOD");
            return "FIRST_TP_METHOD" ;
           }
     }
   else
     {
      Print("Failed to select position by ticket 1, Error: " + GetLastError());
     }

   return "FAILED" ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuyTradeManager:: reachedProfitRatio(int _indexInArr)
  {

   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))
        {
         if(PositionGetDouble(POSITION_PROFIT)/(0.5*riskDollars) >= firstSecureRatio)    // checking if the first half of the contract reached the ratio of first secure profit
           {
            Print("reached profit ratio !");
            return true ;
           }
        }
      else
        {
         Print("Failed to select the position by ticket 4 ,Error: " + GetLastError());

        }

     }

   return false ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  BuyTradeManager:: closeTrade(int _indexInArr)
  {


   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))
        {

         // close the first half and update remaining partials sl's
         if(tradeLongInTradeManager.PositionClose(_ticket))
           {
            return true ;

           }
         else
           {

            Print("Failed to close  positon, Error:" + GetLastError());
            return false;
           }

        }
      else
        {

         Print("Failed to select position by ticket , Error: "+ GetLastError());
         return false;
        }

     }


   return false ;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  BuyTradeManager::  positionBreakEven(int  _indexInArr)
  {

   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))  // select the first quarter
        {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double positionTp = PositionGetDouble(POSITION_TP);
         double positionSl = PositionGetDouble(POSITION_SL);

         if(tradeLongInTradeManager.PositionModify(_ticket,openPrice,positionTp))
           {


            return true ;
           }
         else
           {
            Print("Failed to modify oder , ERROR: " + GetLastError());
            return false ;
           }

        }
      else
        {
         Print("Failed to select position by ticket ");
         return false ;
        }
     }


   return false ;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BuyTradeManager:: countRemainingTakeProfits()
  {

   int counter = 0 ;
   for(int i=0; i<3 ; i++)
     {
      if(tpArray[i] != -1)
        {
         counter++ ;
        }
     }

   return counter;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyTradeManager:: deleteClosestTp()
  {

   int closestTpIndex =findClosestTpIndex();
   tpArray[closestTpIndex] = -1;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BuyTradeManager:: findClosestTpIndex()
  {
   int closestTpIndex = 0;
   int closestTpValue =  1000000 ; // dummy value

   for(int i=0; i<3; i++)
     {
      if(tpArray[i] != -1 && tpArray[i] < closestTpValue)
        {
         closestTpValue = tpArray[i];
         closestTpIndex = i ;
        }

     }

   return closestTpIndex ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuyTradeManager:: reachedClosestTakeProfit()
  {


   double closestTakeProfitValue = tpArray[findClosestTpIndex()];
   //Print("im in reached closest take profit function ,the current price is: " + SymbolInfoDouble(_Symbol, SYMBOL_BID) + " and the tp is: " + closestTakeProfitValue);
   if(SymbolInfoDouble(_Symbol, SYMBOL_BID) >= closestTakeProfitValue) // we are looking for the BID , because reaching a tp in a buy trade means we are selling, so we want our take profit value, to be at least as the BID price (because we want to find someone to buy it from us at this price)
     {
      return true ;
     }
   return false ;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyTradeManager:: cleanOrderDataStructures()
  {
// this is to make sure, that every closed order is removed from the data strucutre !

   for(int i=0; i<3; i++)
     {
      if(!PositionSelectByTicket(rejectionByOneCandleTradeArray[i]))
        {
         if(GetLastError() == 4753)
           {
            rejectionByOneCandleTradeArray[i] = -1 ;
           }
        }
     }

  }
//+------------------------------------------------------------------+


