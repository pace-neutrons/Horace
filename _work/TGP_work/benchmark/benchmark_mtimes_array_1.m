function [T, TL] = benchmark_mtimes_array_1 (n, nloop)
% Benchmark mtimes_array and mtimesx_horace
%
%   >> benchmark_mtimes_array_1 (n, nloop)
%
% Input:
% ------
%   n       Array of sizes of two arrays to multiply, [3,3,n(i)], i=1:numel(n)
%           n = -1 to skip
%           Default if empty: 10.^[0,1,2,3,4,5,6]
%
%   nloop   Array of number of loops: [3,3,1] matrix multiplication
%           nloop = -1 to skip
%           Default if empty: 10.^[0,1,2,3,4,5]


% Multiplying matricies of increasing size: conclude mtimesx_horace is about 10
% times faster (TGP's Dell XPS 15 laptop,(2023))

if isempty(n)
    n = 10.^[0,1,2,3,4,5,6];
end
if ~isequal(n,-1)
    T1 = zeros(numel(n),1);
    S1 = zeros(numel(n),1);
    T2 = zeros(numel(n),1);
    S2 = zeros(numel(n),1);
    for i=1:numel(n)
        disp(['Multiplying arrays size [3,3,',num2str(n(i)),']'])
        a = rand(3,3,n(i));
        b = rand(3,3,n(i));
        
        % Time mtimes_array
        tic
        c1 = mtimes_array(a,b);
        T1(i) = toc;
        S1(i) = sum(c1(:));     % use result of matrix multiplication; avoids optimisation
        
        % Time mtimes_horace
        tic
        c2 = mtimesx_horace(a,b);
        T2(i) = toc;
        S2(i) = sum(c2(:));     % use result of matrix multiplication; avoids optimisation
    end
    % Concatenate
    T = [T1,T2];
    T = 1e6 * T;  % microseconds
else
    S1 = 0;
    S2 = 0;
    T = NaN(0,2);
end


% Multiplying loops: tests overheads
% Overheads for [3,3,10^6] matrix are c. 1e-4 of core calculation
% Conclude that overheads start to dominate for <= [3,3,100] matrix
if isempty(nloop)
    nloop = 10.^[0,1,2,3,4,5];
end
if ~isequal(nloop,-1)
    TL0 = zeros(numel(nloop),1);
    SL0 = zeros(numel(nloop),1);
    TL1 = zeros(numel(nloop),1);
    SL1 = zeros(numel(nloop),1);
    TL2 = zeros(numel(nloop),1);
    SL2 = zeros(numel(nloop),1);
    for i=1:numel(nloop)
        disp(['Multiplying arrays size [3,3,1] ',num2str(nloop(i)),' times'])
        a = rand(3,3,1);
        b = rand(3,3,1);
        
        % Time Matlab intrinsic
        tic
        c0 = zeros(3,3,1);
        for j = 1:nloop(i)
            c0 = c0 + (a+j/1e5)*(b+j/1e5);
        end
        TL0(i) = toc;
        SL0(i) = sum(c0(:));     % use result of matrix multiplication; avoids optimisation
        
        % Time mtimes_array
        tic
        c1 = zeros(3,3,1);
        for j = 1:nloop(i)
            c1 = c1 + mtimes_array(a+j/1e5,b+j/1e5);
        end
        TL1(i) = toc;
        SL1(i) = sum(c1(:));     % use result of matrix multiplication; avoids optimisation
        
        % Time mtimes_horace
        tic
        c2 = zeros(3,3,1);
        for j = 1:nloop(i)
            c2 = c2 + mtimes_array(a+j/1e5,b+j/1e5);
        end
        TL2(i) = toc;
        SL2(i) = sum(c2(:));     % use result of matrix multiplication; avoids optimisation
    end
    % Concatenate
    TL = [TL0,TL1,TL2];
    TL = 1e6 * TL./n(:);  % microseconds per loop
else
    SL0 = 0;
    SL1 = 0;
    SL2 = 0;
    TL = NaN(0,2);
end

% Silly thing to prevent optimisation
if (sum(S1)+sum(S2)+sum(SL0)+sum(SL1)+sum(SL2)) <-1e30
    disp('Ooer!')
end
