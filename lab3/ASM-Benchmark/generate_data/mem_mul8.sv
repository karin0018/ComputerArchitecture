
module mem #(                   // 
    parameter  ADDR_LEN  = 11   // 
) (
    input  clk, rst,
    input  [ADDR_LEN-1:0] addr, // memory address
    output reg [31:0] rd_data,  // data read out
    input  wr_req,
    input  [31:0] wr_data       // data write in
);
localparam MEM_SIZE = 1<<ADDR_LEN;
reg [31:0] ram_cell [MEM_SIZE];

always @ (posedge clk or posedge rst)
    if(rst)
        rd_data <= 0;
    else
        rd_data <= ram_cell[addr];

always @ (posedge clk)
    if(wr_req) 
        ram_cell[addr] <= wr_data;

initial begin
    // dst matrix C
    ram_cell[       0] = 32'h0;  // 32'h025d2f9e;
    ram_cell[       1] = 32'h0;  // 32'h71cb0d84;
    ram_cell[       2] = 32'h0;  // 32'h018286de;
    ram_cell[       3] = 32'h0;  // 32'hc0d27ccc;
    ram_cell[       4] = 32'h0;  // 32'hf9cba0bf;
    ram_cell[       5] = 32'h0;  // 32'h9413602a;
    ram_cell[       6] = 32'h0;  // 32'hf837316d;
    ram_cell[       7] = 32'h0;  // 32'h85d4cffd;
    ram_cell[       8] = 32'h0;  // 32'he567a5f0;
    ram_cell[       9] = 32'h0;  // 32'h759c9cae;
    ram_cell[      10] = 32'h0;  // 32'h49270b59;
    ram_cell[      11] = 32'h0;  // 32'hbce51ec9;
    ram_cell[      12] = 32'h0;  // 32'h15d71da6;
    ram_cell[      13] = 32'h0;  // 32'h7d1e81b1;
    ram_cell[      14] = 32'h0;  // 32'h1da88b8c;
    ram_cell[      15] = 32'h0;  // 32'h0fe3a97d;
    ram_cell[      16] = 32'h0;  // 32'h8ecfd53d;
    ram_cell[      17] = 32'h0;  // 32'h51c8e695;
    ram_cell[      18] = 32'h0;  // 32'h0dedbbe4;
    ram_cell[      19] = 32'h0;  // 32'h7f0abc6a;
    ram_cell[      20] = 32'h0;  // 32'h61146c50;
    ram_cell[      21] = 32'h0;  // 32'he140f274;
    ram_cell[      22] = 32'h0;  // 32'h88c01666;
    ram_cell[      23] = 32'h0;  // 32'h68069f30;
    ram_cell[      24] = 32'h0;  // 32'hc7151afb;
    ram_cell[      25] = 32'h0;  // 32'hda83e7ac;
    ram_cell[      26] = 32'h0;  // 32'h0500474d;
    ram_cell[      27] = 32'h0;  // 32'hf7304e8c;
    ram_cell[      28] = 32'h0;  // 32'hfc4e1a66;
    ram_cell[      29] = 32'h0;  // 32'h036c2d66;
    ram_cell[      30] = 32'h0;  // 32'ha6cdf75c;
    ram_cell[      31] = 32'h0;  // 32'h2d2712ac;
    ram_cell[      32] = 32'h0;  // 32'hddbfa9bb;
    ram_cell[      33] = 32'h0;  // 32'h48255cc4;
    ram_cell[      34] = 32'h0;  // 32'hebf9c9a3;
    ram_cell[      35] = 32'h0;  // 32'hb17251e5;
    ram_cell[      36] = 32'h0;  // 32'h87d3619e;
    ram_cell[      37] = 32'h0;  // 32'h222dbd83;
    ram_cell[      38] = 32'h0;  // 32'h5321a20a;
    ram_cell[      39] = 32'h0;  // 32'h34090eaa;
    ram_cell[      40] = 32'h0;  // 32'hc68b0379;
    ram_cell[      41] = 32'h0;  // 32'h62a94b41;
    ram_cell[      42] = 32'h0;  // 32'hda03443d;
    ram_cell[      43] = 32'h0;  // 32'hcb3ee63f;
    ram_cell[      44] = 32'h0;  // 32'h10a5ab9f;
    ram_cell[      45] = 32'h0;  // 32'h3bc63e24;
    ram_cell[      46] = 32'h0;  // 32'ha295c6de;
    ram_cell[      47] = 32'h0;  // 32'h0ec75930;
    ram_cell[      48] = 32'h0;  // 32'hdb70f336;
    ram_cell[      49] = 32'h0;  // 32'hacd5dd7c;
    ram_cell[      50] = 32'h0;  // 32'h22de3caa;
    ram_cell[      51] = 32'h0;  // 32'h8afeb34e;
    ram_cell[      52] = 32'h0;  // 32'hdbdeea59;
    ram_cell[      53] = 32'h0;  // 32'h2c93761c;
    ram_cell[      54] = 32'h0;  // 32'ha5afc41d;
    ram_cell[      55] = 32'h0;  // 32'h9db6ad0a;
    ram_cell[      56] = 32'h0;  // 32'h755d108c;
    ram_cell[      57] = 32'h0;  // 32'h587b7e70;
    ram_cell[      58] = 32'h0;  // 32'hd965c366;
    ram_cell[      59] = 32'h0;  // 32'h5b813721;
    ram_cell[      60] = 32'h0;  // 32'hfb93202b;
    ram_cell[      61] = 32'h0;  // 32'h57972074;
    ram_cell[      62] = 32'h0;  // 32'h73c7bbce;
    ram_cell[      63] = 32'h0;  // 32'h9762810e;
    // src matrix A
    ram_cell[      64] = 32'h906567ac;
    ram_cell[      65] = 32'h92329911;
    ram_cell[      66] = 32'h8276c2e1;
    ram_cell[      67] = 32'ha34c86da;
    ram_cell[      68] = 32'h984b9431;
    ram_cell[      69] = 32'h3c6f80dc;
    ram_cell[      70] = 32'hbdbadc77;
    ram_cell[      71] = 32'h357c06a6;
    ram_cell[      72] = 32'hce14befc;
    ram_cell[      73] = 32'h5f18b4ba;
    ram_cell[      74] = 32'h17e52098;
    ram_cell[      75] = 32'h73b7f6d4;
    ram_cell[      76] = 32'h3ce3b8c6;
    ram_cell[      77] = 32'h84f60dc9;
    ram_cell[      78] = 32'h9fa70388;
    ram_cell[      79] = 32'hccaa2173;
    ram_cell[      80] = 32'h7508f84f;
    ram_cell[      81] = 32'hee06ed2c;
    ram_cell[      82] = 32'hc604322a;
    ram_cell[      83] = 32'h78b5d55c;
    ram_cell[      84] = 32'h00a2178c;
    ram_cell[      85] = 32'h79ba977b;
    ram_cell[      86] = 32'h39e10691;
    ram_cell[      87] = 32'hb28ea24d;
    ram_cell[      88] = 32'h0f342dd7;
    ram_cell[      89] = 32'hdd3e2816;
    ram_cell[      90] = 32'h9ada87c5;
    ram_cell[      91] = 32'hf8d5b623;
    ram_cell[      92] = 32'h24825aad;
    ram_cell[      93] = 32'hfd3b8a22;
    ram_cell[      94] = 32'ha39deb82;
    ram_cell[      95] = 32'hf69b15be;
    ram_cell[      96] = 32'he7f84f87;
    ram_cell[      97] = 32'hff65b934;
    ram_cell[      98] = 32'h2474bba2;
    ram_cell[      99] = 32'h63f0488a;
    ram_cell[     100] = 32'h9f0465b7;
    ram_cell[     101] = 32'hba08fc55;
    ram_cell[     102] = 32'h376d9aca;
    ram_cell[     103] = 32'h79ff6841;
    ram_cell[     104] = 32'h4b879bf0;
    ram_cell[     105] = 32'h61bfd7de;
    ram_cell[     106] = 32'h504532cd;
    ram_cell[     107] = 32'h132afed9;
    ram_cell[     108] = 32'hc7661217;
    ram_cell[     109] = 32'hdffd22a1;
    ram_cell[     110] = 32'hbdaa734e;
    ram_cell[     111] = 32'h70cb63e6;
    ram_cell[     112] = 32'h1e434a34;
    ram_cell[     113] = 32'h5a5b7dc4;
    ram_cell[     114] = 32'h50a946d4;
    ram_cell[     115] = 32'hff01d2d7;
    ram_cell[     116] = 32'hbd25ddf7;
    ram_cell[     117] = 32'hfe6a165c;
    ram_cell[     118] = 32'hfa9497ca;
    ram_cell[     119] = 32'hb7b7b24f;
    ram_cell[     120] = 32'h94f719df;
    ram_cell[     121] = 32'he557ef35;
    ram_cell[     122] = 32'h491c7a13;
    ram_cell[     123] = 32'hf548472d;
    ram_cell[     124] = 32'hc045648f;
    ram_cell[     125] = 32'h34c0c37e;
    ram_cell[     126] = 32'h24b615f6;
    ram_cell[     127] = 32'h8699969a;
    // src matrix B
    ram_cell[     128] = 32'hd86ee10a;
    ram_cell[     129] = 32'habcdb2b6;
    ram_cell[     130] = 32'ha74930f0;
    ram_cell[     131] = 32'h0b039ed8;
    ram_cell[     132] = 32'h5783f421;
    ram_cell[     133] = 32'h2bcb9c55;
    ram_cell[     134] = 32'h1523f903;
    ram_cell[     135] = 32'h5fa02a24;
    ram_cell[     136] = 32'h5cc1a753;
    ram_cell[     137] = 32'h2b6791e2;
    ram_cell[     138] = 32'h17488917;
    ram_cell[     139] = 32'hcef9f5cb;
    ram_cell[     140] = 32'hed0cfb51;
    ram_cell[     141] = 32'h92010c12;
    ram_cell[     142] = 32'hce573f82;
    ram_cell[     143] = 32'he93fe28c;
    ram_cell[     144] = 32'hfe7eed2d;
    ram_cell[     145] = 32'h94c07ae1;
    ram_cell[     146] = 32'h90169c18;
    ram_cell[     147] = 32'h7fbab68c;
    ram_cell[     148] = 32'he6bf5616;
    ram_cell[     149] = 32'h328ec253;
    ram_cell[     150] = 32'ha0a767db;
    ram_cell[     151] = 32'hd915e4e7;
    ram_cell[     152] = 32'h79459295;
    ram_cell[     153] = 32'h79276f2b;
    ram_cell[     154] = 32'he9c94c97;
    ram_cell[     155] = 32'h8f305b12;
    ram_cell[     156] = 32'h172d623a;
    ram_cell[     157] = 32'h79021cc1;
    ram_cell[     158] = 32'hdc872b27;
    ram_cell[     159] = 32'h5427f756;
    ram_cell[     160] = 32'h6cc6ab43;
    ram_cell[     161] = 32'hc47cafd4;
    ram_cell[     162] = 32'hcc5c54f0;
    ram_cell[     163] = 32'hf3a9339c;
    ram_cell[     164] = 32'h97246d65;
    ram_cell[     165] = 32'hfde2ec93;
    ram_cell[     166] = 32'h5e6c3bed;
    ram_cell[     167] = 32'h7b1abd63;
    ram_cell[     168] = 32'h2bba766e;
    ram_cell[     169] = 32'h4a8ebabd;
    ram_cell[     170] = 32'h445c1336;
    ram_cell[     171] = 32'h4cb68625;
    ram_cell[     172] = 32'h0d413d5c;
    ram_cell[     173] = 32'h0770d1d1;
    ram_cell[     174] = 32'h818d5237;
    ram_cell[     175] = 32'h69164c10;
    ram_cell[     176] = 32'hcc84a5e3;
    ram_cell[     177] = 32'h95e10ccf;
    ram_cell[     178] = 32'hbe4b47bd;
    ram_cell[     179] = 32'h4c1af31f;
    ram_cell[     180] = 32'h645354fd;
    ram_cell[     181] = 32'h33fdaa18;
    ram_cell[     182] = 32'h19855fd9;
    ram_cell[     183] = 32'h775d6fdb;
    ram_cell[     184] = 32'h83509f3c;
    ram_cell[     185] = 32'hf029e10b;
    ram_cell[     186] = 32'h8f478863;
    ram_cell[     187] = 32'h19a671c6;
    ram_cell[     188] = 32'h6cb477ca;
    ram_cell[     189] = 32'h98f1f03c;
    ram_cell[     190] = 32'hf606fe25;
    ram_cell[     191] = 32'hc8c18e3b;
end

endmodule

