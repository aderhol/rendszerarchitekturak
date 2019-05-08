`timescale 1ns / 1ps

module sim_receiver(

    );
    
    reg clk, rst, next;
    wire [7:0] data;
    wire [6:0] data_7;
    assign data_7 = data[6:0];
    reg [7:0] D;
    reg D_next;
    wire line;
    transmitter tr (
        .clk(clk),
        .rst(rst),
        .N(16'd3),
        .eight_bit(1'b0),
        .two_stop(0),
        .data(D),
        .next(D_next),
        .Tx(line)
        );
        
    receiver uut(
        .clk(clk),
        .rst(rst),
        .N(16'd3), 
        .eight_bit(1'b0),
        .Rx(line),
        .data(data),
        .next(next)
        );
    
    
    
    
    initial begin
        rst <= 1;
        clk <= 0;
        next <= 0;
        D_next <= 0;
        
        #11
        rst <= 0;
        
        #5
        D <= 8'd77;
        D_next <= 1'b1;
        
        #10
        D_next = 1'b0;
        
        #10000
        next <= 1'b1;
        D <= 8'd101;
        D_next <= 1'b1;
        #10
        next <= 1'b0;
        D <= 8'd33;
        D_next <= 1'b1;
        #10
        D_next <= 1'b0;
        
        #6000
        next <= 1'b1;
        #10
        next <= 1'b0;
    end
    
    always #5
        clk = ~clk;
endmodule
