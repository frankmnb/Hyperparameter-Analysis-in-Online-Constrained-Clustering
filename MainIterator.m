clc, clear, close all

% Videos to cluster
dataDir = 'RealDatasets\';
filename = ["Koi_5652_952_540", "Pigeons_4927_960_540_600f",...
    "Pigeons_8234_1280_720", "Pigeons_29033_960_540_300f",...
    "Pigs_49651_960_540_500f"];

% Values to test
windowSizes = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30];          % window size
kSizes = round(linspace(5,30,10));             % number of initial clusters
propC = [0, 0.1, 0.3, 0.5, 0.7, 0.9];  % proportion of constraints out of K

Methods = {'kul', 'online_cop_kmeans', 'osl', 'bla', 'blb', 'blc'};
ft = 'RGB'; % feature type

% Paramaters for methods
tau = 2.8;                            % threshold for setting a new cluster
PARAM.tau = tau;          % similarity threshold for a new clusters [Kul18]

% Iterate through values of gamma
for pc = 1:numel(propC)
    % Iterate through methods
    for me = 1:numel(Methods)
        % Iterate through datasets
        for v = 1:numel(filename)
            tic
            
            % Read data
            A1 = readmatrix(...
                strcat(dataDir, 'h1_', filename{v}, '_frames.csv'));
            A2 = readmatrix(...
                strcat(dataDir, 'h2_', filename{v}, '_frames.csv'));
            A = [A1;A2];
            
            z1 = readmatrix(strcat(dataDir, 'h1_', filename{v},...
                '_', ft, '.csv'));
            z2 = readmatrix(strcat(dataDir, 'h2_', filename{v},...
                '_', ft, '.csv'));
            z = [z1;z2];
            
            d = z(:,1:end-1);
            labels = z(:,end);
            
            constraints = readmatrix(strcat(dataDir, 'constraints_', ...
                filename{v}, '.csv'));
            
            % Convert constraint certainties to 1's and 0's for ML and CL
            for i=1:size(constraints,1)
                if constraints(i,3)==-1
                    constraints(i,3)=0;
                else
                    constraints(i,3)=1;
                end
            end
            
            % Normalise data [Kulshreshta18]
            if strcmp(Methods{me},'kul')
                d = d./repmat(sqrt(sum(d.^2,2)),1,size(d,2));
            end
            
            % Iterate through window sizes
            for f = 1:numel(windowSizes)
                K = windowSizes(f);                           % window size
                
                % Iterate through initial values of k
                for gg = 1:numel(kSizes)
                    g = kSizes(gg);
                    str = ['%26.26s %5.5s\tWindow Size: %2i'...
                        '\tIni. Clusters: %2i'];
                    fprintf(str, filename{v}, Methods{me},...
                        windowSizes(f), g)
                    
                    PARAM.L = g;               % initial number of clusters
                    
                    N = max(A(:,5));                % number of data points
                    
                    assigned_labels = [];
                    CC = [];                              % cluster centres
                    
                    lower = 1; temp = 0; upper = 0;   % for window indexing
                    
                    % Iterate through windows in the video
                    for i = 1:K:N
                        % Allow for a smaller final window
                        window_index = i:min(N,i+K-1);
                        
                        idx = any(A(:,5) == window_index, 2);
                        w = d(idx, :);                 % window of features
                        
                        % Prepare constraints
                        temp = upper; upper = lower + size(w,1)-1;
                        
                        con_index = constraints(:,1) >= lower &...
                            constraints(:,1) <= upper &...
                            constraints(:,2) >= lower &...
                            constraints(:,2) <= upper;
                        
                        lower = upper + 1;
                        ConsData.Overlap = constraints(con_index, :);
                        
                        ctp = ceil(size(w,1) * propC(pc));
                        [ML, CL] = pick_constraints(ConsData,ctp);
                        
                        Constraints = [ML ones(size(ML,1),1);...
                            CL zeros(size(CL,1),1)];
                        
                        Constraints = [Constraints(:,1:2) - temp...
                            Constraints(:,3)];
                        
                        
                        % Run method(me)
                        [cl, CC] = sliding_window(Methods{me}, w, CC,...
                            Constraints, PARAM);
                        assigned_labels = [assigned_labels;cl];
                        
                    end
                    
                    % Calculate similarity between clusters and true labels
                    ResNMI(gg, f) = normalised_mutual_information(...
                        assigned_labels, labels);                     % NMI
                    ResARI(gg, f) = adjusted_rand_index(...
                        assigned_labels, labels);                     % ARI
                    ResACC(gg, f) = classification_accuracy(...
                        assigned_labels, labels);        % Accuracy (Count)
                    ResHCA(gg, f) = classification_accuracy_old(...
                        assigned_labels, labels);    % Accuracy (Hungarian)
                    ResC(gg, f) = numel(unique(assigned_labels));
                                             % Resulting number of clusters
                    
                    fprintf(['\tNMI: %.4f\tARI: %.4f\tACC: %.4f\t'...
                        'HCA: %.4f\tCl: %2i\n'],...
                        ResNMI(gg, f), ResARI(gg, f), ResACC(gg, f),...
                        ResHCA(gg, f), ResC(gg, f))
                end
            end
            
            % Collate results
            AllResults(me, v).NMI = ResNMI;
            AllResults(me, v).ARI = ResARI;
            AllResults(me, v).ACC = ResACC;
            AllResults(me, v).HCA = ResHCA;
            AllResults(me, v).C = ResC;
            
            % Print best value
            Max = max(max(ResNMI));
            [r, c] = find(ResNMI == Max);
            rc = [min(r), min(c)];
            r = rc(1);
            c = rc(2);
            fprintf("%s (%s):> Best WS: %i\tBestIniK: %i\t(ResK: %i)\n",...
                filename{v}, Methods{me}, windowSizes(r), kSizes(c),...
                ResC(r,c))
            
            toc
        end
    end
    % Collate everything into one place
    AllConstraints(pc).PCS = AllResults;
end

% Finished
load gong
sound(y,Fs)