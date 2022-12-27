`timescale 1ns/100ps

`define TEMPL_SIZE 64
`define IMG_ROW 480
`define IMG_COL 640
module template_match(
    input clk,
    input rst,
    input templ_content,
    input templ_in_valid,
    input img_content,
    input img_in_valid,
    output [12:0] data
);

//expect a bit string of templ_content after templ_in_valid, so does img_in_valid

logic [`TEMPL_SIZE*`TEMPL_SIZE:0] templ_arr;

logic [1:0] state_r;
logic [1:0] state_w;
parameter S_IDLE = 0;
parameter S_LD_TEMPL = 1; // load weight into the XOR array
parameter S_PROC = 2; // process the template matching

logic [20:0] counter_w, counter_r;

logic [`IMG_ROW*(`TEMPL_SIZE-1)+`TEMPL_SIZE:0] pipeline_r; // pipeline is inserted at index 0
logic [`IMG_ROW*(`TEMPL_SIZE-1)+`TEMPL_SIZE-1:0] pipeline_w;

adder_tree adder(
    .clk(clk),
    .rst(rst),
    .idata({
        pipeline_r[`IMG_ROW*63+`TEMPL_SIZE-1:`IMG_ROW*63]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-63)-1:`TEMPL_SIZE*(`TEMPL_SIZE-64)],
        pipeline_r[`IMG_ROW*62+`TEMPL_SIZE-1:`IMG_ROW*62]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-62)-1:`TEMPL_SIZE*(`TEMPL_SIZE-63)],
        pipeline_r[`IMG_ROW*61+`TEMPL_SIZE-1:`IMG_ROW*61]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-61)-1:`TEMPL_SIZE*(`TEMPL_SIZE-62)],
        pipeline_r[`IMG_ROW*60+`TEMPL_SIZE-1:`IMG_ROW*60]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-60)-1:`TEMPL_SIZE*(`TEMPL_SIZE-61)],
        pipeline_r[`IMG_ROW*59+`TEMPL_SIZE-1:`IMG_ROW*59]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-59)-1:`TEMPL_SIZE*(`TEMPL_SIZE-60)],
        pipeline_r[`IMG_ROW*58+`TEMPL_SIZE-1:`IMG_ROW*58]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-58)-1:`TEMPL_SIZE*(`TEMPL_SIZE-59)],
        pipeline_r[`IMG_ROW*57+`TEMPL_SIZE-1:`IMG_ROW*57]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-57)-1:`TEMPL_SIZE*(`TEMPL_SIZE-58)],
        pipeline_r[`IMG_ROW*56+`TEMPL_SIZE-1:`IMG_ROW*56]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-56)-1:`TEMPL_SIZE*(`TEMPL_SIZE-57)],
        pipeline_r[`IMG_ROW*55+`TEMPL_SIZE-1:`IMG_ROW*55]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-55)-1:`TEMPL_SIZE*(`TEMPL_SIZE-56)],
        pipeline_r[`IMG_ROW*54+`TEMPL_SIZE-1:`IMG_ROW*54]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-54)-1:`TEMPL_SIZE*(`TEMPL_SIZE-55)],
        pipeline_r[`IMG_ROW*53+`TEMPL_SIZE-1:`IMG_ROW*53]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-53)-1:`TEMPL_SIZE*(`TEMPL_SIZE-54)],
        pipeline_r[`IMG_ROW*52+`TEMPL_SIZE-1:`IMG_ROW*52]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-52)-1:`TEMPL_SIZE*(`TEMPL_SIZE-53)],
        pipeline_r[`IMG_ROW*51+`TEMPL_SIZE-1:`IMG_ROW*51]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-51)-1:`TEMPL_SIZE*(`TEMPL_SIZE-52)],
        pipeline_r[`IMG_ROW*50+`TEMPL_SIZE-1:`IMG_ROW*50]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-50)-1:`TEMPL_SIZE*(`TEMPL_SIZE-51)],
        pipeline_r[`IMG_ROW*49+`TEMPL_SIZE-1:`IMG_ROW*49]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-49)-1:`TEMPL_SIZE*(`TEMPL_SIZE-50)],
        pipeline_r[`IMG_ROW*48+`TEMPL_SIZE-1:`IMG_ROW*48]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-48)-1:`TEMPL_SIZE*(`TEMPL_SIZE-49)],
        pipeline_r[`IMG_ROW*47+`TEMPL_SIZE-1:`IMG_ROW*47]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-47)-1:`TEMPL_SIZE*(`TEMPL_SIZE-48)],
        pipeline_r[`IMG_ROW*46+`TEMPL_SIZE-1:`IMG_ROW*46]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-46)-1:`TEMPL_SIZE*(`TEMPL_SIZE-47)],
        pipeline_r[`IMG_ROW*45+`TEMPL_SIZE-1:`IMG_ROW*45]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-45)-1:`TEMPL_SIZE*(`TEMPL_SIZE-46)],
        pipeline_r[`IMG_ROW*44+`TEMPL_SIZE-1:`IMG_ROW*44]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-44)-1:`TEMPL_SIZE*(`TEMPL_SIZE-45)],
        pipeline_r[`IMG_ROW*43+`TEMPL_SIZE-1:`IMG_ROW*43]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-43)-1:`TEMPL_SIZE*(`TEMPL_SIZE-44)],
        pipeline_r[`IMG_ROW*42+`TEMPL_SIZE-1:`IMG_ROW*42]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-42)-1:`TEMPL_SIZE*(`TEMPL_SIZE-43)],
        pipeline_r[`IMG_ROW*41+`TEMPL_SIZE-1:`IMG_ROW*41]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-41)-1:`TEMPL_SIZE*(`TEMPL_SIZE-42)],
        pipeline_r[`IMG_ROW*40+`TEMPL_SIZE-1:`IMG_ROW*40]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-40)-1:`TEMPL_SIZE*(`TEMPL_SIZE-41)],
        pipeline_r[`IMG_ROW*39+`TEMPL_SIZE-1:`IMG_ROW*39]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-39)-1:`TEMPL_SIZE*(`TEMPL_SIZE-40)],
        pipeline_r[`IMG_ROW*38+`TEMPL_SIZE-1:`IMG_ROW*38]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-38)-1:`TEMPL_SIZE*(`TEMPL_SIZE-39)],
        pipeline_r[`IMG_ROW*37+`TEMPL_SIZE-1:`IMG_ROW*37]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-37)-1:`TEMPL_SIZE*(`TEMPL_SIZE-38)],
        pipeline_r[`IMG_ROW*36+`TEMPL_SIZE-1:`IMG_ROW*36]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-36)-1:`TEMPL_SIZE*(`TEMPL_SIZE-37)],
        pipeline_r[`IMG_ROW*35+`TEMPL_SIZE-1:`IMG_ROW*35]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-35)-1:`TEMPL_SIZE*(`TEMPL_SIZE-36)],
        pipeline_r[`IMG_ROW*34+`TEMPL_SIZE-1:`IMG_ROW*34]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-34)-1:`TEMPL_SIZE*(`TEMPL_SIZE-35)],
        pipeline_r[`IMG_ROW*33+`TEMPL_SIZE-1:`IMG_ROW*33]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-33)-1:`TEMPL_SIZE*(`TEMPL_SIZE-34)],
        pipeline_r[`IMG_ROW*32+`TEMPL_SIZE-1:`IMG_ROW*32]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-32)-1:`TEMPL_SIZE*(`TEMPL_SIZE-33)],
        pipeline_r[`IMG_ROW*31+`TEMPL_SIZE-1:`IMG_ROW*31]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-31)-1:`TEMPL_SIZE*(`TEMPL_SIZE-32)],
        pipeline_r[`IMG_ROW*30+`TEMPL_SIZE-1:`IMG_ROW*30]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-30)-1:`TEMPL_SIZE*(`TEMPL_SIZE-31)],
        pipeline_r[`IMG_ROW*29+`TEMPL_SIZE-1:`IMG_ROW*29]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-29)-1:`TEMPL_SIZE*(`TEMPL_SIZE-30)],
        pipeline_r[`IMG_ROW*28+`TEMPL_SIZE-1:`IMG_ROW*28]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-28)-1:`TEMPL_SIZE*(`TEMPL_SIZE-29)],
        pipeline_r[`IMG_ROW*27+`TEMPL_SIZE-1:`IMG_ROW*27]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-27)-1:`TEMPL_SIZE*(`TEMPL_SIZE-28)],
        pipeline_r[`IMG_ROW*26+`TEMPL_SIZE-1:`IMG_ROW*26]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-26)-1:`TEMPL_SIZE*(`TEMPL_SIZE-27)],
        pipeline_r[`IMG_ROW*25+`TEMPL_SIZE-1:`IMG_ROW*25]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-25)-1:`TEMPL_SIZE*(`TEMPL_SIZE-26)],
        pipeline_r[`IMG_ROW*24+`TEMPL_SIZE-1:`IMG_ROW*24]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-24)-1:`TEMPL_SIZE*(`TEMPL_SIZE-25)],
        pipeline_r[`IMG_ROW*23+`TEMPL_SIZE-1:`IMG_ROW*23]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-23)-1:`TEMPL_SIZE*(`TEMPL_SIZE-24)],
        pipeline_r[`IMG_ROW*22+`TEMPL_SIZE-1:`IMG_ROW*22]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-22)-1:`TEMPL_SIZE*(`TEMPL_SIZE-23)],
        pipeline_r[`IMG_ROW*21+`TEMPL_SIZE-1:`IMG_ROW*21]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-21)-1:`TEMPL_SIZE*(`TEMPL_SIZE-22)],
        pipeline_r[`IMG_ROW*20+`TEMPL_SIZE-1:`IMG_ROW*20]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-20)-1:`TEMPL_SIZE*(`TEMPL_SIZE-21)],
        pipeline_r[`IMG_ROW*19+`TEMPL_SIZE-1:`IMG_ROW*19]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-19)-1:`TEMPL_SIZE*(`TEMPL_SIZE-20)],
        pipeline_r[`IMG_ROW*18+`TEMPL_SIZE-1:`IMG_ROW*18]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-18)-1:`TEMPL_SIZE*(`TEMPL_SIZE-19)],
        pipeline_r[`IMG_ROW*17+`TEMPL_SIZE-1:`IMG_ROW*17]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-17)-1:`TEMPL_SIZE*(`TEMPL_SIZE-18)],
        pipeline_r[`IMG_ROW*16+`TEMPL_SIZE-1:`IMG_ROW*16]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-16)-1:`TEMPL_SIZE*(`TEMPL_SIZE-17)],
        pipeline_r[`IMG_ROW*15+`TEMPL_SIZE-1:`IMG_ROW*15]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-15)-1:`TEMPL_SIZE*(`TEMPL_SIZE-16)],
        pipeline_r[`IMG_ROW*14+`TEMPL_SIZE-1:`IMG_ROW*14]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-14)-1:`TEMPL_SIZE*(`TEMPL_SIZE-15)],
        pipeline_r[`IMG_ROW*13+`TEMPL_SIZE-1:`IMG_ROW*13]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-13)-1:`TEMPL_SIZE*(`TEMPL_SIZE-14)],
        pipeline_r[`IMG_ROW*12+`TEMPL_SIZE-1:`IMG_ROW*12]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-12)-1:`TEMPL_SIZE*(`TEMPL_SIZE-13)],
        pipeline_r[`IMG_ROW*11+`TEMPL_SIZE-1:`IMG_ROW*11]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-11)-1:`TEMPL_SIZE*(`TEMPL_SIZE-12)],
        pipeline_r[`IMG_ROW*10+`TEMPL_SIZE-1:`IMG_ROW*10]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-10)-1:`TEMPL_SIZE*(`TEMPL_SIZE-11)],
        pipeline_r[`IMG_ROW*9+`TEMPL_SIZE-1:`IMG_ROW*9]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-9)-1:`TEMPL_SIZE*(`TEMPL_SIZE-10)],
        pipeline_r[`IMG_ROW*8+`TEMPL_SIZE-1:`IMG_ROW*8]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-8)-1:`TEMPL_SIZE*(`TEMPL_SIZE-9)],
        pipeline_r[`IMG_ROW*7+`TEMPL_SIZE-1:`IMG_ROW*7]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-7)-1:`TEMPL_SIZE*(`TEMPL_SIZE-8)],
        pipeline_r[`IMG_ROW*6+`TEMPL_SIZE-1:`IMG_ROW*6]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-6)-1:`TEMPL_SIZE*(`TEMPL_SIZE-7)],
        pipeline_r[`IMG_ROW*5+`TEMPL_SIZE-1:`IMG_ROW*5]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-5)-1:`TEMPL_SIZE*(`TEMPL_SIZE-6)],
        pipeline_r[`IMG_ROW*4+`TEMPL_SIZE-1:`IMG_ROW*4]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-4)-1:`TEMPL_SIZE*(`TEMPL_SIZE-5)],
        pipeline_r[`IMG_ROW*3+`TEMPL_SIZE-1:`IMG_ROW*3]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-3)-1:`TEMPL_SIZE*(`TEMPL_SIZE-4)],
        pipeline_r[`IMG_ROW*2+`TEMPL_SIZE-1:`IMG_ROW*2]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-2)-1:`TEMPL_SIZE*(`TEMPL_SIZE-3)],
        pipeline_r[`IMG_ROW*1+`TEMPL_SIZE-1:`IMG_ROW*1]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-1)-1:`TEMPL_SIZE*(`TEMPL_SIZE-2)],
        pipeline_r[`IMG_ROW*0+`TEMPL_SIZE-1:`IMG_ROW*0]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-0)-1:`TEMPL_SIZE*(`TEMPL_SIZE-1)]
    }),
    .odata(data)
);
//output is 12:0

always_comb begin
    pipeline_w = pipeline_r[`IMG_ROW*(`TEMPL_SIZE-1)+`TEMPL_SIZE-1:1];
    state_w = state_r;
    counter_w = counter_r;
    case(state_r)
    S_IDLE: begin
        if(templ_in_valid) begin
            state_w = S_LD_TEMPL;
        end
        if(img_in_valid) begin
            state_w = S_PROC;
        end
        counter_w = 0;
    end
    S_LD_TEMPL: begin
        counter_w = counter_r + 1;
        if(counter_r == (`TEMPL_SIZE)*(`TEMPL_SIZE)-1) begin
            state_w = S_IDLE;
        end
    end
    S_PROC: begin
        counter_w = counter_r + 1;
        if(counter_r == (`IMG_ROW)*(`IMG_COL)-1) begin
            state_w = S_IDLE;
        end
    end
    endcase
end

always_ff @( posedge clk or posedge rst ) begin
    if(rst) begin
        templ_arr <= 0;
        state_r <= S_IDLE;
        counter_r <= 0;
    end
    else begin
        if(state_r == S_LD_TEMPL) begin
            templ_arr[counter_r] = templ_content;
        end
        state_r <= state_w;
        counter_r <= counter_w;
        pipeline_r[`IMG_ROW*(`TEMPL_SIZE-1)+`TEMPL_SIZE-1:1] <= pipeline_w;
        pipeline_r[0] <= img_content;
    end
end

// assume the template input is cont. bitstring

endmodule