`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input clk;
input reset;
output reg [13:0] 	gray_addr;
output reg gray_req;
input gray_ready;
input [7:0] gray_data;
output reg[13:0] lbp_addr;
output reg lbp_valid;
output reg [7:0] lbp_data;
output reg finish;

reg [3:0]addr_counter;
reg [3:0]buffer_counter;
wire[13:0]load_addr [8:0];
reg[13:0] middle;
reg[7:0]buffer [8:0];

parameter load=2'b00,
          write=2'b01,
          over=2'b10;
reg[1:0] cur_st, nxt_st;  

//====================================================================
always@(posedge clk or posedge reset)
  if(reset)
    cur_st<=load;
  else
    cur_st<=nxt_st;

always@(*)
  case(cur_st)
    load:if((middle[7:0]==8'h00)||(middle[7:0]==8'h80)||(middle[7:0]==8'h7f)||(middle[7:0]==8'hff))
            nxt_st=write;
         else if(buffer_counter==4'd8)
            nxt_st=write;
         else 
            nxt_st=load;        
   
    write:
		 if(middle==14'h3f7e)
            nxt_st=over;
		 else if((middle[7:0]==8'h7f)||(middle[7:0]==8'hff)||(middle[7:0]==8'h7e)||(middle[7:0]==8'hfe))
            nxt_st=write;	
		 else 
		 nxt_st=load;
    over:nxt_st=load;
  endcase
  

always@(posedge clk or posedge reset)
  if(reset)
    gray_req<=0; 
  else if(cur_st==load)
    gray_req<=1;
  else
    gray_req<=0;
	
always@(posedge clk or posedge reset)
  if(reset)
    gray_addr<=14'd0;
  else if(cur_st==load)
    gray_addr<=load_addr[addr_counter];
    


always@(posedge clk or posedge reset)
  if(reset)
    buffer_counter<=0;
  else if (nxt_st==load)
    buffer_counter<=addr_counter;
  
always@(posedge clk or posedge reset)
  if(reset)
    addr_counter<=0;
  else if (cur_st==write)
    addr_counter<=0;
  else if(cur_st==load)
    addr_counter<=addr_counter+1;

assign load_addr[8]=middle+129;
assign load_addr[7]=middle+128;
assign load_addr[6]=middle+127;
assign load_addr[5]=middle+1;
assign load_addr[4]=middle;
assign load_addr[3]=middle-1;
assign load_addr[2]=middle-127;
assign load_addr[1]=middle-128;
assign load_addr[0]=middle-129;



always@(posedge clk or posedge reset)
  if(reset)
    middle<=14'd129;
  else if(cur_st==write)
    middle<=middle+1;
    
///////////////////////////
always@(posedge clk or posedge reset)
  if(reset)
	lbp_valid<=0;
  else if(cur_st==write)
    lbp_valid<=1;
  else 
    lbp_valid<=0;
	
always@(posedge clk)
  if(cur_st==load)
    buffer[buffer_counter]<=gray_data;
	

	
always@(posedge clk or posedge reset)
  if(reset)
    lbp_data=0;
  else if((middle[7:0]==8'h00)||(middle[7:0]==8'h80)||(middle[7:0]==8'h7f)||(middle[7:0]==8'hff))
     lbp_data=0;
  else if(cur_st==write)
    begin
     lbp_data[7]=(buffer[8]<buffer[4])?0:1;
     lbp_data[6]=(buffer[7]<buffer[4])?0:1;
     lbp_data[5]=(buffer[6]<buffer[4])?0:1;
     lbp_data[4]=(buffer[5]<buffer[4])?0:1;
     lbp_data[3]=(buffer[3]<buffer[4])?0:1;
     lbp_data[2]=(buffer[2]<buffer[4])?0:1;
     lbp_data[1]=(buffer[1]<buffer[4])?0:1;
     lbp_data[0]=(buffer[0]<buffer[4])?0:1;
    end

 always@(posedge clk or posedge reset)
  if(reset)
    lbp_addr<=14'd0;
  else if(cur_st==write)
    lbp_addr<=middle;   
always@(posedge clk or posedge reset)
  if(reset)
    finish=0;
  else if(nxt_st==over)
    finish=1;
//====================================================================
endmodule
