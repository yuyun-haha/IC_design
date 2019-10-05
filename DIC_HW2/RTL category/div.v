`timescale 1ns / 10ps
module div(out, in1, in2, dbz);

parameter width = 6;

input  	[width-1:0] in1; // Dividend   
input  	[width-1:0] in2; // Divisor
output  [width-1:0] out; // Quotient
output dbz;

/********************************/

reg [width-1:0] out;
reg [width-1:0] in1_;
reg [width-1:0] in3,in4,in5,in6,in7,in8;
reg [10:0] in2_;


assign dbz=(in2==0)?1:0;


 always@(*)
  begin
   
   in1_=in1;
   in2_={in2,5'b0};  
  
  end
   
   
always@(*)
    
    if(in1_<in2_)
        begin
        out[5]=0;
        in3=in1_;
        end
    else
      begin
        out[5]=1;
        in3=in1_-in2_;
      end
      
always@(*)    
    if(in3<(in2_>>1))
       begin
        out[4]=0;
        in4=in3;
        end
    else
      begin
        out[4]=1;
        in4=in3-(in2_>>1); 
      end 
      
always@(*)   
    if(in4<(in2_>>2))
       begin
        out[3]=0;
        in5=in4;
        end
    else
      begin
        out[3]=1;
        in5=in4-(in2_>>2);
         
      end 
      
always@(*)      
      if(in5<(in2_>>3))
      begin
        out[2]=0;
        in6=in5;
        end
    else
      begin
        out[2]=1;
        in6=in5-(in2_>>3);
         
      end 
      
always@(*)      
      if(in6<(in2_>>4))
       begin
        out[1]=0;
        in7=in6;
        end
    else
      begin
        out[1]=1;
        in7=in6-(in2_>>4);
      end 
  
always@(*)  
  if(in7<(in2_>>5))
      begin
        out[0]=0;
        in8=in7;
        end
    else
      begin
        out[0]=1;
        in8=in7-(in2_>>4); 
      end 
 
/********************************/

endmodule