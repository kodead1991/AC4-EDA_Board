module test1
  (
    input CLK_50MHz, CLK_16MHz,
    input K1, K2, K3, K4, K5, //BUTTONS
    output LED_D3, LED_D4, LED_D5, LED_D6, LED_D7,
    output wire p28, p30, p32, p33, p38, p39, p42, p43, p44, p46
  );

  wire p0, p1; // signal declaration
  reg [32:0] cnt = 8'b0;


  always@(posedge CLK_16MHz)
    cnt = cnt + 1;

  assign p28 = cnt[6];
  assign p30 = cnt[7];
  assign p32 = cnt[8];
  assign p33 = cnt[9];
  assign p38 = cnt[10];
  assign p42 = cnt[11];
  assign p43 = cnt[20];
  assign p44 = cnt[21];
  assign p46 = cnt[22];

  assign LED_D3 = cnt[24];
  assign LED_D4 = cnt[25];
  assign LED_D5 = cnt[26];

endmodule
