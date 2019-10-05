`timescale 10ns / 1ps
module mux(Sel, A, B, C, D, Q);
input A, B, C, D;
input [1:0] Sel;
output Q;


//*****************************************
    wire n0,n1,aa,ab,ac,ad;
    not sel0(n0,Sel[0]);
    not sel1(n1,Sel[1]);
    and a1(aa,n0,n1,A);
    and a2(ab,Sel[0],n1,B);
    and a3(ac,Sel[1],n0,C);
    and a4(ad,Sel[0],Sel[1],D);
    or or1(Q,aa,ab,ac,ad);
    
    
    
    
//*****************************************

endmodule
