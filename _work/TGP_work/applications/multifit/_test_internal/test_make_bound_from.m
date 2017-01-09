function [B,R] = test_make_bound_from (n,varargin)
% Example:
%   >> A = test_make_bound_from (5,[2,3],[3,4,4.3],[5,1,NaN],[1,2])
%   >> A = test_make_bound_from (5,0.2)

% Create a list
if numel(varargin)==1 && numel(varargin{1})==1
    frac=varargin{1};
    arg=num2cell([randperm(n,round(frac*n));randperm(n,round(frac*n))],1);
end

B = sparse([],[],0,n,n,n);
R = sparse([],[],0,n,n,n);
for i=1:numel(arg)
    pb=arg{i}(1);
    pf=arg{i}(2);
    if pf~=pb
        B(pb,:)=0;
        R(pb,:)=0;
        B(pb,pf)=1;
        if numel(arg{i})==2
            R(pb,pf)=NaN;
        else
            R(pb,pf)=arg{i}(3);
        end
    end
end
