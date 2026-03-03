import pkg::*;

module test3 (
    input CLK_50MHz,
    CLK_16MHz,
    input K1,
    K2,
    K3,
    K4,
    K5,  //BUTTONS
    output LED_D3,
    LED_D4,
    LED_D5,
    LED_D6,
    LED_D7,
    LED_D8,
    output p46,
    p30,
    p32,
    p33,
    p38,
    p39,
    p42,
    p43,
    p44,
    p49,
    input p89,  //TX
    output p28,  //RX

    // 7-сегментный дисплей
    output p127,  //A
    output p126,  //B
    output p125,  //C
    output p124,  //D
    output p121,  //E
    output p120,  //F
    output p119,  //G
    output p115,  //DP
    output p128,  //BIT0
    output p129,  //BIT1
    output p132,  //BIT2
    output p133,  //BIT3
    output p135,  //BIT4
    output p136,  //BIT5
    output p137,  //BIT6
    output p138   //BIT7
);

  // Сигналы для 7-сегментного дисплея
  reg [7:0] r_Segment;
  reg [7:0] r_BitNum = 8'hFE;
  reg [9:0] r_ClkDivCnt;

  // Сигналы для обработки кнопок
  reg [15:0] debounce_cnt1, debounce_cnt2;
  reg k1_prev, k2_prev;
  reg k1_pressed, k2_pressed;

  // ======================================================
  // 7-сегментный дисплей
  // ======================================================
  always @(posedge CLK_16MHz) begin
    r_ClkDivCnt <= r_ClkDivCnt + 1;

    if (r_ClkDivCnt == 0) begin
      r_BitNum <= {r_BitNum[6:0], r_BitNum[7]};
    end

    case (r_BitNum)
      8'hFE:   r_Segment <= pkg::SEG_0;
      8'hFD:   r_Segment <= pkg::SEG_1;
      8'hFB:   r_Segment <= pkg::SEG_2;
      8'hF7:   r_Segment <= pkg::SEG_3;
      8'hEF:   r_Segment <= pkg::SEG_4;
      8'hDF:   r_Segment <= pkg::SEG_5;
      8'hBF:   r_Segment <= pkg::SEG_6;
      8'h7F:   r_Segment <= pkg::SEG_7;
      default: r_Segment <= pkg::SEG_BLANK;
    endcase
  end

  // ======================================================
  // ШИМ для LED_D3 с регулируемой яркостью
  // ======================================================
  // Сигналы для ШИМ светодиода
  reg [7:0] r_PWM_Cnt;  // быстрый ШИМ счетчик (0-255)
  reg [19:0] r_PWM_FadeCnt;       // медленный счетчик (для изменения яркости)
  reg [7:0] r_PWM_Border;  // граница ШИМ (0-255)
  reg r_PWM_Dir;  // направление: 0-увеличение, 1-уменьшение
  reg pwm_led;

  // Определяем базовые параметры в одном месте
  localparam CLK_FREQ = 16_000_000;  // 16 МГц
  localparam FADE_CYCLE_MS = 2000;   // полный цикл затухания/зажигания 2 секунды
  localparam BRIGHTNESS_PERCENT = 40;  // максимальная яркость 25%

  // Автоматически рассчитываем все необходимые параметры
  localparam STEPS = 256;  // шагов ШИМ
  localparam MAX_BRIGHTNESS = (STEPS * BRIGHTNESS_PERCENT) / 100;  // 64

  // Время одного шага = полный цикл / (2 * MAX_BRIGHTNESS)
  localparam STEP_TIME_MS = FADE_CYCLE_MS / (2 * MAX_BRIGHTNESS);  // 2000 / 126 ≈ 15.87ms

  // Количество тактов на шаг
  localparam TICKS_PER_STEP = (CLK_FREQ / 1000) * STEP_TIME_MS;  // 16000 * 15.87 ≈ 254000

  // Итоговое значение для счетчика
  localparam FADECNT_BORDER = TICKS_PER_STEP[19:0];  // 20'h3E000 (примерно)

  // Быстрый ШИМ счетчик
  always @(posedge CLK_16MHz) begin
    r_PWM_Cnt <= r_PWM_Cnt + 1;  // автоматический переполнение 255->0
  end

  // Медленное изменение границы
  always @(posedge CLK_16MHz) begin
    r_PWM_FadeCnt <= r_PWM_FadeCnt + 1;

    // Каждые 524288 тактов (~32ms)
    if (r_PWM_FadeCnt == TICKS_PER_STEP) begin
      r_PWM_FadeCnt <= 0;

      if (r_PWM_Dir == 0) begin  // увеличение
        if (r_PWM_Border >= MAX_BRIGHTNESS) begin
          r_PWM_Dir <= 1;
        end else begin
          r_PWM_Border <= r_PWM_Border + 1;
        end
      end else begin  // уменьшение
        if (r_PWM_Border <= 8'd0) begin
          r_PWM_Dir <= 0;
        end else begin
          r_PWM_Border <= r_PWM_Border - 1;
        end
      end
    end
  end

  // ШИМ сравнение
  always @(posedge CLK_16MHz) begin
    pwm_led <= (r_PWM_Cnt < r_PWM_Border);
  end

  // ======================================================
  // Qsys soft core
  // ======================================================


  // ======================================================
  // Выходы
  // ======================================================

  // Подключение сегментов
  assign p127 = r_Segment[0];  //A
  assign p126 = r_Segment[1];  //B
  assign p125 = r_Segment[2];  //C
  assign p124 = r_Segment[3];  //D
  assign p121 = r_Segment[4];  //E
  assign p120 = r_Segment[5];  //F
  assign p119 = r_Segment[6];  //G
  assign p115 = r_Segment[7];  //DP

  // Подключение битовых линий
  assign p128 = r_BitNum[0] | ~pwm_led;  //BIT0
  assign p129 = r_BitNum[1] | ~pwm_led;  //BIT1
  assign p132 = r_BitNum[2] | ~pwm_led;  //BIT2
  assign p133 = r_BitNum[3] | ~pwm_led;  //BIT3
  assign p135 = r_BitNum[4] | ~pwm_led;  //BIT4
  assign p136 = r_BitNum[5] | ~pwm_led;  //BIT5
  assign p137 = r_BitNum[6] | ~pwm_led;  //BIT6
  assign p138 = r_BitNum[7] | ~pwm_led;  //BIT7

  // Тестовые точки
  assign p46 = r_Segment[0];
  assign p30 = r_Segment[1];
  assign p32 = r_Segment[2];
  assign p33 = r_Segment[3];
  assign p38 = r_Segment[4];
  assign p42 = r_Segment[5];
  assign p43 = r_Segment[6];
  assign p44 = r_Segment[7];
  assign p49 = (r_ClkDivCnt == 0) ? 1'b1 : 1'b0;

  // Светодиоды с ШИМ (все одинаково)
  assign LED_D3 = ~pwm_led;
  assign LED_D4 = ~pwm_led;
  assign LED_D5 = ~pwm_led;
  assign LED_D6 = ~pwm_led;
  assign LED_D7 = ~pwm_led;
  assign LED_D8 = ~pwm_led;

endmodule
