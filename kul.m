function [cl,CC] = kul(w, CC, Constraints,PARAM)


% [1] Kulshreshtha, Prakhar and Guha, Tanaya (2018) An online
% algorithm for constrained face clustering in videos. In: 25th
% IEEE International Conference on Image Processing (ICIP), Athens,
% Greece, 7-10 Oct 2018 pp. 2670-2674.
% ISBN 9781479970629. doi:10.1109/ICIP.2018.8451343 ISSN 2381-8549.

% Note: For this algorithm to work, the distance must be bounded, hence the
% data transformation to unit-length vectors. However, this may be a
% problem in low-dimensional spaces, e.g., synthetic data.

% if nargin == 3
%     tau = 2.8; % threshold for setting a new cluster
%     L = 10; % initial number of clusters (*)
% else
%     tau = PARAM.tau;
%     L = PARAM.L;
% end

tau = PARAM.tau;
L = min(PARAM.L, size(w,1));

if ~isempty(Constraints)
    MLindex = Constraints(:,3) == 1;
    ML = Constraints(MLindex,[1,2]);
    CL = Constraints(~MLindex,[1,2]);
else
    ML = []; CL = [];
end
K = size(w,1); % window size

cl = zeros(size(w,1),1); % cluster labels

if isempty(CC)

    % first iteration
    % Note: The authors do not say how they initialise the algorithm: What
    % is the initial number of clusters and how are these obtained?

    % Find cluster centres
    maxiter = 100;
    initialmeans = w(1:L,:);

    [cl, ~, CC] = cop_kmeans(w, ML, CL, maxiter, initialmeans);

else

    L = size(CC,1);
    % Find the tracks

    if ~isempty(ML)
        MLC = Constraints(:,3) == 1;

        % To include all nodes in the graph, even those without
        % constraints, we need to add 1:K to the graph definition
        aux = 1:K;
        G = graph([aux'; Constraints(MLC,1)],...
            [aux';Constraints(MLC,2)]);

        tl = conncomp(G); % track labels in the window
    else
        tl = 1:K;
    end

    NT = max(tl); % number of tracks in the window
    % (conncomp in MATLAB returns labels 1, 2, 3, ...)

    W = ones(L,NT); % weight matrix
    Q = ones(NT); % constraint matrix
    for i = 1:size(CL,1)
        current_pair = CL(i,:);
        Q(tl(current_pair(1)),tl(current_pair(2))) = 0;
        Q(tl(current_pair(2)),tl(current_pair(1))) = 0;
    end

    D = zeros(L,NT); % distance/similarity matrix
    for i = 1:L
        for j = 1:NT
            track = w(tl == j,:);
            difs = sum((track - repmat(CC(i,:),size(track,1),1)).^2,2);
            D(i,j) = 4 - mean(difs);
        end
    end

    % Their Algorithm 1
    ind = 1:NT;
    while numel(ind) > 0

        [x1,y1] = max(D.*W);
        [x2,next_track] = max(x1);
        kstar = ind(next_track); % the actual label to be processed next

        if  x2 >= tau
            next_cluster = y1(next_track);

            % Cluster centre update is not defined strictly! I take the
            % average of the current centre and the track mean
            CC(next_cluster,:) = ...
                (CC(next_cluster,:) + mean(w(tl == kstar,:),1))/2;

        else % Add new cluster
            CC = [CC; mean(w(tl == kstar,:),1)];
            next_cluster = size(CC,1);
        end

        cl(tl == kstar) = next_cluster; % store the cluster labels

        % Recompute D for next_cluster
        for j = 1:numel(ind)
            track = w(tl == ind(j),:);
            difs = sum((track - repmat(CC(next_cluster,:),...
                size(track,1),1)).^2,2);
            D(next_cluster,j) = 4 - mean(difs);
        end

        % Update the weights
        W(next_cluster,:) = Q(next_track,:);

        D(:,next_track) = [];
        W(:,next_track) = [];
        Q(:,next_track) = [];
        Q(next_track,:) = [];
        ind(next_track) = [];

    end
end
end