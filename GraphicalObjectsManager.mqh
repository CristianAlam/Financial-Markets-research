//+------------------------------------------------------------------+
//|                                      GraphicalObjectsManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class GraphicalObjectsManager
  {
private:
                     int verticalLineCounter ;
public:
                     GraphicalObjectsManager();
                    ~GraphicalObjectsManager();
                    

   void              addZoneButton();
   void              addStopLossButton();
   void              addTakeProfitButton();
   void              addSetTakeProfitButton();
   void              addConfirmButton();
   void              addDeleteButton();
   void              addPrintFractalsButton();
   void              addPrintZonesButton();
   void              addTakeBuyTradeButton();
   void              addTakeSellTradeButton();
   void              addExitExperAdvisorButton();
   void              drawRectangle(int _zoneId);
   void              drawRectangleInStrategyTester(int _zone_Id,datetime leftEdge, datetime rightEdge, double highEdgePrice, double lowEdgePrice,long _color);
   void              drawStopLossLine(string _zoneId);
   void              drawStopLossLineGandalf();
   void              drawTakeProfitLine(string _zoneId);
   void              drawVerticalLine(long _color, datetime _time);
   void              drawHorizontalLine(long _color, string nameOfLine,double price);
   void              drawLowFractal(int _index,long _color);
   void              drawHighFractal(int _index,long _color);
   
   void              addText ();
   void              addTextTiger();
   void              addMarketDescriptionTextTiger();
   void              addTotalRiskText ();
   
   bool EditTextGet(string &text, const long chart_ID=0, string name = "" ) ;
  
   


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphicalObjectsManager::GraphicalObjectsManager()
  {
      verticalLineCounter = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphicalObjectsManager::~GraphicalObjectsManager()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addZoneButton()
  {


   if(!ObjectCreate(0,"ZONE_ADD_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_XDISTANCE,30);
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"ZONE_ADD_BTN",OBJPROP_TEXT,"Add Zone");
      //--- set text font
      ObjectSetString(0,"ZONE_ADD_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_BORDER_COLOR,clrGray);
      //--- display in the foreground (false) or background (true)

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_BACK,back);

      //--- set button state

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_STATE,state);

      //--- enable (true) or disable (false) the mode of moving the button by mouse

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTABLE,selection);
      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTED,selection);

      //--- hide (true) or display (false) graphical object name in the object list

      // ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_HIDDEN,hidden);

      //--- set the priority for receiving the event of a mouse click in the chart

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_ZORDER,z_order);

     }
  }
  
  

void GraphicalObjectsManager:: addTakeBuyTradeButton(){



      if(!ObjectCreate(0,"BUY_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_XDISTANCE,30);
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"BUY_BTN",OBJPROP_TEXT,"Buy");
      //--- set text font
      ObjectSetString(0,"BUY_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"BUY_BTN",OBJPROP_BORDER_COLOR,clrGray);
      //--- display in the foreground (false) or background (true)

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_BACK,back);

      //--- set button state

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_STATE,state);

      //--- enable (true) or disable (false) the mode of moving the button by mouse

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTABLE,selection);
      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTED,selection);

      //--- hide (true) or display (false) graphical object name in the object list

      // ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_HIDDEN,hidden);

      //--- set the priority for receiving the event of a mouse click in the chart

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_ZORDER,z_order);

     }


}





void GraphicalObjectsManager:: addTakeSellTradeButton(){



      if(!ObjectCreate(0,"SELL_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_XDISTANCE,170);
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"SELL_BTN",OBJPROP_TEXT,"Sell");
      //--- set text font
      ObjectSetString(0,"SELL_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"SELL_BTN",OBJPROP_BORDER_COLOR,clrGray);
      //--- display in the foreground (false) or background (true)

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_BACK,back);

      //--- set button state

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_STATE,state);

      //--- enable (true) or disable (false) the mode of moving the button by mouse

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTABLE,selection);
      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_SELECTED,selection);

      //--- hide (true) or display (false) graphical object name in the object list

      // ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_HIDDEN,hidden);

      //--- set the priority for receiving the event of a mouse click in the chart

      //ObjectSetInteger(0,"ZONE_ADD_BTN",OBJPROP_ZORDER,z_order);

     }


}






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addConfirmButton()
  {

   if(!ObjectCreate(0,"CONFIRM_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the confirm button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_XDISTANCE,470);
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"CONFIRM_BTN",OBJPROP_TEXT,"Confirm Object");
      //--- set text font
      ObjectSetString(0,"CONFIRM_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"CONFIRM_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addDeleteButton()
  {
   if(!ObjectCreate(0,"DELETE_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the delete button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_XDISTANCE,310);
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"DELETE_BTN",OBJPROP_TEXT,"Delete Object");
      //--- set text font
      ObjectSetString(0,"DELETE_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"DELETE_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addExitExperAdvisorButton()
  {
   if(!ObjectCreate(0,"EXIT_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the exit button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_XDISTANCE,450);
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"EXIT_BTN",OBJPROP_TEXT,"Remove Expert");
      //--- set text font
      ObjectSetString(0,"EXIT_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_FONTSIZE,9);
      //--- set text color
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"EXIT_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager::  addPrintFractalsButton()
  {

   if(!ObjectCreate(0,"PRINT_FRACTAL_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the print fractals button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_XDISTANCE,590);
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"PRINT_FRACTAL_BTN",OBJPROP_TEXT,"Print Fractals");
      //--- set text font
      ObjectSetString(0,"PRINT_FRACTAL_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"PRINT_FRACTAL_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addPrintZonesButton()
  {
   if(!ObjectCreate(0,"PRINT_ZONES_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the print fractals button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_XDISTANCE,730);
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"PRINT_ZONES_BTN",OBJPROP_TEXT,"Print Zones");
      //--- set text font
      ObjectSetString(0,"PRINT_ZONES_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"PRINT_ZONES_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addStopLossButton()
  {
   if(!ObjectCreate(0,"ADD_SL_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the stop loss button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_XDISTANCE,30);
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_YDISTANCE,100);
      //--- set button size
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"ADD_SL_BTN",OBJPROP_TEXT,"Add SL");
      //--- set text font
      ObjectSetString(0,"ADD_SL_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"ADD_SL_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: addTakeProfitButton()
  {

       if(!ObjectCreate(0,"ADD_TP_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the take profit button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_XDISTANCE,170);
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_YDISTANCE,100);
      //--- set button size
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"ADD_TP_BTN",OBJPROP_TEXT,"Add TP");
      //--- set text font
      ObjectSetString(0,"ADD_TP_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"ADD_TP_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }
  }



void GraphicalObjectsManager:: addSetTakeProfitButton(){
     if(!ObjectCreate(0,"SET_TP_BTN",OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the take profit button! Error code = ",GetLastError());

     }
   else
     {
      ChartRedraw();
      //--- set button coordinates
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_XDISTANCE,310);
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_YDISTANCE,100);
      //--- set button size
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"SET_TP_BTN",OBJPROP_TEXT,"Set TP");
      //--- set text font
      ObjectSetString(0,"SET_TP_BTN",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"SET_TP_BTN",OBJPROP_BORDER_COLOR,clrGray);

     }
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: drawRectangle(int _zoneId)
  {

   string nameInString = IntegerToString(_zoneId);


   if(!ObjectCreate(_Symbol,nameInString,OBJ_RECTANGLE,0,iTime(_Symbol,PERIOD_CURRENT,20),iLow(_Symbol,PERIOD_CURRENT,20),iTime(_Symbol,PERIOD_CURRENT,10), iOpen(_Symbol,PERIOD_CURRENT,20)))
     {

      Print(__FUNCTION__,
            ": Failed to create a Zone! Error code = ",GetLastError());

     }

   else
     {
      ChartRedraw();
      Print("Rectangle created successfully!");
      //--- set rectangle color
      ObjectSetInteger(0,nameInString,OBJPROP_COLOR,clrDimGray);
      ObjectSetInteger(0,nameInString,OBJPROP_FILL,clrDimGray);

      ObjectSetInteger(0,nameInString,OBJPROP_SELECTABLE,true);

      ObjectSetInteger(0,nameInString,OBJPROP_SELECTED,true);


      ObjectSetInteger(0,nameInString,OBJPROP_XDISTANCE,700);
      ObjectSetInteger(0,nameInString,OBJPROP_YDISTANCE,700);


     }

  }



void GraphicalObjectsManager:: drawRectangleInStrategyTester(int _zoneId,datetime leftEdge, datetime rightEdge, double highEdgePrice, double lowEdgePrice, long _color){

       string nameInString = IntegerToString(_zoneId);

   
   if(!ObjectCreate(_Symbol,nameInString,OBJ_RECTANGLE,0,leftEdge,lowEdgePrice,rightEdge, highEdgePrice))
     {
     
      Print(__FUNCTION__,
            ": Failed to create a Zone! Error code = ",GetLastError());

     }

   else
     {
      ChartRedraw();
      Print("Rectangle created successfully!");
      //--- set rectangle color
      ObjectSetInteger(0,nameInString,OBJPROP_COLOR,_color);
      ObjectSetInteger(0,nameInString,OBJPROP_FILL,_color);
      ObjectSetInteger(0,nameInString,OBJPROP_BORDER_TYPE,0);
      ObjectSetInteger(0,nameInString,OBJPROP_BACK,true);

      ObjectSetInteger(0,nameInString,OBJPROP_SELECTABLE,true);

      ObjectSetInteger(0,nameInString,OBJPROP_SELECTED,false);


      ObjectSetInteger(0,nameInString,OBJPROP_XDISTANCE,700);
      ObjectSetInteger(0,nameInString,OBJPROP_YDISTANCE,700);
      


     }
   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphicalObjectsManager:: drawStopLossLine(string _zoneId)
  {

   string lineName = "sl" + _zoneId ;
//--- create a horizontal line
   if(!ObjectCreate(_Symbol,lineName,OBJ_HLINE,0,0,SymbolInfoDouble(_Symbol, SYMBOL_ASK)))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,lineName,OBJPROP_COLOR,clrRed);
//--- set line display style
   ObjectSetInteger(_Symbol,lineName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
   ObjectSetInteger(_Symbol,lineName,OBJPROP_WIDTH,1);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,lineName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,lineName,OBJPROP_HIDDEN,false);

//--- successful execution
  }
  
  
  void GraphicalObjectsManager:: drawTakeProfitLine(string _zoneId)
  {

   string lineName = "tp" + _zoneId ;
//--- create a horizontal line
   if(!ObjectCreate(_Symbol,lineName,OBJ_HLINE,0,0,SymbolInfoDouble(_Symbol, SYMBOL_ASK)))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,lineName,OBJPROP_COLOR,clrAqua);
//--- set line display style
   ObjectSetInteger(_Symbol,lineName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
   ObjectSetInteger(_Symbol,lineName,OBJPROP_WIDTH,0.5);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,lineName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,lineName,OBJPROP_HIDDEN,false);

//--- successful execution
  }



void GraphicalObjectsManager:: drawVerticalLine(long _color, datetime _time){
   Print("entered the drawvertical line function");
   string lineName = "vline" + IntegerToString(verticalLineCounter) ;
   verticalLineCounter++;
   
   
   
   
   if(!ObjectCreate(_Symbol,lineName,OBJ_VLINE,0,_time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,lineName,OBJPROP_COLOR,_color);
//--- set line display style
   ObjectSetInteger(_Symbol,lineName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
   ObjectSetInteger(_Symbol,lineName,OBJPROP_WIDTH,0.5);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,lineName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,lineName,OBJPROP_HIDDEN,false);
   
   
}



void GraphicalObjectsManager:: drawHorizontalLine(long _color, string nameOfLine,double price){
      
      string lineName = nameOfLine;
   
   
   
   if(!ObjectCreate(_Symbol,lineName,OBJ_HLINE,0,TimeCurrent(),price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,lineName,OBJPROP_COLOR,_color);
//--- set line display style
   ObjectSetInteger(_Symbol,lineName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
   ObjectSetInteger(_Symbol,lineName,OBJPROP_WIDTH,0.5);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,lineName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,lineName,OBJPROP_HIDDEN,false);

}

void  GraphicalObjectsManager:: addText (){

       if(!ObjectCreate(0,"textName",OBJ_EDIT,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());

     }
     
     else{
     
            
            
             ChartRedraw();
         
     
      //--- set button coordinates
      ObjectSetInteger(0,"textName",OBJPROP_XDISTANCE,300);
      ObjectSetInteger(0,"textName",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"textName",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"textName",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"textName",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"textName",OBJPROP_TEXT,"  Risk Amount");
      //--- set text font
      ObjectSetString(0,"textName",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"textName",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"textName",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"textName",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"textName",OBJPROP_BORDER_COLOR,clrGray);
     }
    
       

}


void  GraphicalObjectsManager:: addTextTiger (){

       if(!ObjectCreate(0,"clockTextTiger",OBJ_EDIT,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());

     }
     
     else{
     
            
            
             ChartRedraw();
         
     
      //--- set button coordinates
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_XDISTANCE,300);
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_XSIZE,150);
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_YSIZE,100);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,"  ");
      //--- set text font
      ObjectSetString(0,"clockTextTiger",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_FONTSIZE,20);
      //--- set text color
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"clockTextTiger",OBJPROP_BORDER_COLOR,clrGray);
     }
    
       

}



void GraphicalObjectsManager:: addMarketDescriptionTextTiger(){

   if(!ObjectCreate(0,"marketDescriptionText",OBJ_EDIT,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());

     }
     
     else{
     
            
            
             ChartRedraw();
         
     
      //--- set button coordinates
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_YDISTANCE,150);
      //--- set button size
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_XSIZE,600);
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_YSIZE,100);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"marketDescriptionText",OBJPROP_TEXT,"  ");
      //--- set text font
      ObjectSetString(0,"marketDescriptionText",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_BGCOLOR,clrGray);
      //--- set border color
      ObjectSetInteger(0,"marketDescriptionText",OBJPROP_BORDER_COLOR,clrGray);
     }


}


void  GraphicalObjectsManager:: addTotalRiskText (){

       if(!ObjectCreate(0,"totalRiskText",OBJ_EDIT,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());

     }
     
     else{
     
            
            
             ChartRedraw();
         
     
      //--- set button coordinates
      ObjectSetInteger(0,"totalRiskText",OBJPROP_XDISTANCE,700);
      ObjectSetInteger(0,"totalRiskText",OBJPROP_YDISTANCE,40);
      //--- set button size
      ObjectSetInteger(0,"totalRiskText",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"totalRiskText",OBJPROP_YSIZE,50);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(0,"totalRiskText",OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- set the text
      ObjectSetString(0,"totalRiskText",OBJPROP_TEXT,"Total Risk is: 0");
      //--- set text font
      ObjectSetString(0,"totalRiskText",OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,"totalRiskText",OBJPROP_FONTSIZE,10);
      //--- set text color
      ObjectSetInteger(0,"totalRiskText",OBJPROP_COLOR,clrWhite);
      //--- set background color
      ObjectSetInteger(0,"totalRiskText",OBJPROP_BGCOLOR,clrBlack);
      //--- set border color
      ObjectSetInteger(0,"totalRiskText",OBJPROP_BORDER_COLOR,clrBlack);
      
      ObjectSetInteger(_Symbol,"totalRiskText",OBJPROP_SELECTABLE,false);
      
      
     }
    
       

}


bool GraphicalObjectsManager::  EditTextGet(string      &text,    const long   chart_ID=0,   string name = "")
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
   


void GraphicalObjectsManager:: drawStopLossLineGandalf()
  {

   string lineName = "sl"  ;
//--- create a horizontal line
   if(!ObjectCreate(_Symbol,lineName,OBJ_HLINE,0,0,SymbolInfoDouble(_Symbol, SYMBOL_ASK)))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,lineName,OBJPROP_COLOR,clrRed);
//--- set line display style
   ObjectSetInteger(_Symbol,lineName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
   ObjectSetInteger(_Symbol,lineName,OBJPROP_WIDTH,1);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,lineName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,lineName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,lineName,OBJPROP_HIDDEN,false);

//--- successful execution
  }
  
  
  
  
void GraphicalObjectsManager:: drawLowFractal(int _index,long _color){
   
   string fractalName = "low_fractal"  ;
//--- create a horizontal line
   if(!ObjectCreate(_Symbol,fractalName,OBJ_ARROW_UP,0,iTime(_Symbol,PERIOD_CURRENT,_index),iLow(_Symbol,PERIOD_CURRENT,_index) - 0.25))
     {
      
      Print(__FUNCTION__,
            ": failed to create an arrow object! Error code = ",GetLastError());

     }
     
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_COLOR,_color);
//--- set line display style
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
  // ObjectSetInteger(_Symbol,fractalName,OBJPROP_WIDTH,1);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   //ObjectSetInteger(_Symbol,fractalName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_HIDDEN,false);
}



void GraphicalObjectsManager:: drawHighFractal(int _index,long _color){
   
   string fractalName = "high_fractal"  ;
//--- create a horizontal line
   if(!ObjectCreate(_Symbol,fractalName,OBJ_ARROW_DOWN,0,iTime(_Symbol,PERIOD_CURRENT,_index),iHigh(_Symbol,PERIOD_CURRENT,_index) + 0.25))
     {
      
      Print(__FUNCTION__,
            ": failed to create an arrow object! Error code = ",GetLastError());

     }
     
     ChartRedraw();
//--- set line color
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_COLOR,_color);
//--- set line display style
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_STYLE,STYLE_SOLID);
//--- set line width
  // ObjectSetInteger(_Symbol,fractalName,OBJPROP_WIDTH,1);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   //ObjectSetInteger(_Symbol,fractalName,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(_Symbol,fractalName,OBJPROP_HIDDEN,false);
}