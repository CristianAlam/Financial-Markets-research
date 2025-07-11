//+------------------------------------------------------------------+
//|                                            library_functions.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"



#include  <Trade/Trade.mqh>



int findMondayFromLastPeriodWeeks(int _period);

// FRACTALS RELATED FUNCTIONS
bool isLowFractalByIndex(int index, int leftPeriod, int rightPeriod, ENUM_TIMEFRAMES timeFrame);  // checks if the given index candle is, a low fractal of the left, right periods
bool isHighFractalByIndex(int index, int leftPeriod, int rightPeriod, ENUM_TIMEFRAMES timeFrame); // checks if the given index candle is, a high fractal of the left, right periods

// TIME FRAME RELATED FUNCTIONS
string getChartTimeFrameInString() ; // gets the chart time frame in string format
string timeFrameToString(ENUM_TIMEFRAMES _timeFrame);

// SESSIONS RELATED FUNCTIONS
bool sessionIsNy(); // checks if the session is ny
bool sessionIsLondon(); // checks if the session is london
bool sessionIsTokyo();



// TRADE RELATED FUNCTIONS
bool closePartialFromAllPositions(double partialAmount) ; // closes partial of all open positions the partial is partialAmount (parameter)
bool closePartialFromSpecificPosition(ulong posTicket, double partialToClose) ; // closes a partial from the given position ticket
bool stopLossIsValidBuys(double stopLoss, double _maxPipsRiskAmount);
bool stopLossIsValidSells(double stopLoss,double _maxPipsRiskAmount);
double positionProfitInPips(ulong posTicket); // returns the position profit in pips
double positionStopLoss(ulong posTicket);
void positionTrailStopLoss(ulong posTicket, double newStopLoss, double takeProfit);



// CANDLE ANATOMY RELATED FUNCTIONS
bool buyBreakerCandleIsValid(ENUM_TIMEFRAMES _timeFrame, double _sizeOfBreakerCandleBody); // checks if the buy breaker candle is big enough
bool sellBreakerCandleIsValid(ENUM_TIMEFRAMES _timeFrame, double _sizeOfBreakerCandleBody); // checks if the sell breaker candle is big enough
bool bearishCandleIsWeak(ENUM_TIMEFRAMES  _timeFrame, int index, double wickRatioRejection);  // this function assumes that the previous candle is bearish
bool bullishCandleIsWeak(ENUM_TIMEFRAMES  _timeFrame, int index, double wickRatioRejection); // this function assumes that the previous candle is bullish
double retestWickFormedOnTheFirstHalfOfCandle(ENUM_TIMEFRAMES _mainTimeFrame, ENUM_TIMEFRAMES _secondaryTimeFrame);
bool candleClosedBullish(ENUM_TIMEFRAMES _timeFrame, int _index);
bool candleClosedBearish(ENUM_TIMEFRAMES _timeFrame,int _index);
bool candleClosedDoji(ENUM_TIMEFRAMES _timeFrame, int _index);
bool candleBodyIsValid(ENUM_TIMEFRAMES _timeFrame, int _index); // this function is used for enhancing the detection of supports/resistances


// SUPPORT AND RESISTANCE RELATED FUNCTIONS
bool supportPatternFormed(ENUM_TIMEFRAMES _timeFrame, int _index=0); // _index = 0 is the default state which is a specific case of the general function with _index = i
bool resistancePatternFormed(ENUM_TIMEFRAMES _timeFrame, int _index=0);// _index = 0 is the default state which is a specific case of the general function with _index = i






/* WARNING FOR THE NEXT FUNCTION*/
/* IF A FRIDAY WAS NOT ON THE BROKER, THE FUNCTION WILL NOT COUNT THE WEEK. MAKE SURE BEFORE APPLYING IT TO SEE VISUALLY THAT IT WAS LAUNCHED RIGHT */

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findMondayFromLastPeriodWeeks(int _period) { // _period = 1 means the previous week. _period = 2 means 2 weeks ago. and so on ...

   int startCountFromIndex = 0 ;
   datetime localTime = TimeLocal();
   MqlDateTime dateTimeStructure ;
   TimeToStruct(localTime,dateTimeStructure);
   int dayOfTheWeek = dateTimeStructure.day_of_week;
   int hourOfTheDay = dateTimeStructure.hour;

   if(dayOfTheWeek == 5) { // means if we called the function on friday , start counting from the candle of index 25, because our goal is to reach the pervious week friday, so we know we are in the previous week
      startCountFromIndex = 25 ;
   }
   if(dayOfTheWeek == 6 || dayOfTheWeek == 7) {
      Alert("Its saturday/sunday start next week !");
   }

   MqlDateTime shiftedBarTimeStruct ;
   int weeksPassed = 0 ; // count of how many weeks we passed. it starts with 0 since we start at week 0. and will end in _period
   int lockCounter = 0;
   int i = startCountFromIndex ; // i represents the distance from the moment we started. by the end of the function it will point to the first monday of the desired week that we want
   while(weeksPassed < _period) {
      datetime shiftedBarTime=iTime(_Symbol,PERIOD_CURRENT,i); // take the date of the current candle
      TimeToStruct(shiftedBarTime,shiftedBarTimeStruct); // change the date to a struct

      if(shiftedBarTimeStruct.day_of_week == 5 && lockCounter == 0) { // if we reached friday, add the weeksPassed by 1 and lock the block for the next friday
         weeksPassed++; // each time we reach a friday this means we are in a previous week. (we are counting the weeks starting from the current moment and going back in time)
         lockCounter++;

      } else if(shiftedBarTimeStruct.day_of_week == 5 && lockCounter > 0) { // stay locked until we pass the current friday
         lockCounter++ ;
      } else if(shiftedBarTimeStruct.day_of_week == 4) { // if  reached thursday , then release the lock
         lockCounter = 0;
      }
      i++;
   }

   Print("weeks passed value is: "+ weeksPassed);
   return i-2 ;

}


// ************************   FRACTALS FUNCTIONS   ************************

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isLowFractalByIndex(int index, int leftPeriod, int rightPeriod, ENUM_TIMEFRAMES timeFrame) { // checks if the given index candle is, a low fractal of the left, right periods

   for(int i = index+1 ; i < (index + leftPeriod + 1) ; i++) {
      if(!(iLow(Symbol(),timeFrame,index) <= iLow(Symbol(),timeFrame,i))) {
         return false;
      }
   }
   
   
   if(index > rightPeriod) { // this means we have enough candles to the right

      for(int j = index-1 ; (j > index - rightPeriod - 1) ; j--) {
         if(!(iLow(Symbol(),timeFrame,index) <= iLow(Symbol(),timeFrame,j))) {
            return false ;
         }
      }
   }
   else{
      return false ;
   }


   return true ;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isHighFractalByIndex(int index, int leftPeriod, int rightPeriod, ENUM_TIMEFRAMES timeFrame) { // checks if the given index candle is, a high fractal of the left, right periods

   for(int i = index+1 ; i < (index + leftPeriod + 1) ; i++) {
      if(!(iHigh(Symbol(),timeFrame,index) >= iHigh(Symbol(),timeFrame,i))) {
         return false;
      }
   }

   if(index > rightPeriod) { // this means we have enough candles to the right

      for(int j = index-1 ; (j > index - rightPeriod - 1) ; j--) {
         if(!(iHigh(Symbol(),timeFrame,index) >= iHigh(Symbol(),timeFrame,j))) {
            return false ;
         }
      }
   }
   else{
      return false ;
   }

   return true ;
}






// ************************   TIME FRAMES FUNCTIONS   ************************

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getChartTimeFrameInString() {

   ENUM_TIMEFRAMES period = Period();

   switch(period) {

   case PERIOD_M1:
      return "PERIOD_M1" ;
      break;

   case PERIOD_M2:
      return "PERIOD_M2" ;
      break;

   case PERIOD_M3:
      return "PERIOD_M3" ;
      break;

   case PERIOD_M4:
      return "PERIOD_M4" ;
      break;

   case PERIOD_M5:
      return "PERIOD_M5" ;
      break;

   case PERIOD_M6:
      return "PERIOD_M6" ;
      break;
   case PERIOD_M10:
      return "PERIOD_M10" ;
      break;

   case PERIOD_M12:
      return "PERIOD_M12" ;
      break;

   case PERIOD_M15:
      return "PERIOD_M15" ;
      break;

   case PERIOD_M20:
      return "PERIOD_M20" ;
      break;

   case PERIOD_M30:
      return "PERIOD_M30" ;
      break;
   case PERIOD_H1:
      return "PERIOD_H1" ;
      break;

   case PERIOD_H2:
      return "PERIOD_H2" ;
      break;

   case PERIOD_H3:
      return "PERIOD_H3" ;
      break;

   case PERIOD_H4:
      return "PERIOD_H4" ;
      break;

   case PERIOD_H6:
      return "PERIOD_H6" ;
      break;

   case PERIOD_H8:
      return "PERIOD_H8" ;
      break;
   case PERIOD_H12:
      return "PERIOD_H12" ;
      break;

   case PERIOD_D1:
      return "PERIOD_D1" ;
      break;
   case PERIOD_W1:
      return "PERIOD_W1" ;
      break;

   case PERIOD_MN1:
      return "PERIOD_MN1" ;
      break;

   }

   return "" ;
}


string timeFrameToString(ENUM_TIMEFRAMES _timeFrame){
   switch(_timeFrame) {

   case PERIOD_M1:
      return "PERIOD_M1" ;
      break;

   case PERIOD_M2:
      return "PERIOD_M2" ;
      break;

   case PERIOD_M3:
      return "PERIOD_M3" ;
      break;

   case PERIOD_M4:
      return "PERIOD_M4" ;
      break;

   case PERIOD_M5:
      return "PERIOD_M5" ;
      break;

   case PERIOD_M6:
      return "PERIOD_M6" ;
      break;
   case PERIOD_M10:
      return "PERIOD_M10" ;
      break;

   case PERIOD_M12:
      return "PERIOD_M12" ;
      break;

   case PERIOD_M15:
      return "PERIOD_M15" ;
      break;

   case PERIOD_M20:
      return "PERIOD_M20" ;
      break;

   case PERIOD_M30:
      return "PERIOD_M30" ;
      break;
   case PERIOD_H1:
      return "PERIOD_H1" ;
      break;

   case PERIOD_H2:
      return "PERIOD_H2" ;
      break;

   case PERIOD_H3:
      return "PERIOD_H3" ;
      break;

   case PERIOD_H4:
      return "PERIOD_H4" ;
      break;

   case PERIOD_H6:
      return "PERIOD_H6" ;
      break;

   case PERIOD_H8:
      return "PERIOD_H8" ;
      break;
   case PERIOD_H12:
      return "PERIOD_H12" ;
      break;

   case PERIOD_D1:
      return "PERIOD_D1" ;
      break;
   case PERIOD_W1:
      return "PERIOD_W1" ;
      break;

   case PERIOD_MN1:
      return "PERIOD_MN1" ;
      break;

   }

   return "" ;

}





// ************************   SESSIONS FUNCTIONS   ************************

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sessionIsNy() {
   MqlDateTime mqldt ;
   datetime currTime = TimeCurrent(mqldt);

   if(mqldt.hour >= 12 && mqldt.hour <= 20) {
      return true ;
   }

   return false ;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sessionIsLondon() {
   MqlDateTime mqldt ;
   datetime currTime = TimeCurrent(mqldt);

   if(mqldt.hour >= 8 && mqldt.hour <= 12) {
      return true ;
   }

   return false ;

}


bool sessionIsTokyo(){
   MqlDateTime mqldt ;
   datetime currTime = TimeCurrent(mqldt);

   if(mqldt.hour >= 4 && mqldt.hour <= 8) {
      return true ;
   }

   return false ;
}


// ************************   TRADE FUNCTIONS   ************************

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool closePartialFromAllPositions(double partialAmount) {
   CTrade trade ;
   for(uint i=0 ; i< PositionsTotal() ; i++) {

      ulong positionTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(positionTicket)) {

         double positionVolume = PositionGetDouble(POSITION_VOLUME);
         double lotsToClose = positionVolume * partialAmount ;
         if(trade.PositionClosePartial(positionTicket,NormalizeDouble(lotsToClose,2))) {
            Print("Closed partials succesffully");
            return true ;
         } else {
            Print("Failed to close partials, Error: " + GetLastError());
            return false ;
         }

      }



   }
   return false ;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool closePartialFromSpecificPosition(ulong posTicket, double partialToClose) {

   CTrade trade ;
   double positionVolume = PositionGetDouble(POSITION_VOLUME);
   double lotsToClose = positionVolume * partialToClose ;
   if(trade.PositionClosePartial(posTicket,NormalizeDouble(lotsToClose,2))) {

      return true ;

   } else {
      return false ;
   }


   return false ;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool stopLossIsValidBuys(double stopLoss, double _maxPipsRiskAmount) {

   if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLoss < _maxPipsRiskAmount) {
      return true ;
   }

   return false ;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double positionProfitInPips(ulong posTicket) {

   double currentProfitInPips = -1 ;
   if(PositionSelectByTicket(posTicket)) {

      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT) ;
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);


      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
         currentProfitInPips = currentPrice - positionOpenPrice ;
      }

      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {

         currentProfitInPips = positionOpenPrice - currentPrice ;
      }
   } else {

      Comment("Error from positionProfitInPips() function: Failed to select position, Error " + GetLastError());
   }



   return currentProfitInPips ;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


double positionStopLoss(ulong posTicket) {

   double posStopLoss = -1 ;
   if(PositionSelectByTicket(posTicket)) {
      posStopLoss = PositionGetDouble(POSITION_SL) ;

   } else {
      Comment("Error from positionStopLoss() function: Failed to select position, Error " + GetLastError());
   }

   return posStopLoss;

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool stopLossIsValidSells(double stopLoss,double _maxPipsRiskAmount) {
   if(stopLoss - SymbolInfoDouble(_Symbol, SYMBOL_BID) < _maxPipsRiskAmount) {
      return true ;
   }
   return false ;

}




void positionTrailStopLoss(ulong posTicket, double newStopLoss, double takeProfit) {

   CTrade trade ;
   trade.PositionModify(posTicket,newStopLoss,takeProfit);



}


// ************************   CANDLE ANATOMY FUNCTIONS   ************************

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool buyBreakerCandleIsValid(ENUM_TIMEFRAMES _timeFrame, double _sizeOfBreakerCandleBody) {

   if((iClose(_Symbol,_timeFrame,1) - iOpen(_Symbol,_timeFrame,1)) >= _sizeOfBreakerCandleBody) {
      return true ;
   } else {
      datetime currTime = TimeCurrent();
      string timeInStr = TimeToString(currTime,TIME_MINUTES);
      Comment(timeInStr + " Bullish Breaker candle body is too small to take a trade !");
      return false ;

   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sellBreakerCandleIsValid(ENUM_TIMEFRAMES _timeFrame, double _sizeOfBreakerCandleBody) {
   if((iOpen(_Symbol,_timeFrame,1) - iClose(_Symbol,_timeFrame,1)) >= _sizeOfBreakerCandleBody) {
      return true ;
   } else {
      datetime currTime = TimeCurrent();
      string timeInStr = TimeToString(currTime,TIME_MINUTES);
      Comment(timeInStr + " Bearish Breaker candle body is too small to take a trade !");
      return false ;

   }

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishCandleIsWeak(ENUM_TIMEFRAMES  _timeFrame, int index, double wickRatioRejection) { // this function assumes that the previous candle is bearish
   
   double upperWickLength = iHigh(_Symbol,_timeFrame,index) - iOpen(_Symbol,_timeFrame,index) ;
   double totalCandleLength = iHigh(_Symbol,_timeFrame,index) - iClose(_Symbol,_timeFrame,index);
   if((upperWickLength / totalCandleLength) >= wickRatioRejection) { // this means the candle is  weak
      Comment("Bearish Candle Is Weak");
      return true ;
   } else {
      return false ;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullishCandleIsWeak(ENUM_TIMEFRAMES  _timeFrame, int index, double wickRatioRejection) { // this function assumes that the previous candle is bullish
   double lowerWickLength = iOpen(_Symbol,_timeFrame,index) - iLow(_Symbol,_timeFrame,index) ;
   double totalCandleLength = iClose(_Symbol,_timeFrame,index) - iLow(_Symbol,_timeFrame,index) ;

   if((lowerWickLength/totalCandleLength) >= wickRatioRejection) { // this means the candle is  weak
      Comment("Bullish Candle is weak");
      return true ;
   } else {
      return false ;
   }
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedBullish(ENUM_TIMEFRAMES _timeFrame, int _index) {
   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);


   if(candleClose >candleOpen) { // the candle closed bullish

      return true ;
   }
   return false ;
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedBearish(ENUM_TIMEFRAMES _timeFrame,int _index) {


   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);


   if(candleClose < candleOpen) { // the candle closed bullish

      return true ;
   }
   return false ;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleClosedDoji(ENUM_TIMEFRAMES _timeFrame, int _index) {
   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);

   if(candleClose == candleOpen) {
      return true;
   } else {
      return false;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleBodyIsValid(ENUM_TIMEFRAMES _timeFrame, int _index) {
   double candleClose = iClose(_Symbol,_timeFrame,_index);
   double candleOpen = iOpen(_Symbol,_timeFrame,_index);
   double candleHigh = iHigh(_Symbol,_timeFrame,_index);
   double candleLow = iLow(_Symbol,_timeFrame,_index);
   double topWickSize ;
   double bottomWickSize ;
   double candleBodySize ;

   if(candleClosedBearish(_timeFrame,_index)) {
      topWickSize = candleHigh - candleOpen ;
      bottomWickSize = candleClose - candleLow ;
      candleBodySize = candleOpen - candleClose ;

   } else if(candleClosedBullish(_timeFrame,_index)) {
      topWickSize = candleHigh - candleClose ;
      bottomWickSize = candleOpen - candleLow ;
      candleBodySize = candleClose - candleOpen ;
   } else if(candleClosedDoji(_timeFrame,_index)) {

      return false ;
   }

   
   if((topWickSize >= (15*candleBodySize)) || (bottomWickSize >= (15* candleBodySize))) { // 8 is fixed number ,
      //which means that if i find a candle's wick that is 15 times bigger than the body then i dont want to consider it when detecting a support or resistance, this is for the cases that the candle looks almost like a doji but not an actual doji
      return false ;
   }

   return true ;
}

/*double retestWickFormedOnTheFirstHalfOfCandle(ENUM_TIMEFRAMES _mainTimeFrame, ENUM_TIMEFRAMES _secondaryTimeFrame){

   if(candleClosedBullish(_mainTimeFrame,1)){ // previous candle closed bullish, this means checking a wick on a bullish candle on the main timeframe
      if(candleClosedBearish(_secondaryTimeFrame)){

      }
   }


   if(candleClosedBearish(_mainTimeFrame)){  // previous candle closed bullish, this means checking a wick on a bearish candle on the main timeframe

   }

}  */


// ************************   SUPPORT AND RESISTANCE RELATED FUNCTIONS   ************************


/*bool supportPatternFormed(ENUM_TIMEFRAMES _timeFrame){ // this is a spicific case of the next function, the _index parameter here is 0
   if((candleClosedBearish(_timeFrame,2) && candleClosedBullish(_timeFrame,1) && candleBodyIsValid(_timeFrame,1)&& candleBodyIsValid(_timeFrame,2)) 
   || (candleClosedBearish(_timeFrame,3)  && candleClosedDoji(_timeFrame,2) && candleClosedBullish(_timeFrame,1))
   || candleClosedBearish(_timeFrame,3) && candleBodyIsValid(_timeFrame,3) && !candleBodyIsValid(_timeFrame,2) && candleClosedBullish(_timeFrame,1) && candleBodyIsValid(_timeFrame,1)) {
      return true ;
   
   }
   return false ;
}*/


bool supportPatternFormed(ENUM_TIMEFRAMES _timeFrame, int _index = 0){ // this is the same previous function but with geniric index to detect the support on . its used for detecing old supports (that are not currently happeneing)


if((candleClosedBearish(_timeFrame,_index+2) && candleClosedBullish(_timeFrame,_index+1) && candleBodyIsValid(_timeFrame,_index+1)&& candleBodyIsValid(_timeFrame,_index+2)) 
   || (candleClosedBearish(_timeFrame,_index+3)  && candleClosedDoji(_timeFrame,_index+2) && candleClosedBullish(_timeFrame,_index+1))
   || candleClosedBearish(_timeFrame,_index+3) && candleBodyIsValid(_timeFrame,_index+3) && !candleBodyIsValid(_timeFrame,_index + 2) && candleClosedBullish(_timeFrame,_index+1)
   && candleBodyIsValid(_timeFrame,_index+1) ){
      return true ;
   
   }
   return false ;

}
bool resistancePatternFormed(ENUM_TIMEFRAMES _timeFrame, int _index = 0){ // this is a spicific case of the next function
   
    if((candleClosedBullish(_timeFrame,_index+2) && candleClosedBearish(_timeFrame,_index+1) && candleBodyIsValid(_timeFrame,_index+2) && candleBodyIsValid(_timeFrame,_index+1))
    || (candleClosedBullish(_timeFrame,3)  && candleClosedDoji(_timeFrame,2) && candleClosedBearish(_timeFrame,1)  )){
    
      return true ;
    }
   
   return false ;
}

