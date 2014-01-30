function wout=set_header_fudge(w,field,varargin)
% Fudge to get around the object hierarchy in set functions that prevents direct assignment
% of sample or instrument fields to objects
wout=w;
tmp=wout.header;
if isstruct(tmp)
    if numel(varargin)~=1, error('Check number of values'), end
    tmp.(field)=varargin{1};
else
    if numel(varargin)==1
        for i=1:numel(tmp)
            tmp{i}.(field)=varargin{1};
        end
    elseif numel(varargin)==numel(tmp)
        for i=1:numel(tmp)
            tmp{i}.(field)=varargin{i};
        end
    else
        error('Check number of values')
    end
end
wout.header=tmp;
