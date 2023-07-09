module alarm_clock (
    rst_bar, clk, h1_in, h0_in, m1_in, m0_in, load_time, load_alarm, set_alarm, stop_alarm,
    alarm, h1_out, h0_out, m1_out, m0_out, s1_out, s0_out
);
    
    input   rst_bar,    // active low reset button, set alarm time to 00:00:00, and clock time to input time, and turns alarm(sound) off
            clk,        // a clock of frequency 100Hz (10ms)
            load_time,  // when high, sets clock time to input time
            load_alarm, // when high, sets alaram time to input time
            set_alarm,  // when high, alarm rings when clock time reaches alarm time
            stop_alarm; // when high, stops the ringing alarm

    input [1:0] h1_in;  // inputs the MSB of hrs,  (0-2)
    input [3:0] h0_in;  // inofputs the LSB of hrs,  (0-9)
    input [2:0] m1_in;  // inputs the MSB  mins, (0-5)
    input [3:0] m0_in;  // inputs the LSB of mins, (0-9)

    output reg alarm;         // when high, alarm rings

    output reg [1:0] h1_out;  // outputs the MSB of hrs,  (0-2)
    output reg [3:0] h0_out;  // outputs the LSB of hrs,  (0-9)
    output reg [2:0] m1_out;  // outputs the MSB of mins, (0-5)
    output reg [3:0] m0_out;  // outputs the LSB of mins, (0-9)
    output reg [2:0] s1_out;  // outputs the MSB of secs, (0-5)
    output reg [3:0] s0_out;  // outputs the LSB of secs, (0-9)

    //  we need temperory clock time and alarm time for operations to be followed

    reg [1:0] temp_c_h1, temp_a_h1;     //  MSB of hrs of clock and alarm    (0-2)
    reg [3:0] temp_c_h0, temp_a_h0;     //  LSB of hrs of clock and alarm    (0-9)
    reg [2:0] temp_c_m1, temp_a_m1;     //  MSB of mins of clock and alarm   (0-5)
    reg [3:0] temp_c_m0, temp_a_m0;     //  LSB of mins of clock and alarm   (0-9)
    reg [2:0] temp_c_s1, temp_a_s1;     //  MSB of secs of clock             (0-5)
    reg [3:0] temp_c_s0, temp_a_s0;     //  LSB of secs of clock             (0-9)

    //  we have a clock of frequency 100 Hz but for alarm clock we need a clock of frequency 1 Hz

    reg clk_1;  //  this will work as clock of frequency 1Hz 
    integer i;  //  integer value to be iterated

    always @(posedge clk or negedge rst_bar) begin
        
        if (!rst_bar) begin         //  active low reset button
            i <= 0;                 //  both i and clk_1 to be
            clk_1 <= 1'b0;          //  set to 0, at reset
        end
        else begin
            if (i>=49) begin        //  since we have a clock of frequency 100 Hz
                i <= 0;             //  halfway is at 49, where out edge must come 
                clk_1 <= ~clk_1;    //  negedge or posedge
            end
            else i<= i+1;           //  otherwise i will be incremented, until reaches halfway
        end
    end

    //  CLOCK OPERATION

    always @(negedge clk_1 or negedge rst_bar) begin  //  we will be using negedge of clock generated
        
        if (!rst_bar) begin

            temp_c_h1 <= h1_in;     //  clock time is set to input time
            temp_c_h0 <= h0_in;
            temp_c_m1 <= m1_in;
            temp_c_m0 <= m0_in;
            temp_c_s1 <= 3'b0;      //  secs set to 00
            temp_c_s0 <= 4'b0;

            temp_a_h1 <= 2'b0;      //  alarm time set to 00:00 (hh:mm)
            temp_a_h0 <= 4'b0;
            temp_a_m1 <= 3'b0;
            temp_a_m0 <= 4'b0;            
            temp_a_s1 <= 3'b0;
            temp_a_s0 <= 4'b0;

            alarm <= 1'b0;          //  alarms if ringings sounds off
        end

        else if (load_time) begin
            temp_c_h1 <= h1_in;     //  clock time is set to input time
            temp_c_h0 <= h0_in;
            temp_c_m1 <= m1_in;
            temp_c_m0 <= m0_in;
            temp_c_s1 <= 3'b0;      //  secs set to 00
            temp_c_s0 <= 4'b0;            
        end

        else if (load_alarm) begin
            temp_a_h1 <= h1_in;     //  clock time is set to input time
            temp_a_h0 <= h0_in;
            temp_a_m1 <= m1_in;
            temp_a_m0 <= m0_in;
            temp_a_s1 <= 3'b0;      //  secs set to 00
            temp_a_s0 <= 4'b0;            
        end

        else begin
            if (temp_c_s0 >= 9) begin                                   //  is s0 = 9, then s0 = 0
                temp_c_s0 <= 0;                                         //  and s1 ges incremented
                if (temp_c_s1 >= 5) begin                               //  ss == 59, it should get to 00
                    temp_c_s1 <= 0;                                     //  and m0 gets incremented
                    if (temp_c_m0 >= 9) begin                           //  if m0 = 9, then m0 = 0
                        temp_c_m0 <= 0;                                 //  and m1 gets incremented
                        if (temp_c_m1 >= 5) begin                       //  mm == 59, it should get to 00
                            temp_c_m1 <= 0;                             //  and hh gets incremented
                            if (temp_c_h1 < 2) begin                    //  if 19 gets to 20
                                if (temp_c_h0 >= 9) begin               //  if 09 gets to 10
                                    temp_c_h0 <= 0;                     //  but shouldn't reach till 29
                                    temp_c_h1 <= temp_c_h1 + 1;
                                end
                                else temp_c_h0 <= temp_c_h0 + 1;
                            end 
                            else if (temp_c_h1 >=2) begin               //  so this is seprated
                                if (temp_c_h0 >= 3) begin               //  after hh = 23, it gets to 00
                                    temp_c_h0 <= 0;
                                    temp_c_h1 <= 0;
                                end
                                else temp_c_h0 <= temp_c_h0 + 1;
                            end
                        end
                        else temp_c_m1 <= temp_c_m1 + 1;
                    end
                    else temp_c_m0 <= temp_c_m0 + 1;
                end
                else temp_c_s1 <= temp_c_s1 + 1;
            end
            else temp_c_s0 <= temp_c_s0 + 1;
        end
    end

    //  ALARM ACTION

    //  we will be adding snooze function also
    //  if alarm is not stopped, it will ring for 1min and then ring after 10 min past alarm time that is set
    //  this will repeat three times, if stop_alarm not pressed

    reg min_1,      //  alarm will ring for one min, if stop_alarm not pressed
        min_9,      //  will wait for nine mins afterwards for stop_alarm to be pressed, if not alarm will ring again
        loop_3;     //  this process repeats three times, if stop_alarm is not pressed

    reg [7:0] num_1;    //  needs to count negedges for 1 min
    reg [9:0] num_9;    //  needs to count negedges for 9 min
    reg [1:0] num_3;    //  needs to count till 2 only or 3 max

    always @(negedge clk_1 or negedge rst_bar) begin
        
        if (!rst_bar) begin         //  alarms turns off at reset
            alarm <=  1'b0;
            min_1 <=  1'b0;
            min_9 <=  1'b0;
            loop_3 <= 1'b0;
        end

        else if (set_alarm) begin   //  when set_alarm is high and clock time matches alarm time
            if ({temp_c_h1,temp_c_h0,temp_c_m1,temp_c_m0,temp_c_s1,temp_c_s0} == 
                {temp_a_h1,temp_a_h0,temp_a_m1,temp_a_m0,temp_a_s1,temp_a_s0} ) begin
            alarm <=  1'b1;         //  alarm rings
            min_1 <=  1'b1;
            min_9 <=  1'b0;
            loop_3 <= 1'b1;
            end
        end
    end

    //  SNOOZE ACTION

    always @(negedge clk_1 or negedge rst_bar or posedge stop_alarm) begin
        
        if (!rst_bar) begin         //  alarms turns off at reset
            alarm <=  1'b0;
            min_1 = 1'b0;
            min_9 = 1'b0;
            loop_3 = 1'b0;
            num_1 = 8'b0;
            num_9 = 10'b0;
            num_3 = 2'b0;
        end

        else if (stop_alarm) begin  //  alarms turns off when stop_alarm is pressed
            alarm <=  1'b0;
            min_1 = 1'b0;
            min_9 = 1'b0;
            loop_3 = 1'b0;
            num_1 = 8'b0;
            num_9 = 10'b0;
            num_3 = 2'b0;
        end
        
        else if (loop_3 || min_1) begin
            if (min_1) begin
                alarm <= 1'b1;
            end
            else if (min_9) begin
                alarm <= 1'b0;
            end
        end

        else begin                  //  no response from user, repeating process turns off
            alarm <=  1'b0;
            min_1 = 1'b0;
            min_9 = 1'b0;
            loop_3 = 1'b0;
            num_1 = 8'b0;
            num_9 = 10'b0;
            num_3 = 2'b0;         
        end
    end

    //  COUNTING OPERATION

    always @(negedge clk_1 or negedge rst_bar) begin

        if (!rst_bar) begin         //  alarms turns off at reset
            alarm <=  1'b0;
            min_1 = 1'b0;
            min_9 = 1'b0;
            loop_3 = 1'b0;
            num_1 = 8'b0;
            num_9 = 10'b0;
            num_3 = 2'b0;
        end

        else if (loop_3) begin

            if (num_3 >= 2) begin
                num_3  <= 2'b0;
                loop_3 <= 1'b0;
            end

            else begin

                if (min_1) begin
                    if (num_1 >= 60) begin
                        num_1 <= 8'b0;
                        min_1 <= 1'b0;
                        min_9 <= 1'b1;
                    end
                    else num_1 <= num_1 + 1;
                end

                else if (min_9) begin
                    if (num_9 >= 540) begin
                        num_9 <= 10'b0;
                        min_1 <= 1'b1;
                        min_9 <= 1'b0;
                        num_3 <= num_3 + 1;
                    end
                    else num_9 <= num_9 + 1;
                end
            end
        end

        else if (min_1) begin
            if (num_1 >= 60) begin
                num_1 <= 8'b0;
                min_1 <= 1'b0;
            end
            else num_1 <= num_1 + 1;
        end

        else begin
            min_1 = 1'b0;
            min_9 = 1'b0;
            loop_3 = 1'b0;
            num_1 = 8'b0;
            num_9 = 10'b0;
            num_3 = 2'b0;
        end 
    end

    // OUTPUT

    always @(negedge clk_1 or negedge rst_bar) begin
        if (!rst_bar) begin
            h1_out <= h1_in;
            h0_out <= h0_in;
            m1_out <= m1_in;
            m0_out <= m0_in;
            s1_out <= 3'b0;
            s0_out <= 4'b0;
        end
        else begin
            h1_out <= temp_c_h1;
            h0_out <= temp_c_h0;
            m1_out <= temp_c_m1;
            m0_out <= temp_c_m0;
            s1_out <= temp_c_s1;
            s0_out <= temp_c_s0;
        end
    end

endmodule