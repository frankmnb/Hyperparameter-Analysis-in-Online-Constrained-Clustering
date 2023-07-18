function [cl, AssignedLabels] = classification_accuracy(A, true_labels)
%=======================================================================
%classification_accuracy. Every cluster is assigned to the class where the
% majority of the labels are. The index calculates the proportion of 
% matched assigned labels and true labels. 
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
% 28.04.2023 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

uA = unique(A); % unique candidate labels
nA = numel(uA);

 AssignedLabels = zeros(size(true_labels));
for i = 1:nA
    label_subset = true_labels(A == uA(i));
    t = tabulate(label_subset);
    [~,indexmax] = max(t(:,2)); % index of most represented label
    AssignedLabels(A == uA(i)) = t(indexmax,1);
end

cl = mean(true_labels == AssignedLabels);
