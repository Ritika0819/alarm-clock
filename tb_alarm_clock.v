`timescale 1ms/1ms
`include "alarm_clock.v"

module tb_alarm_clock;

    reg clk, rst_bar, load_time, load_alarm, set_alarm, stop_alarm;     //  inputs are declared reg datatype

    reg [1:0] h1_in;  // MSB of hrs,  (0-2)
    reg [3:0] h0_in;  // LSB of hrs,  (0-9)
    reg [2:0] m1_in;  // MSB of mins, (0-5)
    reg [3:0] m0_in;  // LSB of mins, (0-9)

    wire alarm;         // outputs are declared wire datatype

    wire [1:0] h1_out;  // MSB of hrs,  (0-2)
    wire [3:0] h0_out;  // LSB of hrs,  (0-9)
    wire [2:0] m1_out;  // MSB of mins, (0-5)
    wire [3:0] m0_out;  // LSB of mins, (0-9)
    wire [2:0] s1_out;  // MSB of secs, (0-5)
    wire [3:0] s0_out;  // LSB of secs, (0-9)

    //  INITIALISING THE ALARM CLOCK

    alarm_clock DUT     
    (
    rst_bar, clk, h1_in, h0_in, m1_in, m0_in, load_time, load_alarm, set_alarm, stop_alarm,
    alarm, h1_out, h0_out, m1_out, m0_out, s1_out, s0_out
    );

    localparam CLK_PERIOD = 10;             //  clock with timeperiod 10ms (100 Hz)
    always #(CLK_PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_alarm_clock.vcd");                                            //  file to be dumped inn, for gtkwave
        $dumpvars(1, alarm, h1_out, h0_out, m1_out, m0_out, s1_out, s0_out);        //  variables to be dumped
        $monitor($time," rst_bar = %b set_alarm = %b stop_alarm = %b input time = %d%d : %d%d output time = %d%d : %d%d alarm = %b",rst_bar,set_alarm,stop_alarm,h1_in,h0_in,m1_in,m0_in,h1_out,h0_out,m1_out,m0_out,alarm);               //  to be printed on screen
    end

    initial begin                           //  initialising at t = 0
        clk = 1'b0;
        rst_bar = 1'b0;

        h1_in = 2'd1;   h0_in = 4'd1;       //  initialised input time 11:43 (hh:mm)   
        m1_in = 3'd4;   m0_in = 4'd3;
    
        set_alarm = 1'b0;   stop_alarm = 1'b0;  
    end

    initial begin   //  handles reset button (active low)
        
        #1e3    rst_bar = 1'b1;     //  t = 1sec
        #32e6   rst_bar = 1'b0;     //  t = 32001 sec
        #1e3    rst_bar = 1'b1;     //  t = 32002 sec
        #274e4  rst_bar = 1'b0;     //  t = 34742 sec
        #1e3    rst_bar = 1'b1;     //  t = 34743 sec

    end

    initial begin   //  handles input time 
    
        #1e4    h1_in = 2'd0;   h0_in = 4'd7;       //  input time 07:10 (hh:mm) at t = 10 sec   
                m1_in = 3'd1;   m0_in = 4'd0;
        
        #4e4    h1_in = 2'd0;   h0_in = 4'd9;       //  input time 09:05 (hh:mm) at t = 50 sec   
                m1_in = 3'd0;   m0_in = 4'd5;
        
        #9e6    h1_in = 2'd1;   h0_in = 4'd2;       //  input time 12:10 (hh:mm) at t = 9050 sec   
                m1_in = 3'd1;   m0_in = 4'd0;
        
        #1e7    h1_in = 2'd1;   h0_in = 4'd3;       //  input time 13:40 (hh:mm) at t = 19050 sec   
                m1_in = 3'd4;   m0_in = 4'd0;
        
        #6e6    h1_in = 2'd1;   h0_in = 4'd5;       //  input time 15:30 (hh:mm) at t = 25050 sec   
                m1_in = 3'd3;   m0_in = 4'd0;

        #6e6    h1_in = 2'd2;   h0_in = 4'd3;       //  input time 23:15 (hh:mm) at t = 31050 sec   
                m1_in = 3'd1;   m0_in = 4'd5;       
            
    end

    initial begin                   //  handles load_time button (active high)
        
        #3e4    load_time = 1'b1;   //  t = 30 sec
        #1e3    load_time = 1'b0;   //  t = 31 sec
    
    end

    initial begin                   //  handles load_alarm button (active high)
        
        #7e4    load_alarm = 1'b1;  //  t = 70 sec
        #1e3    load_alarm = 1'b0;  //  t = 71 sec
        #9e6    load_alarm = 1'b1;  //  t = 9071 sec
        #1e3    load_alarm = 1'b0;  //  t = 9072 sec
        #1e7    load_alarm = 1'b1;  //  t = 19072 sec
        #1e3    load_alarm = 1'b0;  //  t = 19073 sec
        #6e6    load_alarm = 1'b1;  //  t = 25073 sec
        #1e3    load_alarm = 1'b0;  //  t = 25074 sec

    end


    initial begin                   //  handles set_alarm button (active high)
       
        #1e7    set_alarm = 1'b1;   // t = 10000 sec
    
    end

    initial begin                   //  handles stop_alarm button (active high)
        
        #24e6   stop_alarm = 1'b1;  //  t = 24000 sec
        #1e3    stop_alarm = 1'b0;  //  t = 24001 sec
        #6059e3 stop_alarm = 1'b1;  //  t = 30060 sec
        #1e3    stop_alarm = 1'b0;  //  t = 30061 sec

    end

    initial begin
        #35e6   $finish;            //  t = 35000 sec
    end

endmodule