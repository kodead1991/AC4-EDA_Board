module test2
  (
    input CLK_50MHz, CLK_16MHz,
    input K1, K2, K3, K4, K5, //BUTTONS
    output LED_D3, LED_D4, LED_D5, LED_D6, LED_D7,
    output p46, p30, p32, p33, p38, p39, p42, p43, p44, p49,
    input p89, //TX
    output p28 //RX
  );


  assign LED_D3 = 1'b0;
  assign LED_D4 = 1'b0;
  assign LED_D5 = 1'b0;

  wire w_UART_RX;
  reg [7:0] w_UART_Data;
  reg w_UART_DataValid;

  UART_RX (
      .i_Clk(CLK_16MHz),
      .i_nRst(1'b1),
      .i_Rx(w_UART_Rx),
      .o_Data(w_UART_Data),
      .o_DataValid(w_UART_DataValid),
      .i_DataRE(1'b0),
      .o_FIFO_Full(),
      .o_FIFO_Empty(),
      .o_FrameError(),
      .o_ParityError()
    );

  assign w_UART_Rx = p89;

  assign w_UART_Tx = p89;
  assign p28 = w_UART_Tx;

  assign p46 = w_UART_Data[7];
  assign p30 = w_UART_Data[6];
  assign p32 = w_UART_Data[5];
  assign p33 = w_UART_Data[4];
  assign p38 = w_UART_Data[3];
  assign p42 = w_UART_Data[2];
  assign p43 = w_UART_Data[1];
  assign p44 = w_UART_Data[0];
  assign p49 = w_UART_DataValid;


endmodule
