module ADC(
    input clk,
    input adcData,
    output adcClk,
    output reg adcCs,
    output reg sampleClk,
    output reg [7:0] sample
);

reg [3:0] currentEdge = 0;
reg [12:0] bitsIn = 0;
assign adcClk = clk;
reg adcDataNeg;

always @(negedge clk) begin
    adcDataNeg <= adcData;
end

always @(posedge clk) begin
    currentEdge <= currentEdge + 1'b1;
    if(currentEdge < 5'd14)
    begin
        bitsIn <= {bitsIn[11:0], adcDataNeg};
        adcCs <= 1'b0;
        sampleClk <= 1'b0;
    end else if(currentEdge == 5'd14) begin
        adcCs <= 1'b1;
        bitsIn <= 13'd0;
        sample <= bitsIn[1 +: 8];
        sampleClk <= 1'b1;
    end
end

endmodule