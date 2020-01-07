module divfreq(input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)
	begin
		if(Count > 5000)
			begin
				Count <= 25'b0;
				CLK_div <= ~CLK_div;
			end
		else
			Count <= Count + 1'b1;
	end
endmodule

module divfreq2(input CLK, output reg CLK_div2);
	reg [24:0] Count;
	always @(posedge CLK)
	begin
		if(Count >= 3999425)
			begin
				Count <= 25'b0;
				CLK_div2 <= ~CLK_div2;
			end
		else
			Count <= Count + 1'b1;
	end
endmodule


module divfreq3(input CLK, output reg CLK_div3);
	reg [24:0] Count;
	always @(posedge CLK)
		begin
			if(Count > 25000000)
				begin
					Count <= 25'b0;
					CLK_div3 <= ~CLK_div3;
				end
			else
				Count <= Count + 1'b1;
		end
endmodule

module demo(output reg[7:0] R,G,B,output reg h,output reg[3:0] print_bool,A_count,B_count,output reg[1:0] tmot,output reg[7:0] score,input CLK,left,right,control,Clear,next,output reg[6:0] ckot);

	parameter logic[7:0] ball_move[0:7]=  
	'{
		8'b01111111,
		8'b10111111,
		8'b11011111,
		8'b11101111,
		8'b11110111,
		8'b11111011,
		8'b11111101,
		8'b11111110
	};
	
	bit [7:0] empty[7:0] =
	'{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
	};
	
	bit [7:0] W[0:7] =
	'{
		8'b11000011,
		8'b10111101,
		8'b01101010,
		8'b01011110,
		8'b01011110,
		8'b01101010,
		8'b10111101,
		8'b11000011
	};
	
	bit [7:0] L[0:7] =
	'{
		8'b01111110,
		8'b00000000,
		8'b01111110,
		8'b01111111,
		8'b01111111,
		8'b01111111,
		8'b01111111,
		8'b00111111
	};
	
	bit [7:0] tmp2[7:0] = 
	'{
		8'b11111111,
		8'b11111111,
		8'b01111111,
		8'b01111111,
		8'b01111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
	};	
	bit [7:0] ori_tmp[7:0] = 
	'{
		8'b11111111,
		8'b11111111,
		8'b01111111,
		8'b01111111,
		8'b01111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
	};	
	bit [7:0] balls[7:0] =
	'{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b10111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
	};
	
	bit [7:0] ori_balls[7:0] =
	'{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b10111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
	};
	bit [6:0] clock[2:0] =
	'{
		7'b0000100,
		7'b0000100,
		7'b0000000
	};
	bit [7:0] stage[0:2][7:0] =
	'{
		'{8'b11111000,
		8'b11111010,
		8'b11111010,
		8'b11111010,
		8'b11111010,
		8'b11111010,
		8'b11111010,
		8'b11111000},
		
		/*'{8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111000,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111},*/
		
		'{8'b11111101,
		8'b11111010,
		8'b11111101,
		8'b11111010,
		8'b11111101,
		8'b11111010,
		8'b11111101,
		8'b11111010},
		
		'{8'b11110000,
		8'b11111111,
		8'b11111111,
		8'b11111101,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11110000}
		
	};
	
	int sum = 0;
	int block_sum[0:2] = '{6,4,3};
	int block_total[0:2] = '{18,12,9};
	bit [2:0] cnt;
	bit [1:0] tm;
	bit [7:0] block[7:0];
	int i,j,ball_h,hight,button_if,hit,stop,ball_stop,line,direct,ball_flag=0,ball_flag_re =0,ball_hit=0,reverse=0,level=0,smile = 0,score_b = 0;
	divfreq f0(CLK,CLK_div);
	divfreq2 f1(CLK,CLK_ball);
	divfreq3 f2(CLK,CLK_div3);
	initial
		begin
			h = 1;//dots of 7-seg is dark when 1 
			direct = 1;//direction of ball
			stop = 0;//when time is zero,the game stop
			ball_stop = 0;//when the ball isn't catched,the game stop
			line = 4;//the column of ball
			cnt = 0;
			tm = 2;
			ball_h = 1;//the height of ball
			ball_flag = 0;//when ball_flag is 1,judge from up to down
			hit = 7;//the most height of bricks
			hight = 0;//the height of ball
			button_if = 3;//judge if the plat is at edge
			score = 8'b00000000;//score
			A_count = 4'b1001;//the right of 7-seg
			B_count = 4'b1001;//the left of 7-seg
			R = 8'b11111111;//the red of 8x8
			G = 8'b11111111;//the green of 8x8
			B = 8'b11111111;//the blue of 8x8
			print_bool = 4'b1000;//EN S2 S1 S0
			tmot = 2'b01;//7-seg's com1 com2
		end
		
	always @(posedge CLK_div)
		begin		
			if(tm == 1)
				begin
					tm = 2;
				end
			else
				begin
					tm = 1;
				end
			tmot = tm;	
		end
		
	always @(posedge CLK_div3)
		begin
			if(Clear || next) 
				begin
					A_count <= 4'b1001;
					B_count <= 4'b1001;
				end
			else if(control == 1'b1 && B_count > 4'b0000 && ball_stop == 0) 
				begin
					if(A_count > 0)
						A_count <= A_count - 1'b1;
					else
						begin
							B_count <= B_count - 1'b1;
						end
				end
			else if(control == 1'b1)
				begin
					if(A_count != 4'b0000)
						begin
							if(ball_stop == 1)
								begin
									stop = 1;
									A_count <= 4'b0000;
									B_count <= 4'b0000;
								end
							else
								A_count <= A_count - 1'b1;
						end
					else
						stop = 1;
				end
			case({A_count[3],A_count[2],A_count[1],A_count[0]})
					4'b0001: clock[2]= 7'b1001111;
					4'b0010: clock[2]= 7'b0010010;
					4'b0011: clock[2]= 7'b0000110;
					4'b0100: clock[2]= 7'b1001100;
					4'b0101: clock[2]= 7'b0100100;
					4'b0110: clock[2]= 7'b0100000;
					4'b0111: clock[2]= 7'b0001111;
					4'b1000: clock[2]= 7'b0000000;
					4'b1001: clock[2]= 7'b0000100;
					4'b0000:
						begin
							clock[2]= 7'b0000001;
							if(control == 1'b1 && stop == 0)
								A_count <= 4'b1001;
						end
				endcase
				case({B_count[3],B_count[2],B_count[1],B_count[0]})
					4'b0001: clock[1]= 7'b1001111;
					4'b0010: clock[1]= 7'b0010010;
					4'b0011: clock[1]= 7'b0000110;
					4'b0100: clock[1]= 7'b1001100;
					4'b0101: clock[1]= 7'b0100100;
					4'b0110: clock[1]= 7'b0100000;
					4'b0111: clock[1]= 7'b0001111;
					4'b1000: clock[1]= 7'b0000000;
					4'b1001: clock[1]= 7'b0000100;
					4'b0000: clock[1]= 7'b0000001;
				endcase
		end
	always @(posedge CLK_div)
		begin			
			if(cnt >= 7)
				begin
					cnt = 0;				
				end
			else				
				cnt = cnt + 1;			
			print_bool = {1'b1 ,cnt};				
		end
	
	
	
	always @(posedge CLK_ball)
		//board
		begin		
			if(next)
				begin
					smile = 0;
					level = level + 1;
					if(level > 2)
						level = 2;
					for(j=0;j<8;j=j+1)
						begin
							tmp2[j] = ori_tmp[j];
							balls[j] = ori_balls[j];
							score[j] = 0;
						end
				end
			if(control == 1'b1 && stop == 0)
				begin
					if(left==1'b1 && right==1'b0)
						begin
							if(button_if > 0)
								begin
									for(j=0;j<7;j=j+1)
										tmp2[j] = tmp2[j+1];
									tmp2[7] = 8'b11111111;
									button_if = button_if - 1;
								end
						end
					else if(right==1'b1 && left==1'b0)
						begin
							if(button_if < 5)
								begin
									for(j=7;j>0;j=j-1)
										tmp2[j] = tmp2[j-1];
									tmp2[0] = 8'b11111111;
									button_if = button_if + 1;
								end
						end
				//ball
				case(direct)
					0://left
						begin
							balls[line] = empty[1];
							if(reverse  == 0)
								begin
									for(j=0;j<8;j=j+1)
										begin
											if((ball_move[ball_h+1][j] == 1'b0 && stage[level][line-1][j] == 1'b0) && ball_flag == 0)
												begin
													hit = hight;
													stage[level][line-1][j] = 1'b1;
													//block_sum[level] = block_sum[level] - 1;
												end
											else if((ball_move[ball_h-1][j] == 1'b0 && stage[level][line+1][j] == 1'b0) && ball_flag == 1)
												begin
													//hit = 7;
													//hight = ball_h - 1;
													//line = line + 1;
													//ball_h = ball_h - 1;
													hit = hight;
													ball_hit = 1;
													stage[level][line+1][j] = 1'b1;
													//block_sum[level] = block_sum[level] - 1;
												end
										end
									end
							if(hight != hit)
								begin
									ball_h = ball_h + 1;
									hight = hight + 1;
									line = line - 1;
									if(line == 0)
										begin
											direct = 2;
										end
									else if(hight == 7)
										begin
											//hit = hight;
											direct = 2;
											ball_flag = 1;
											ball_flag_re = 1;
										end
								end
							else if(hight == hit)
								begin
									if(ball_h >= 0)
										begin											
											ball_h = ball_h - 1;											
											line = line + 1;	
											if(ball_hit == 1)
												begin
													hight = ball_h;
													hit = 7;
													ball_hit = 0;
													ball_flag = 0;
													ball_flag_re = 0;
													reverse  = 0;													
												end											
											if((ball_move[ball_h-1] == tmp2[line] ||  ball_move[ball_h-1] == tmp2[line+1]) && ball_h == 1)
												begin
													hight = 1;
													hit = 7;
													if(right==1'b1 && left==1'b0)
														direct = 2;
													else if(right==1'b0 && left==1'b1)
														direct = 0;
													else
														direct = 1;	
													ball_flag = 0;
													ball_flag_re = 0;
													reverse = 0;
												end
											else if(line == 8)
												begin
													line  = 7;
													ball_h = ball_h + 1;
													direct = 2;
												end
											else if(hight == 7 && ball_flag_re == 1)
												begin
													reverse = 1;
													ball_h = ball_h + 1;
													line = line - 1;	
													if(ball_hit == 1)
														begin
															direct = 2;
															ball_hit = 0;
															ball_flag_re = 0;
															//reverse = 0;
														end
													else
														begin
															reverse = 0;
															ball_hit = 0;
															//ball_flag = 1;
														end
													ball_flag_re = 0;
												end
										end
								end
						end
					1://中間
						begin
							balls[line] = empty[1];
							for(j=0;j<8;j=j+1)
								begin
									if(ball_move[ball_h+1][j] == 1'b0 && stage[level][line][j] == 1'b0)
										begin
											hit = hight;
											stage[level][line][j] = 1'b1;
											//block_sum[level] = block_sum[level] - 1;
										end
								end
							if(hight != hit)
								begin
									ball_h = ball_h + 1;
									hight = hight + 1;
								end
							else if(hight == hit)
								begin
									if(ball_h >= 0)
										begin
											ball_h = ball_h - 1;
											if(ball_move[ball_h-1] == tmp2[line] && ball_h == 1)
												begin
													hight = 1;
													hit = 7;
													if(right==1'b1 && left==1'b0)
														direct = 2;
													else if(right==1'b0 && left==1'b1)
														direct = 0;
												end
										end
								end
						end
					2://right
						begin
							balls[line] = empty[1];
							if(reverse == 0)
								begin
									for(j=0;j<8;j=j+1)
										begin
											if((ball_move[ball_h+1][j] == 1'b0 && stage[level][line+1][j] == 1'b0) && ball_flag == 0)
												begin
													hit = hight;
													stage[level][line+1][j] = 1'b1;
													//block_sum[level] = block_sum[level] - 1;
												end
											else if((ball_move[ball_h-1][j] == 1'b0 && stage[level][line-1][j] == 1'b0) && ball_flag == 1)
												begin
													//hit = 7;
													//hight = ball_h - 1;
													//line = line - 1;
													//ball_h = ball_h - 1;
													hit = hight;
													ball_hit = 1;
													stage[level][line-1][j] = 1'b1;
													//block_sum[level] = block_sum[level] - 1;
												end
										end
								end
							if(hight != hit)
								begin

									ball_h = ball_h + 1;
									hight = hight + 1;
									line = line + 1;
									if(line == 7)
										begin
											direct = 0;
										end
									else if(hight == 7)
										begin
											//hit = hight;
											direct = 0;
											ball_flag = 1;
											ball_flag_re = 1;
										end										
								end
							else if(hight == hit)
								begin
									if(ball_h >= 0)
										begin
											ball_h = ball_h - 1;
											line = line - 1;
											if(ball_hit == 1)
												begin
													hight = ball_h;
													hit = 7;
													ball_hit = 0;
													ball_flag = 0;
													ball_flag_re = 0;
													reverse  = 0;	
																									
												end
											if((ball_move[ball_h-1] == tmp2[line] ||  ball_move[ball_h-1] == tmp2[line-1]) && ball_h == 1)
												begin
													hight = 1;
													hit = 7;
													if(right==1'b1 && left==1'b0)
														direct = 2;
													else if(right==1'b0 && left==1'b1)
														direct = 0;
													else
														direct = 1;
													ball_flag = 0;
													ball_flag_re = 0;
													reverse  = 0;
												end
											else if(line == -1)
												begin
													line  = 0;
													ball_h = ball_h + 1;
													direct = 0;
												end
											else if(hight == 7 && ball_flag_re == 1)
												begin
													reverse = 1;
													ball_h = ball_h + 1;
													line = line + 1;
													if(ball_hit == 1)
														begin
															direct = 0;
															ball_hit = 0;
															ball_flag_re = 0;
															//reverse = 0;
														end
													else
														begin
															reverse = 0;
															ball_hit = 0;
															//ball_flag = 1;
														end
													ball_flag_re = 0;														
												end
																				
										end
								end
						end
					endcase
					if(ball_h >= 0)
						begin
							balls[line] = ball_move[ball_h];
							sum = 0;
							for(i=0;i<8;i=i+1)
								begin
									for(j=0;j<8;j=j+1)
										begin
											if(stage[level][i][j] == 0)
												sum = sum + 1;
										end
								end
							score_b = block_total[level] - sum;
							if(sum == 0)
								begin
									if(level != 2)
										for(j=0;j<8;j=j+1)
											begin
												balls[j] = W[j];
												tmp2[j] = W[j];
												stage[level][j] = empty[j];
											end
									else
										for(j=0;j<8;j=j+1)
											begin
												balls[j] = empty[j];
												tmp2[j] = W[j];
												stage[level][j] = W[j];
											end
									smile = 1;
									direct = 1;
									ball_stop = 0;
									line = 4;
									ball_h = 1;
									ball_flag = 0;
									hit = 7;
									hight = 0;
									button_if = 3;
									sum = 0;
								end
						end
					else
						begin
							ball_stop = 1;
							for(j=0;j<8;j=j+1)
								begin
									balls[j] = L[j];
									tmp2[j] = empty[j];
									stage[level][j] = empty[j];
								end
						end
					
				end
			else if(stop == 1 && ball_stop != 1)
				begin
					sum = 0;
					for(i=0;i<8;i=i+1)
						begin
							for(j=0;j<8;j=j+1)
								begin
									if(stage[level][i][j] == 0)
										sum = sum + 1;
								end
						end
					if(sum > block_sum[level] && smile == 0)
						begin
							for(j=0;j<8;j=j+1)
								begin
									balls[j] = L[j];
									tmp2[j] = empty[j];
									stage[level][j] = empty[j];
								end
							smile = 1;
						end
					else if(sum <= block_sum[level] && smile == 0)
						begin
							if(level == 2)
								for(j=0;j<8;j=j+1)
									begin
										balls[j] = W[j];
										tmp2[j] = W[j];
										stage[level][j] = W[j];
									end
							else
								for(j=0;j<8;j=j+1)
									begin
										balls[j] = empty[j];
										tmp2[j] = W[j];
										stage[level][j] = empty[j];
									end
							smile = 1;
						end
				end
			for(j=0;j<8;j=j+1)
				begin
					if((j+1)*2 <= score_b)
						score[j] = 1;
					else if(j*2+1 == score_b && score_b == block_total[level])
						score[j] = 1;
					else
						score[j] = 0;
				end
		end
		
assign B = tmp2[cnt];
assign R = balls[cnt];
assign G = stage[level][cnt];
assign ckot = clock[tm];
endmodule
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
			
