`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:11:28
// Design Name: 
// Module Name: forward_kinematics_optimized
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module forward_kinematics_optimized(
    input clk,
    input rst,
    input signed [15:0] theta1,
    input signed [15:0] theta2,
    input signed [15:0] theta3,
    input signed [15:0] L1,
    input signed [15:0] L2,
    input signed [15:0] L3,
    output reg signed [31:0] X,
    output reg signed [31:0] Y
);

    // Approximate trig functions
    function signed [15:0] cos_approx(input signed [15:0] angle);
        case(angle)
            0:    cos_approx = 1000;
            30:   cos_approx = 866;
            45:   cos_approx = 707;
            60:   cos_approx = 500;
            90:   cos_approx = 0;
            120:  cos_approx = -500;
            135:  cos_approx = -707;
            150:  cos_approx = -866;
            180:  cos_approx = -1000;
            default: cos_approx = 0;
        endcase
    endfunction

    function signed [15:0] sin_approx(input signed [15:0] angle);
        case(angle)
            0:    sin_approx = 0;
            30:   sin_approx = 500;
            45:   sin_approx = 707;
            60:   sin_approx = 866;
            90:   sin_approx = 1000;
            120:  sin_approx = 866;
            135:  sin_approx = 707;
            150:  sin_approx = 500;
            180:  sin_approx = 0;
            default: sin_approx = 0;
        endcase
    endfunction

    // Stage 1: Precompute compound angles
    reg signed [15:0] theta1_s1, theta12_s1, theta123_s1;
    reg signed [15:0] L1_s1, L2_s1, L3_s1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            theta1_s1 <= 0;
            theta12_s1 <= 0;
            theta123_s1 <= 0;
            L1_s1 <= 0; L2_s1 <= 0; L3_s1 <= 0;
        end else begin
            theta1_s1 <= theta1;
            theta12_s1 <= theta1 + theta2;
            theta123_s1 <= theta1 + theta2 + theta3;
            L1_s1 <= L1; L2_s1 <= L2; L3_s1 <= L3;
        end
    end

    // Stage 2: Compute scaled terms
    reg signed [31:0] x1_s2, x2_s2, x3_s2, y1_s2, y2_s2, y3_s2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1_s2 <= 0; x2_s2 <= 0; x3_s2 <= 0;
            y1_s2 <= 0; y2_s2 <= 0; y3_s2 <= 0;
        end else begin
            x1_s2 <= L1_s1 * cos_approx(theta1_s1);
            x2_s2 <= L2_s1 * cos_approx(theta12_s1);
            x3_s2 <= L3_s1 * cos_approx(theta123_s1);

            y1_s2 <= L1_s1 * sin_approx(theta1_s1);
            y2_s2 <= L2_s1 * sin_approx(theta12_s1);
            y3_s2 <= L3_s1 * sin_approx(theta123_s1);
        end
    end

    // Stage 3: Final addition + scaling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X <= 0;
            Y <= 0;
        end else begin
            X <= (x1_s2 + x2_s2 + x3_s2) / 1000;
            Y <= (y1_s2 + y2_s2 + y3_s2) / 1000;
        end
    end

endmodule
