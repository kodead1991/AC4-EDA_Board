import pkg::*;

module UART_RX #(
    parameter int CLK_FREQ    = CLK_FREQ_16MHZ,
    parameter int BAUD_RATE   = BAUD_115200,
    parameter int DATA_BITS   = DATA_BITS_8,
    parameter parity_t PARITY_TYPE = PARITY_NONE,
    parameter int STOP_BITS   = STOP_BITS_1,
    parameter int FIFO_DEPTH  = FIFO_DEPTH_16
  )(
    // Clock and Reset
    input  wire i_Clk           ,
    input  wire i_nRst          , // Активный низкий уровень
    // UART
    input  wire i_Rx            , // Входная линия RX
    // Data Output (FIFO)
    output wire [DATA_BITS-1:0] o_Data,
    output wire  o_DataValid     ,
    input  wire i_DataRE        , // Подтверждение чтения данных
    // Status
    output wire o_FIFO_Full     ,
    output wire o_FIFO_Empty    ,
    output wire o_FrameError ,
    output wire o_ParityError
  );

  // ============================================================
  // Local parameters (расчетные константы)
  // ============================================================
  localparam BIT_PERIOD      = (CLK_FREQ / BAUD_RATE) - 1;
  localparam HALF_BIT        = BIT_PERIOD / 2;
  localparam PARITY_ENABLE   = (PARITY_TYPE != PARITY_NONE);
  localparam STOP_BITS_TOTAL = STOP_BITS;

  // Размер счетчика для BIT_PERIOD (определяем разрядность)
  localparam int BIT_CNT_WIDTH = $clog2(CLK_FREQ / BAUD_RATE);

  //описание автомата
  localparam s_Idle    = 3'd0;
  localparam s_Start   = 3'd1;
  localparam s_Receive = 3'd2;
  localparam s_Parity  = 3'd3;
  localparam s_Stop    = 3'd4;
  reg [2:0]  r_State   = s_Idle;

  // ============================================================
  // Устранение метастабильности на Rx
  // ============================================================
  reg r_Rx_meta;
  reg r_Rx_stable;

  always @(posedge i_Clk or negedge i_nRst) begin
    if (!i_nRst) begin
      r_Rx_meta <= 1'b1;
      r_Rx_stable <= 1'b1;
    end
    else begin
      r_Rx_meta <= i_Rx;     // первый флоп (может быть метастабильным)
      r_Rx_stable <= r_Rx_meta;  // второй флоп (стабилизирует)
    end
  end

  // ============================================================
  // Устранение сбоев на Rx
  // ============================================================
  reg [2:0] r_Rx_Sync = 3'b111;

  always @(posedge i_Clk or negedge i_nRst) begin
    if (!i_nRst) begin
      r_Rx_Sync <= 3'b111;
    end
    else begin
      r_Rx_Sync <= {r_Rx_Sync[1:0],r_Rx_stable};
    end
  end

  wire w_Rx_Synch =
       (r_Rx_Sync[2] & r_Rx_Sync[1]) |
       (r_Rx_Sync[2] & r_Rx_Sync[0]) |
       (r_Rx_Sync[1] & r_Rx_Sync[0]);

  // ============================================================
  // Конечный автомат приёмника
  // ============================================================
  reg [BIT_CNT_WIDTH-1:0] r_CntClk = 0;
  reg [              3:0] r_CntBit = 0;
  reg [    DATA_BITS-1:0] r_Data = 0;
  reg                     r_Parity = 0;
  reg                     r_ParityError = 0;
  reg                     r_FrameError = 0;
  reg                     r_DataValid = 0;

  always @(posedge i_Clk or negedge i_nRst) begin
    if (!i_nRst) begin
      r_State        <= s_Idle;
      r_CntClk       <= 0;
      r_CntBit       <= 0;
      r_Data <= 0;
      r_DataValid <= 0;
      r_Parity <= 0;
      r_ParityError <= 0;
      r_FrameError <= 0;
    end
    else begin
      case (r_State)
        //-------------------------------------------------------------
        s_Idle : begin
          r_CntClk <= 0;
          r_CntBit <= 0;
          r_DataValid <= 0;
          r_Parity <= 0;
          if (!w_Rx_Synch)
            r_State <= s_Start;
        end
        //-------------------------------------------------------------
        s_Start : begin
          if (r_CntClk == HALF_BIT)
            if (w_Rx_Synch == 0) begin
              r_State  <= s_Receive;
              r_CntClk <= 0;
            end
            else begin
              r_State <= s_Idle;
            end
          else
            r_CntClk <= r_CntClk + 1;
        end
        //-------------------------------------------------------------
        s_Receive : begin
          if (r_CntClk == BIT_PERIOD) begin
            r_CntClk <= 0;
            r_Data[r_CntBit] <= w_Rx_Synch;
            r_Parity <= r_Parity ^ w_Rx_Synch;

            if (r_CntBit == DATA_BITS-1) begin
              r_State <= s_Parity;
              r_CntBit <= 0;
            end
            else begin
              r_CntBit <= r_CntBit + 1;
            end

          end
          else begin
            r_CntClk <= r_CntClk + 1;
          end
        end
        //-------------------------------------------------------------
        s_Parity : begin
          if (r_CntClk == BIT_PERIOD) begin
            if (
              (r_Parity == w_Rx_Synch && PARITY_TYPE == PARITY_ODD)
              ||
              (r_Parity != w_Rx_Synch && PARITY_TYPE == PARITY_EVEN)
            )
              r_ParityError <= 1'b0;
            else
              r_ParityError <= 1'b1;

            r_State <= s_Stop;
          end
          else begin
            r_CntClk <= r_CntClk + 1;
          end
        end
        //-------------------------------------------------------------
        s_Stop : begin
          if (r_CntClk == BIT_PERIOD) begin
            if (w_Rx_Synch)
              r_DataValid <= 1'b1;
            else
              r_FrameError <= 1'b1;

            r_State <= s_Idle;
          end
          else begin
            r_CntClk <= r_CntClk + 1;
          end
        end
        //-------------------------------------------------------------
        default :
          r_State <= s_Idle;
      endcase
    end
  end

  assign o_Data = r_Data;
  assign o_DataValid = r_DataValid;
  assign o_FrameError = r_FrameError;


endmodule
