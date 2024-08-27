// which FX pair is moving the most up or down over the last 30 minutes in terms of % ( not pips due to JPY ) 
#include <Trade/Trade.mqh> // Standard Library Trade Class
CTrade trade;
ulong _ticket_buy,_ticket_sell;

int input scan_minutes=30;
input double lot_size=0.10; 
input bool take_trade=true; 

string best_buy,best_sell;
double ll,hh;

int OnInit()
{
   FindBest();
   Print("To Buy ",best_buy," To Sell ",best_sell);
   if(take_trade)TakeTrade();
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}
void OnTick()
{
   if(!PositionSelectByTicket(_ticket_buy)) _ticket_buy=0; 
   if(!PositionSelectByTicket(_ticket_sell)) _ticket_sell=0;
   
   if(_ticket_buy==0 && _ticket_sell==0 && take_trade) 
   {
      FindBest();
      Print("To Buy ",best_buy," To Sell ",best_sell);
      if(take_trade)TakeTrade();
   }
}

void FindBest()
{
   double change_percentage_buy=0,change_percentage_sell=2,lowest,highest,now,tmp;
   string sym;
   
   for(int s=0;s<SymbolsTotal(true);s++)
   {
      sym=SymbolName(s,true);
      if(SymbolInfoString(sym,SYMBOL_SECTOR_NAME)!="Currency") continue;
   
      now=SymbolInfoDouble(sym,SYMBOL_BID);
      lowest=iLow(sym,PERIOD_M1,iLowest(sym,PERIOD_M1,MODE_LOW,scan_minutes,0));
      highest=iHigh(sym,PERIOD_M1,iHighest(sym,PERIOD_M1,MODE_HIGH,scan_minutes,0));
      
      tmp=now/lowest;
      if(tmp>change_percentage_buy)
      {
         ll=lowest;
         change_percentage_buy=tmp;
         best_buy=sym;
         Print(tmp," Buy ",sym);
      }
      
      tmp=now/highest;
      if(tmp<change_percentage_sell)
      {
         hh=highest;
         change_percentage_sell=tmp;
         best_sell=sym;
         Print(tmp," Sell ",sym);
      }   
   }
}

void TakeTrade()
{
   double entry=SymbolInfoDouble(best_buy,SYMBOL_ASK);
   if(trade.Buy(lot_size,best_buy,entry,ll,entry+((entry-ll)/2.0),NULL))
   {
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE) _ticket_buy=trade.ResultOrder();
   }
   
   entry=SymbolInfoDouble(best_sell,SYMBOL_BID);
   if(trade.Sell(lot_size,best_sell,entry,hh,entry-((hh-entry)/2.0),NULL))
   {
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE) _ticket_sell=trade.ResultOrder();
   }
}
