//+------------------------------------------------------------------+
//|                                         HighFractalContainer.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "HighFractal.mqh"
#include  <library_functions.mqh>
#define  SIZE 700

double input arrowDistanceHighs ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HighFractalContainer
  {
private:
   HighFractal*          highFractals[SIZE];
   int freeIndex ;
   double range ;
   ENUM_TIMEFRAMES timeFrame ;
public:
                     HighFractalContainer(ENUM_TIMEFRAMES _timeFrame);
                    ~HighFractalContainer();

   //GETTERS

   HighFractal*       getHighFractal(int _index) {return highFractals[_index] ;} // returns the fractal using its index in the array
   int               getFreeIndex() {return freeIndex ; }

   //SETTERS
   void              setRange(double _range) {range = _range ;}
   
   // OTHER FUNCTIONS
   void              addHighFractal(HighFractal* _highFractal); // adds high fractal to the high fractals array
   void              printHighFractals(); // prints the data of every high fractal in the highFractals[] array 
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighFractalContainer::HighFractalContainer(ENUM_TIMEFRAMES _timeFrame)
  {
  timeFrame = _timeFrame;
  freeIndex = 0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighFractalContainer::~HighFractalContainer()
  {
  
   for(int i=0; i<SIZE; i++) // free the highFractals array
     {
      delete highFractals[i] ;
     }
  }
//+------------------------------------------------------------------+

void HighFractalContainer:: addHighFractal(HighFractal* _highFractal){
   
   
   if(freeIndex == SIZE) // in this case we are adding a new fractal but the array is full so we need to do the following
     {
      ObjectDelete(_Symbol,highFractals[0].getArrowObjName()); // delete the object arrow of the deleted fractal
      

      ObjectCreate(_Symbol,_highFractal.getArrowObjName(),OBJ_ARROW_DOWN,0,iTime(Symbol(),timeFrame,_highFractal.getDistance()),iHigh(Symbol(),timeFrame,_highFractal.getDistance()) + arrowDistanceHighs); // create the new object arrow of the new fractal
      ObjectSetInteger(0,_highFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);
      delete highFractals[0]; // free the memory allocated for the fractal in the first index (because we wanna remove it from the array)

      
      for(int i=0; i< SIZE-1 ; i++)  // shift the array
        {

         highFractals[i] = highFractals[i+1];
        }
      
      highFractals[freeIndex - 1] = _highFractal ;
   
      
     }
     
      else
     {

      if(freeIndex == 0)  // case of the first fractal
        {

         highFractals[freeIndex] = _highFractal ;        
         freeIndex++;

         ObjectCreate(_Symbol,_highFractal.getArrowObjName(),OBJ_ARROW_DOWN,0,iTime(Symbol(),timeFrame,_highFractal.getDistance()),iHigh(Symbol(),timeFrame,_highFractal.getDistance()) + arrowDistanceHighs);
         ObjectSetInteger(0,_highFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);

        }
      else
        { 
         highFractals[freeIndex] = _highFractal ;
         freeIndex++;
         ObjectCreate(_Symbol,_highFractal.getArrowObjName(),OBJ_ARROW_DOWN,0,iTime(Symbol(),timeFrame,_highFractal.getDistance()),iHigh(Symbol(),timeFrame,_highFractal.getDistance()) + arrowDistanceHighs);
         ObjectSetInteger(0,_highFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);
                 

        }


     }
   
}


 void HighFractalContainer:: printHighFractals()
  {

   if(freeIndex > 0)
     {
      for(int i=0 ; i<freeIndex ; i++)
        {
        
          Print(" Fractal " + i + "   Time: ", highFractals[i].getHour() + ":" + highFractals[i].getMinute()+ "   Price: "
               + highFractals[i].getPrice() + "  Distance: " + highFractals[i].getDistance() );

        }

     }

  }
