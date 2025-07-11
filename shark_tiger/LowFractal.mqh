//+------------------------------------------------------------------+
//|                                                   LowFractal.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class LowFractal
  {
private:

private:

   double lowPrice ;
   int               leftPeriod;
   int               rightPeriod;

   MqlDateTime dateStruct ;
   datetime date ;

   double            buyLimitPrice; // the fib level price , based on this fractal
   double highestPeak ; // the highest price reached, after the fractal was formed
   int hour ;
   int               minute;
   int distance ; // holds the number of candles from this fractal until the current live candle
   string arrowObjName ;
   double fibPrice ;

public:
                     LowFractal();
                     LowFractal(double _price, int _leftPeriod, int _rightPeriod, datetime _date,ENUM_TIMEFRAMES _tf);
                    ~LowFractal();



   // GETTERS

   double            getPrice();
   int               getLeftPeriod();
   int               getRightPeriod();
   int               getHour();
   int               getMinute();
   double            getHighestPeak();
   int               getDistance();
   string            getArrowObjName();
   datetime          getDate();
   // SETTERS

   void              setPrice(double _price);
   void              setLeftPeriod(int _leftPeriod);
   void              setRightPeriod(int _rightPeriod);
   void              setHour(int _hour);
   void              setMinute(int _minute);
   void              setHighestPeak(double _highest);
   void              setArrowObjName(string _name);
   void              setDistance(int _dist);
   void              setDate(datetime _givenDate);


   // OTHER FUNCTIONS

   double            calculateFibPrice(double _fibLevel, double _lowPrice, double _highPrice); // calculate the fibonacci price based on the given level, and saves the price in the fibPrice88 variable in the object
   void              updateDistance();
   

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LowFractal::LowFractal()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LowFractal::LowFractal(double _price, int _leftPeriod, int _rightPeriod,datetime _date, ENUM_TIMEFRAMES _tf)
  {
// the constructor sets the data to the attribues , and calculates the real time of the fractal , because the given minute and hour
// are not the real time, they are the time of when the fractal was "known to be a fractal", which is after _righPeriod amount of candles

   lowPrice  = _price ;
   leftPeriod = _leftPeriod;
   rightPeriod = _rightPeriod;
   buyLimitPrice = -1 ;
   distance = _rightPeriod+1;
   arrowObjName = " " ;
   highestPeak = -1; 


   date = iTime(_Symbol,_tf,_rightPeriod+1); // bring the actual date of the fractal
   TimeToStruct(date,dateStruct);          // convert the actual date into a struct


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LowFractal::~LowFractal()
  {
  }
//+------------------------------------------------------------------+



double LowFractal:: getPrice()
  {

   return lowPrice ;
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LowFractal:: getLeftPeriod()
  {

   return leftPeriod ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LowFractal:: getRightPeriod()
  {

   return rightPeriod ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LowFractal:: getHour()
  {

   return dateStruct.hour ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LowFractal:: getMinute()
  {
   return dateStruct.min ;
  }
  

double LowFractal:: getHighestPeak(){

   return highestPeak ;
}



int LowFractal:: getDistance(){

   return distance ;
}


string LowFractal:: getArrowObjName(){
   return arrowObjName ;

}


datetime LowFractal:: getDate(){

   return date ;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LowFractal:: setPrice(double _price)
  {
      lowPrice = _price ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LowFractal:: setLeftPeriod(int _leftPeriod)
  {
      leftPeriod = _leftPeriod ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LowFractal:: setRightPeriod(int _rightPeriod)
  {
      rightPeriod = _rightPeriod ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LowFractal:: setHour(int _hour)
  {
      hour = _hour ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LowFractal:: setMinute(int _minute)
  {
     minute = _minute ;
  }
  
//+------------------------------------------------------------------+

void LowFractal:: setArrowObjName(string _name){
   arrowObjName = _name ;

}

 void  LowFractal::  setDistance(int _dist){
      distance = _dist ; 
 }



double LowFractal:: calculateFibPrice(double _fibLevel, double _lowPrice, double _highPrice){
   
   double difference = _highPrice - _lowPrice ;  
   double retracement = _fibLevel * difference ;
   double _fibPrice = _highPrice - retracement ;
   fibPrice = _fibPrice ;
   return fibPrice;
}



void   LowFractal:: setHighestPeak(double _highest){
   
  highestPeak = _highest ;

}

void  LowFractal::  setDate(datetime _givenDate){
   date = _givenDate;
   TimeToStruct(date,dateStruct);          // convert the actual date into a struct
}

void LowFractal:: updateDistance(){

   distance++ ;
}


