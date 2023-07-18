function [cl,CC] = online_cop_kmeans(w, CC, Constraints,PARAM)

L = min(PARAM.L, size(w,1)); % use window size if smaller than initial k

if isempty(Constraints)
    ML = [];
    CL = [];
else
    MLindex = Constraints(:,3) == 1;
    ML = Constraints(MLindex,[1,2]);
    CL = Constraints(~MLindex,[1,2]);
end

maxiter = 100;

if isempty(CC)

    initialmeans = w(1:L,:);
    [cl, ~, CC] = cop_kmeans(w, ML, CL, maxiter, initialmeans);

else

    [cl, ~, CC_out] = cop_kmeans(w, ML, CL, maxiter, CC);
    CC = (CC_out + CC) / 2;

end
