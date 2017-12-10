function [ntot,arg]=wanker(varargin)
ntot=numel(varargin);
if ntot>0
    name=inputname(1);
    disp(name)
    arg=varargin{end};
else
    arg='Fuckit!';
end
