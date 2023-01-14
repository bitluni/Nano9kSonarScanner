module buffer(
    input reset,
    input inClk,
    input inEn,
    input [7:0] inData,
    input [9:0] inAddr,

    input outClk,
    input outEn,
    input [9:0] outAddr,
    output [7:0] outData
);

wire [7:0] inOut;

    Gowin_DPB mem(
        .doutb(outData), //output [7:0] doutb
        .douta(inOut),
        .clka(inClk), //input clka
        .ocea(inClk), //input ocea
        .cea(inClk), //input cea
        .reseta(reset), //input reseta
        .wrea(1'b1), //input wrea
        
        .clkb(outClk), //input clkb
        .oceb(outEn), //input oceb
        .ceb(1'b1), //input ceb

        .resetb(reset), //input resetb
        .wreb(1'b0), //input wreb

        .ada(10'd0/*inAddr*/), //input [9:0] ada
        .dina(8'd100/*inData*/), //input [7:0] dina
        .dinb(8'b0), //input [7:0] dina

        .adb(10'd0/*outAddr*/) //input [9:0] adb
    );

endmodule