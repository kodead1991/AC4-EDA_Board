package pkg;

  // ============================================================
  // Тактовые частоты
  // ============================================================
  parameter int CLK_FREQ_50MHZ  = 50_000_000;
  parameter int CLK_FREQ_16MHZ  = 16_000_000;
  parameter int CLK_FREQ_100MHZ = 100_000_000;

  // ============================================================
  // Скорости UART
  // ============================================================
  parameter int BAUD_9600   = 9_600;
  parameter int BAUD_19200  = 19_200;
  parameter int BAUD_38400  = 38_400;
  parameter int BAUD_57600  = 57_600;
  parameter int BAUD_115200 = 115_200;
  parameter int BAUD_230400 = 230_400;

  // ============================================================
  // Формат данных
  // ============================================================
  parameter int DATA_BITS_7 = 7;
  parameter int DATA_BITS_8 = 8;
  parameter int DATA_BITS_9 = 9;

  // ============================================================
  // Типы четности
  // ============================================================
  typedef enum logic [1:0] {
            PARITY_NONE = 2'd0,
            PARITY_ODD  = 2'd1,
            PARITY_EVEN = 2'd2
          } parity_t;

  // ============================================================
  // Стоп-биты
  // ============================================================
  parameter int STOP_BITS_1 = 1;
  parameter int STOP_BITS_2 = 2;

  // ============================================================
  // FIFO
  // ============================================================
  parameter int FIFO_DEPTH_16  = 16;
  parameter int FIFO_DEPTH_32  = 32;
  parameter int FIFO_DEPTH_64  = 64;
  parameter int FIFO_DEPTH_128 = 128;

  // ============================================================
  // 7-сегментный дисплей (общий анод - active LOW)
  //    A
  //  F   B
  //    G
  //  E   C
  //    D   DP
  // ============================================================

  // Цифры
  parameter logic [7:0] SEG_0 = 8'b11000000;  // 0
  parameter logic [7:0] SEG_1 = 8'b11111001;  // 1
  parameter logic [7:0] SEG_2 = 8'b10100100;  // 2
  parameter logic [7:0] SEG_3 = 8'b10110000;  // 3
  parameter logic [7:0] SEG_4 = 8'b10011001;  // 4
  parameter logic [7:0] SEG_5 = 8'b10010010;  // 5
  parameter logic [7:0] SEG_6 = 8'b10000010;  // 6
  parameter logic [7:0] SEG_7 = 8'b11111000;  // 7
  parameter logic [7:0] SEG_8 = 8'b10000000;  // 8
  parameter logic [7:0] SEG_9 = 8'b10010000;  // 9

  // Буквы
  parameter logic [7:0] SEG_A = 8'b10001000;  // A
  parameter logic [7:0] SEG_B = 8'b10000011;  // B
  parameter logic [7:0] SEG_C = 8'b11000110;  // C
  parameter logic [7:0] SEG_D = 8'b10100001;  // D
  parameter logic [7:0] SEG_E = 8'b10000110;  // E
  parameter logic [7:0] SEG_F = 8'b10001110;  // F

  // Дополнительные символы
  parameter logic [7:0] SEG_MINUS  = 8'b10111111;  // - (минус, только сегмент G)
  parameter logic [7:0] SEG_BLANK  = 8'b11111111;  // все сегменты выключены
  parameter logic [7:0] SEG_DOTS   = 8'b01111111;  // только десятичная точка
  parameter logic [7:0] SEG_UNDER  = 8'b11110111;  // нижнее подчеркивание (сегмент D)

endpackage
