module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [3:0] cmd;
input cmd_valid;
output reg IROM_EN;
output reg [5:0] IROM_A;
output reg IRB_RW;
output [7:0] IRB_D;
output reg[5:0] IRB_A;
output reg busy;
output reg done;

parameter idle=2'b00,
          load=2'b01,
          work=2'b10,
          write=2'b11;

reg [1:0] cur_st,nxt_st;
reg [7:0] buffer [63:0];
reg [2:0] x;
reg [5:0] y;
reg [5:0] temp_a ;

wire [5:0] addr1,addr2,addr3,addr4;
wire [9:0] ave;

always@(posedge clk or posedge reset)
  if(reset)
    cur_st<=load;
  else 
    cur_st<=nxt_st;
    

always@(*)
  case(cur_st)
    idle:begin
            if((cmd_valid==1))
              nxt_st=work;
            else 
              nxt_st=idle;
         end
    load:begin
           if(temp_a==6'd63)
             nxt_st=idle;
            else 
             nxt_st=load;
         end
    work:
           nxt_st=(cmd==0)?write:work;
    write:
           nxt_st=(IRB_A==63)?idle:write;
  endcase
always@(*)
   case(cur_st)
    idle:busy=0;
    load:busy=1;
    work:busy=0;
    write:busy=1;
   endcase  
    
always@(posedge clk or posedge reset)
  if(reset)
    IROM_EN<=1;
  else if(nxt_st==load)
    IROM_EN <= 1'd0;
  else
	IROM_EN <= 1'd1;
    
always@(posedge clk or posedge reset)
  if(reset)
      temp_a <=0;
  else
      temp_a <= IROM_A ;
    
always@(posedge clk or posedge reset)
  if(reset)
	IROM_A<=0;
  else if(IROM_EN == 0 )
    IROM_A <= IROM_A + 1'd1;
  else if(IROM_A==6'd63)
    IROM_A<=0;
  else
    IROM_A <= 0;

      
   ////////////////////////////////////// 
always@(*)
  if(cur_st==write)
    IRB_RW<=0;
  else
    IRB_RW<=1;

assign IRB_D=buffer[IRB_A] ;
    
always@(posedge clk)
  if(cur_st==idle)
    done<=0;
  else if(IRB_A==6'd63)
    done<=1;  
     
always@(posedge clk)
  if(cur_st==idle)
    IRB_A<=0;
  else if(cur_st==write)
    IRB_A<=IRB_A+1'd1;  
  else if(IRB_A==6'd63)
    IRB_A<=0;
 /////////////////////////////////  
always@(posedge clk or posedge reset)     
begin
  if(reset)
    begin
      y<=3'd4;
    end
    
  else if(nxt_st==work)
    case(cmd)
      4'd1:if(y<=1)
                y<=1;
              else
                y<=y-1'd1;//UP
             
      4'd2:if(y>=7)
                y<=7;
              else
                y<=y+1'd1;//DOWN
      4'd8: y<=3'd4;   
      
    endcase
end

always@(posedge clk or posedge reset)
  begin
    if(reset)
     x<= 3'd4;
     
   else if(nxt_st==work)
     case(cmd)
       4'd3: if(x<=1)
                x<=1;
              else
                x<=x-1'd1;//LEFT
             
      4'd4:if(x>=7)
                x<=7;
              else
                x<=x+1'd1;//RIGHT

      4'd8: x<=3'd4;
              //RST_XY
              
     
      endcase
  end
  
assign addr1=(y<<3)+x-6'd9;
assign addr2=(y<<3)+x-6'd8;
assign addr3=(y<<3)+x;
assign addr4=(y<<3)+x-1'd1;

assign ave=((buffer[addr1]+buffer[addr2]+buffer[addr3]+buffer[addr4])>>2 );
 
always@(posedge clk)
  if(cur_st==load)
      buffer[temp_a]<=IROM_Q; 
  else if(nxt_st==work)
    case(cmd)
              
      4'd5:begin
              buffer[addr1]<=(ave[7:0]);//AVER.
              buffer[addr2]<=(ave[7:0]);
              buffer[addr3]<=(ave[7:0]);
              buffer[addr4]<=(ave[7:0]);
              end
      4'd6:begin
              buffer[addr1]<=buffer[addr4];//MIRR. X
              buffer[addr4]<=buffer[addr1];
              buffer[addr3]<=buffer[addr2];
              buffer[addr2]<=buffer[addr3];
              end
      4'd7:begin
              buffer[addr1]<=buffer[addr2];
              buffer[addr2]<=buffer[addr1];
              buffer[addr3]<=buffer[addr4];
              buffer[addr4]<=buffer[addr3]; //MIRR. Y
              end
      
      4'd9:begin 
              buffer[addr1]<=(buffer[addr1]>8'd191)?8'd255:buffer[addr1]+8'd64;
              buffer[addr2]<=(buffer[addr2]>8'd191)?8'd255:buffer[addr2]+8'd64;
              buffer[addr3]<=(buffer[addr3]>8'd191)?8'd255:buffer[addr3]+8'd64;
              buffer[addr4]<=(buffer[addr4]>8'd191)?8'd255:buffer[addr4]+8'd64;//ENHANCE
              end
      4'd10:begin
              buffer[addr1]<=(buffer[addr1]>8'd64)?buffer[addr1]-8'd64:8'd0;
              buffer[addr2]<=(buffer[addr2]>8'd64)?buffer[addr2]-8'd64:8'd0;
              buffer[addr3]<=(buffer[addr3]>8'd64)?buffer[addr3]-8'd64:8'd0;
              buffer[addr4]<=(buffer[addr4]>8'd64)?buffer[addr4]-8'd64:8'd0; //DECRESE
              end
      4'd11:begin
              buffer[addr1]<=(buffer[addr1]>8'd128)?8'd255:8'd0;
              buffer[addr2]<=(buffer[addr2]>8'd128)?8'd255:8'd0;
              buffer[addr3]<=(buffer[addr3]>8'd128)?8'd255:8'd0;
              buffer[addr4]<=(buffer[addr4]>8'd128)?8'd255:8'd0;//THRESHOLD
              end
      4'd12:begin
              buffer[addr1]<=(buffer[addr1]>8'd128)?8'd0:8'd255;
              buffer[addr2]<=(buffer[addr2]>8'd128)?8'd0:8'd255;
              buffer[addr3]<=(buffer[addr3]>8'd128)?8'd0:8'd255;
              buffer[addr4]<=(buffer[addr4]>8'd128)?8'd0:8'd255;//INV. THRES.
              end
      endcase 
	  

	  
endmodule
