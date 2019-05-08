`timescale 1ns / 1ps

module APB_UART(
    output Tx,
    input Rx,
    input PCLK,
    input PRESETn,
    input [31:0] PADDR,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [31:0] PWDATA,
    input [3:0] PSTRB,
    output PREADY,
    output [31:0] PRDATA
    );
    
    assign PREADY = (PSEL & PENABLE);
    
    wire TxNext, TxEmpty, TxFull;
    assign TxNext = (PSTRB[0] & PREADY & PWRITE & (PADDR == 32'd12));
    transmitter tr (
        .clk(PCLK),
        .rst(!PRESETn),
        .N(confg[15:0]),
        .eight_bit(confg[16]),
        .two_stop(confg[17]),
        .data(PWDATA[7:0]),
        .next(TxNext),
        .Tx(Tx),
        .empty(TxEmpty),
        .full(TxFull)
        );
    
    wire [7:0] RxData;
    wire RxNext, RxEmpty, RxFull;
    assign RxNext = (PREADY & !PWRITE & (PADDR == 32'd8));
    receiver rec(
        .clk(PCLK),
        .rst((!PRESETn) || (!confg[18])), //hold in reset if disabled
        .N(confg[15:0]),
        .eight_bit(confg[16]),
        .Rx(Rx),
        .data(RxData),
        .next(RxNext),
        .empty(RxEmpty),
        .full(RxFull)
        );
    
    reg [18:0] confg;
    wire confg_en;
    wire [18:0] M;
    assign M = {{3{PSTRB[2]}}, {8{PSTRB[1]}}, {8{PSTRB[0]}}};
    assign confg_en = (PREADY & PWRITE & (PADDR == 32'd0));
    always @(posedge PCLK) begin
        if(!PRESETn)
            confg <= {3'b001, 16'd100}; //defaults: 8N1, receiver disabled, baud=62'500
        else begin
            if(confg_en) begin
                confg <= ((confg & (~M)) | (PWDATA[18:0] & M)); //confg[n]:=(confg[n-1]*~M)+(PWDATA*M) -> only changes the bytes which are set in PSTRB
            end
        end
    end
    
    wire [31:0] mux;
    assign mux = (
        (PADDR == 32'd0) ? ({13'd0, confg}) : (
            (PADDR == 32'd4) ? ({16'd0, {6'b0, RxFull, RxEmpty}, {6'b0, TxFull, TxEmpty}}) : (
                (PADDR == 32'd8) ? ({24'd0, RxData}) : (
                    32'd0 //deafult choise
                    )
                )
            )
        );
    
    assign PRDATA = ((PREADY && (!PWRITE)) ? mux : 32'd0);
endmodule
