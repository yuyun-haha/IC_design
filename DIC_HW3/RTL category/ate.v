module ate(clk,reset,pix_data,bin,threshold);
  
input clk;
input reset;
input [7:0] pix_data;
output bin;
output [7:0] threshold;

reg [7:0] threshold;
reg bin;
reg [7:0] buffer [63:0];

reg [6:0] count;   //0~127
reg [7:0] min;
reg [7:0] max;   
reg [4:0] block_count=0; //0~31

reg [7:0] temp_threshold;

always@(*)
begin
  if(count==7'd0)  
       temp_threshold<=((max+min+1)>>1);
       
  else temp_threshold<=0;
end



always@(posedge clk,posedge reset)
begin 
      if(reset)
        count<=0;
      else if(count==7'd63)
        count<=0;
      else
       count<=count+1; 
end

always@(posedge clk)
begin
 if(count==7'd63)
    block_count<=block_count+1;
end


always@(posedge clk)
begin
     buffer[count]<=pix_data;  
end


always@(posedge clk)
begin 
        if (count==7'd0)
           max<=pix_data;
        else if(block_count==0||block_count==6||block_count==12||block_count==18||block_count==5||block_count==11||block_count==17||block_count==23)
           max<=0;   
        else if(pix_data>max)
           max<=pix_data;
end


always@(posedge clk)
begin 
        if(count==7'd0)
           min<=pix_data;          
        else if (block_count==0||block_count==6||block_count==12||block_count==18||block_count==5||block_count==11||block_count==17||block_count==23)
            min<=0;
        else if(pix_data<min)
            min<=pix_data;
end


always@(posedge clk)
  if(count==7'd0)
       threshold<=temp_threshold;


always@(posedge clk) 
begin
      if (block_count==0||block_count==6||block_count==12||block_count==18||block_count==1||block_count==7||block_count==13||block_count==19||block_count==24)
           bin<=0;
      else if(count==0)
         if(buffer[0]>=temp_threshold)
           bin<=1;
         else
           bin<=0; 
      else if(buffer[count]>=threshold)
           bin<=1;     
      else
           bin<=0;
       
end

endmodule
