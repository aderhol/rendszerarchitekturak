`timescale 1ns / 1ps

module receiver(
    input clk,
    input rst,
    input [15:0] N, //f_sampling = F_osc / N = 16 * baud
    input eight_bit,
    input Rx,
    output [7:0] data,
    input next,
    output empty,
    output full
    );
        
    wire SClk;
    reg [15:0] SClk_count;
    assign SClk = (N == 16'd1) ? clk : (SClk_count == N-1);
    always @(posedge clk) begin
        if(rst)
            SClk_count <= 0;
        else if(SClk)
             SClk_count <= 0;
        else
            SClk_count <= SClk_count + 1;            
    end
    
    reg sample;
    always @(posedge clk)
        if(SClk)
            sample <= Rx;
    
    reg buff[1:0];
    wire dec;
    assign dec = ((sample + buff[0] + buff[1]) >= 2'd2); 
    always @(posedge clk) begin
        if(SClk) begin
            buff[0] <= buff[1];
            buff[1] <= sample;
        end
    end
    
    reg [7:0] shMem;
    reg rec;
    FIFO #(.depth(32)) mem(
        .clk(clk),
        .rst(rst),
        .in(shMem),
        .in_next(rec),
        .out(data),
        .out_next(next),
        .empty(empty),
        .full(full)
        );
    
       
    reg [3:0] state; //0:wait, 1:start bit, 2-:data bits
    reg [3:0] cnt;
    always @(posedge clk) begin
        if(rst) begin
            state <= 4'd0;
            rec <= 1'b0;
        end
        else if(SClk) begin
            if(state == 4'd0) begin
                if(sample == 1'b0) begin //start condition
                    state <= 4'd1;
                    cnt <= 4'd0;
                end
			end
            else if(state == 4'd1) begin
                if(sample == 1'b1)
                    state <= 4'd0;
                else begin
                    if(cnt == 8) begin //if the start condition lasted for half a bit time + 1 sample (so that subsequent bits will be sampled at the middle)
                        cnt <= 4'd0;
                        state <= state + 1;
                    end
                    else
                        cnt <= cnt + 1;
                end
            end
            else if(state == (4'd8 + eight_bit)) begin //last bit
                if(cnt == 4'd15) begin
                    state <= 4'd0;
                    shMem[state - 4'd2] <= dec;
                    rec <= 1'b1;
                end
                else
                    cnt <= cnt + 1;
            end
            else begin
                if(cnt == 4'd15) begin
                    cnt <= 4'd0;
                    state <= state + 4'd1;
                    shMem[state - 4'd2] <= dec;
                end
                else
                    cnt <= cnt + 1;
            end
        end
        else
            rec <= 1'b0;
    end
    
endmodule
