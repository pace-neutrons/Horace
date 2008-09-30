function wtot = combine(w1,varargin)
% Combines one dimensional datasets with identical x axes into a new workspace.
% The data set are "glued" together at the points x1,x2..xn-1
% with a smoothing function that extends +/-(delta/2) about those points.
%
% Syntax:
%   >> wout = combine (w1, x1, w2, delta)                   % minimum case
%
%   >> wout = combine (w1, x1, w2, x2 ... xn-1, wn, delta)  % general case

for i=2:2:length(varargin)
    if isa(varargin{i},'d1d') && length(varargin{i})==1
        varargin{i}=d1d_to_spectrum(varargin{i});
    else
        error ('Check that the datasets are single, not array &/or argument types')
    end
end

for i=1:2:length(varargin)
    if ~(isa(varargin{i},'double') && length(varargin{i})==1)
        error ('Check that the merge points and merge width are numeric scalars')
    end
end

stot=combine(d1d_to_spectrum(w1),varargin{:});
wtot=combine_d1d_spectrum(w1,stot);