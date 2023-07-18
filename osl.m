function [cl,CC] = osl_c(w, CC, Constraints,PARAM)

% Suppress warning
%#ok<*FNDSB>

% Online constrained single linkage
% The reference set is the previous window only

L = min(PARAM.L, size(w,1)); % number of clusers

if ~isempty(Constraints)
    MLindex = Constraints(:,3) == 1;
    ML = Constraints(MLindex,[1,2]);
    CL = Constraints(~MLindex,[1,2]);
    CL = sort(CL,2);
else
    ML= [];
    CL = [];
end
K = size(w,1); % window size

cl = zeros(size(w,1),1); % cluster labels

if isempty(CC)

    % first iteration - use cop-kmeans
    maxiter = 100;
    initialmeans = w(1:L,:);
    cl = cop_kmeans(w, ML, CL, maxiter, initialmeans);
    CC.RefSet = w;
    CC.RefLab = cl;
    CC.MaxClusters = L;

else

    Ref = CC.RefSet;
    Lab = CC.RefLab;
    maxc = CC.MaxClusters; % maximum number of clusters

    % We assume that constraints do not encrouch different windows.

    if ~isempty(Constraints)
        % Find the tracks
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

    for i = 1:NT % for each track in w

        % Process in order of appearance
        in_component = find(tl == i); % objects from w in the compoinent

        dtc = distance_to_clusters(w(in_component,:),Ref,Lab);
        u = unique(Lab);
        [~,sorted_clusters] = sort(dtc);
        u = u(sorted_clusters); % order of clusters from closest to
        % farthest

        flag_fitted = false; % try to fit the connected component
        for j = 1:numel(u)
            % Check compatibility
            if ~isempty(CL)
                comp = check_compatibility(cl,in_component,CL,u(j));
            else
                comp = true;
            end
            if comp
                % Add to RefTemp and tidy up
                cl(in_component) = u(j);
                Ref = [Ref;w(in_component,:)];
                Lab = [Lab;ones(numel(in_component),1)*u(j)];
                flag_fitted = true;
                break
            end
        end

        if ~flag_fitted
            % New cluster
            Ref = [Ref;w(in_component,:)];
            maxc = maxc + 1;
            Lab = [Lab; ones(numel(in_component),1)*maxc];
            cl(in_component) = maxc;
        end
    end
    CC.Ref = w;
    CC.Lab = cl;
    CC.MaxClusters = maxc;
end

end

% ====================================================================
function dtc = distance_to_clusters(a,Ref,Lab)
% Calculate distance between a and all clusters (labels)

u = unique(Lab);
for i = 1:numel(u)
    t = pdist2(a,Ref(Lab == u(i),:));
    dtc(i) = min(t(:));
end

end

%---------------------------------------------------------------------
function out = check_compatibility(current_labels,in_complonent,...
    CL,chosen_class)
out = true;

z = find(current_labels == chosen_class);
for k1 = 1:numel(in_complonent)
    for k2 = 1:numel(z)
        pair = sort([in_complonent(k1),z(k2)]);
        if ismember(pair,CL,'rows')
            out = false;
            break
        end
    end
end
end