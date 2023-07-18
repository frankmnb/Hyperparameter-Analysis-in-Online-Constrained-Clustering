function [cl,CC] = blc(w, CC, Constraints, PARAM)
% Baseline "random"
% Returns N-by-1 matrix of random values in range (1,...,ws)

   
cl = randi(PARAM.L, size(w,1), 1);
CC = [];

end