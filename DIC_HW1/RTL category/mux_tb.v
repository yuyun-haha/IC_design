`timescale 10ns / 1ps
`define CYCLE 5
module mux_tb;

reg A, B, C, D;
reg [1:0] Sel;

wire Q;

integer num = 1;
integer i, j;
integer err = 0;
integer ans;

mux mux(.Sel(Sel), .A(A), .B(B), .C(C), .D(D), .Q(Q));

initial begin
  for(i=0;i<16;i=i+1)  begin
    for(j=0;j<4;j=j+1)  begin
      {A, B, C, D} = i;
      Sel = j;
      #`CYCLE;
      ans = (Sel == 2'd0) ? A :
            (Sel == 2'd1) ? B :
            (Sel == 2'd2) ? C : D;
            
      if(ans[0] == Q)
        $display("%d data is correct", num);
      else begin
        $display("%d data is error %b, correct is %b", num, Q, ans[0]);
        err = err + 1;
      end
      num = num + 1;
    end
  end
  
  if(err == 0) begin
    $display("-------------------PASS-------------------");
    $display("All data have been generated successfully!");    
  end else begin
    $display("-------------------ERROR-------------------");
    $display("There are %d errors!", err);
  end
    
  #10 $stop;
  
end
endmodule
