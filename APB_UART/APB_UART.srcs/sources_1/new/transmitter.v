`timescale 1ns / 1ps

module transmitter(
    input clk,
    input rst,
    input [15:0] N, //f_sampling = F_osc / N = 16 * baud
    input eight_bit,
    input two_stop,
    output empty,
    output full,
    input [7:0] data,
    input next,
    output Tx
    );
        
    wire [7:0] D;
    reg nextD;
    FIFO #(.depth(32)) mem(
        .clk(clk),
        .rst(rst),
        .in(data),
        .in_next(next),
        .out(D),
        .out_next(nextD),
        .empty(empty),
        .full(full)
        );
    
    reg [10:0] shMem;    
    reg [3:0] state; //0: wait, 1 - 1+bit_num+stop_num: send
    reg [19:0] BCount;
    wire nextState;
    assign nextState = (BCount == ({N, 4'd0} - 1));
    wire [3:0] shiftDepth;
    assign shiftDepth = (4'd1 + 4'd7 + {3'd0, eight_bit} + 4'd1 + {3'd0, two_stop}); //start_bit + 7_data_bits + eight_bit + stop_bit + 2nd_stop_bit
    assign Tx = (state == 4'd0) ? 1'b1 : shMem[state - 4'd1];
    
    always @(posedge clk) begin
        if(rst) begin
            BCount <= 0;
            state <= 0;
            nextD <= 0;
        end
        else begin
            if(state == 0) begin
                if(!empty) begin
                    nextD <= 1;
                    shMem <= {2'b11, (eight_bit ? D[7] : 1'b1), D[6:0], 1'b0}; //11 - eight_bit or stop bit - data - start bit
                    state <= 4'd1;
                    BCount <= 19'd0;
                end
            end
            else begin
                if(state == shiftDepth) begin
                    if(nextState) begin
                        if(!empty) begin
                            nextD <= 1;
                            shMem <= {2'b11, (eight_bit ? D[7] : 1'b1), D[6:0], 1'b0}; //11 - eight_bit or stop bit - data - start bit
                            state <= 4'd1;
                            BCount <= 19'd0;
                        end
                        else
                            state <= 4'd0;
                    end
                    else begin
                        BCount <= BCount + 1;
                    end
                end
                else begin
                    if(nextState) begin
                        state <= state + 1;
                        BCount <= 19'd0;
                    end
                    else begin
                        BCount <= BCount + 1;
                        nextD <= 0;
                    end
                end
            end
            
        end
    end
    
endmodule
