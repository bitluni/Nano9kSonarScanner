//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.07 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Wed Jan 04 22:52:53 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_RAM16SDP your_instance_name(
        .dout(dout_o), //output [7:0] dout
        .wre(wre_i), //input wre
        .wad(wad_i), //input [9:0] wad
        .di(di_i), //input [7:0] di
        .rad(rad_i), //input [9:0] rad
        .clk(clk_i) //input clk
    );

//--------Copy end-------------------
