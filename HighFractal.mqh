//+------------------------------------------------------------------+
//|                                                  HighFractal.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class HighFractal
  {

private:

   double highPrice ;
   int               leftPeriod;
   int               rightPeriod;

   MqlDateTime dateStruct ;
   datetime date ;

   double            sellLimitPrice; // the fib level price , based on this fractal
   double lowestPeak ; // the highest price reached, after the fractal was formed
   int hour ;
   int               minute;
   int distance ; // holds the number of candles from this fractal until the current live candle
   string arrowObjName ;
   double fibPrice ;

public:
                     HighFractal();
                     HighFractal(double _price, int _leftPeriod, int _rightPeriod, datetime _date,ENUM_TIMEFRAMES _tf);
                    ~HighFractal();



   // GETTERS

   double            getPrice();
   int               getLeftPeriod();
   int               getRightPeriod();
   int               getHour();
   int               getMinute();
   double            getLowestPeak();
   int               getDistance();
   string            getArrowObjName();
   datetime          getDate();
   // SETTERS

   void              setPrice(double _price);
   void              setLeftPeriod(int _leftPeriod);
   void              setRightPeriod(int _rightPeriod);
   void              setHour(int _hour);
   void              setMinute(int _minute);
   void              setLowestPeak(double _highest);
   void              setArrowObjName(string _name);
   void              setDistance(int _dist);
   void              setDate(datetime _givenDate);


   // OTHER FUNCTIONS

   double            calculateFibPrice(double _fibLevel, double _highPrice, double _lowPrice); // calculate the fibonacci price based on the given level, and saves the price in the fibPrice88 variable in the object
   void              updateDistance();
   

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighFractal::HighFractal()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighFractal::HighFractal(double _price, int _leftPeriod, int _rightPeriod,datetime _date,ENUM_TIMEFRAMES _tf)
  {
// the constructor sets the data to the attribues , and calculates the real time of the fractal , because the given minute and hour
// are not the real time, they are the time of when the fractal was "known to be a fractal", which is after _righPeriod amount of candles

   highPrice  = _price ;
   leftPeriod = _leftPeriod;
   rightPeriod = _rightPeriod;
   sellLimitPrice = -1 ;
   distance = _rightPeriod+1;
   arrowObjName = " " ;
   lowestPeak = -1; 


   date = iTime(_Symbol,_tf,_rightPeriod+1); // bring the actual date of the fractal
   TimeToStruct(date,dateStruct);          // convert the actual date into a struct


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighFractal::~HighFractal()
  {
  }
//+------------------------------------------------------------------+



double HighFractal:: getPrice()
  {

   return highPrice ;
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HighFractal:: getLeftPeriod()
  {

   return leftPeriod ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HighFractal:: getRightPeriod()
  {

   return rightPeriod ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HighFractal:: getHour()
  {

   return dateStruct.hour ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HighFractal:: getMinute()
  {
   return dateStruct.min ;
  }
  

double HighFractal:: getLowestPeak(){

   return lowestPeak ;
}



int HighFractal:: getDistance(){

   return distance ;
}


string HighFractal:: getArrowObjName(){
   return arrowObjName ;

}


datetime HighFractal:: getDate(){

   return date ;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HighFractal:: setPrice(double _price)
  {
      highPrice = _price ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HighFractal:: setLeftPeriod(int _leftPeriod)
  {
      leftPeriod = _leftPeriod ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HighFractal:: setRightPeriod(int _rightPeriod)
  {
      rightPeriod = _rightPeriod ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HighFractal:: setHour(int _hour)
  {
      hour = _hour ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HighFractal:: setMinute(int _minute)
  {
     minute = _minute ;
  }
  
//+------------------------------------------------------------------+

void HighFractal:: setArrowObjName(string _name){
   arrowObjName = _name ;

}

 void  HighFractal::  setDistance(int _dist){
      distance = _dist ; 
 }



double HighFractal:: calculateFibPrice(double _fibLevel, double _highPrice, double _lowPrice){
   
   double difference = _lowPrice - _highPrice ;
   difference = difference*-1 ;  
   double retracement = _fibLevel * difference ;
   double _fibPrice = _lowPrice + retracement ;
   fibPrice = _fibPrice ;
   return fibPrice;
}



void   HighFractal:: setLowestPeak(double _lowest){
   
  lowestPeak = _lowest ;

}

void  HighFractal::  setDate(datetime _givenDate){
   date = _givenDate;
   TimeToStruct(date,dateStruct);          // convert the actual date into a struct
}

void HighFractal:: updateDistance(){

   distance++ ;
}
//+------------------------------------------------------------------+
