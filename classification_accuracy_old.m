function [cl, AssignedLabels] = classification_accuracy_old(A, true_labels)
%=======================================================================
%classification_accuracy. Calculates the match between 'candidate' labels
%and true labels. The best match is ascertained by using the munkres
%(Hungarian) algorithm.
%
%   cl = classification_accuracy(A, true_labels)
%
%   Input -----
%      'A': vector with candidate labels (integers)
%      'true_labels': vector with true labels (integers)
%
%   Output -----
%      'cl': proportion of matching labels (classification accuracy)
%      'AssignedLabels' : optimal assigned labels
%========================================================================
%
% (c) Lucy Kuncheva                                                 ^--^
% 20.07.2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

uA = unique(A); % unique candidate labels
nA = numel(uA);

uT = unique(true_labels); % unique true labels
nT = numel(uT);

% Calculate the cost matrix
costm = zeros(nT,nA);
for i = 1:nT
    for j = 1:nA
        costm(i,j) =  1 - mean(true_labels == uT(i) & A == uA(j));
    end
end

assignments = assignmunkres(costm,10); % Cost of non-assignment = 10
permT = uT(assignments(:,1)); % label permutations for true labels
permA = uA(assignments(:,2)); % label permutations for candidate labels

% Assign labels to candidates
AssignedLabels = zeros(size(A));
for i = 1:numel(permA)
    AssignedLabels(A == permA(i)) = permT(i);
end

cl = mean(true_labels == AssignedLabels);
