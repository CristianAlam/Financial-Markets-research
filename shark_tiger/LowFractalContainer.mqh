//+------------------------------------------------------------------+
//|                                          LowFractalContainer.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "LowFractal.mqh"
#include  <library_functions.mqh>
#define  SIZE 700

double input arrowDistanceLows ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LowFractalContainer
  {
private:
   LowFractal*          lowFractals[SIZE];
   int freeIndex ;
   double range ;
   ENUM_TIMEFRAMES timeFrame ;
public:
                     LowFractalContainer(ENUM_TIMEFRAMES _timeFrame);
                    ~LowFractalContainer();

   //GETTERS

   LowFractal*       getLowFractal(int _index) {return lowFractals[_index] ;} // returns the fractal using its index in the array
   int               getFreeIndex() {return freeIndex ; }

   //SETTERS
   void              setRange(double _range) {range = _range ;}
   
   // OTHER FUNCTIONS
   void              addLowFractal(LowFractal* _lowFractal); // adds low fractal to the low fractals array
   void              printLowFractals(); // prints all low fractals data
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LowFractalContainer::LowFractalContainer(ENUM_TIMEFRAMES _timeFrame)
  {
  timeFrame = _timeFrame ;
  freeIndex = 0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LowFractalContainer::~LowFractalContainer()
  {
  
   for(int i=0; i<SIZE; i++) // free the lowFractals array
     {
      delete lowFractals[i] ;
     }
  }
//+------------------------------------------------------------------+

void LowFractalContainer:: addLowFractal(LowFractal* _lowFractal){
   
   
   if(freeIndex == SIZE) // in this case we are adding a new fractal but the array is full so we need to do the following
     {
      ObjectDelete(_Symbol,lowFractals[0].getArrowObjName()); // delete the object arrow of the deleted fractal
      

      ObjectCreate(_Symbol,_lowFractal.getArrowObjName(),OBJ_ARROW_UP,0,iTime(Symbol(),timeFrame,_lowFractal.getDistance()),iLow(Symbol(),timeFrame,_lowFractal.getDistance()) - arrowDistanceLows); // create the new object arrow of the new fractal
      ObjectSetInteger(0,_lowFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);
      delete lowFractals[0]; // free the memory allocated for the fractal in the first index (because we wanna remove it from the array)

      
      for(int i=0; i< SIZE-1 ; i++)  // shift the array
        {

         lowFractals[i] = lowFractals[i+1];
        }
      
      lowFractals[freeIndex - 1] = _lowFractal ;
   
      
     }
     
      else
     {

      if(freeIndex == 0)  // case of the first fractal
        {

         lowFractals[freeIndex] = _lowFractal ;        
         freeIndex++;

         ObjectCreate(_Symbol,_lowFractal.getArrowObjName(),OBJ_ARROW_UP,0,iTime(Symbol(),timeFrame,_lowFractal.getDistance()),iLow(Symbol(),timeFrame,_lowFractal.getDistance()) - arrowDistanceLows);
         ObjectSetInteger(0,_lowFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);

        }
      else
        { 
         lowFractals[freeIndex] = _lowFractal ;
         freeIndex++;
         ObjectCreate(_Symbol,_lowFractal.getArrowObjName(),OBJ_ARROW_UP,0,iTime(Symbol(),timeFrame,_lowFractal.getDistance()),iLow(Symbol(),timeFrame,_lowFractal.getDistance()) - arrowDistanceLows);
         ObjectSetInteger(0,_lowFractal.getArrowObjName(),OBJPROP_COLOR,clrWhite);
                 

        }


     }
   
}


 void LowFractalContainer:: printLowFractals()
  {

   if(freeIndex > 0)
     {
      
      for(int i=0 ; i<freeIndex ; i++)
        {
        
         Print(" Fractal " + i + "   Time: ", lowFractals[i].getHour() + ":" + lowFractals[i].getMinute()+ "   Price: "
               + lowFractals[i].getPrice() + "  Distance: " + lowFractals[i].getDistance() );

        }

     }

  }
  
  
  
  
 