function wout=xsigerr_set(win,iax,x,signal,err,xdistr)
% Set signal, error and selected axes in a single instance of an IX_dataset_1d object
%
%   >> wout=xsigerr_set(win,iax,x,signal,err)
%   >> wout=xsigerr_set(win,iax,x,signal,err,xdistr)
%
%   win     Input IX_dataset_1d
%   iax     Array of axes indicies (can only be iax=1)
%   x       Cell array of coordinate values
%   signal  Signal
%   err     Associated error bars
%   xdistr  (Optional) replacement distribution flag
%
%   wout    Output IX_dataset_1d
%
% This method exists with this syntax for compatibility with IX_dataset_2d, _3d objects
% so generic methods can apply to all types.

% Set fields
wout=win;
wout.signal=signal;
wout.error=err;
if exist('xdistr','var') && ~isempty(xdistr)
    if isscalar(xdistr)
        xdistr=repmat(logical(xdistr),size(iax));
    else
        xdistr=logical(xdistr);
    end
else
    xdistr=[];
end
if numel(iax)==1 && ~iscell(x), x={x}; end  % convert to cell for convenience
for i=1:numel(iax)
    if iax(i)==1
        wout.x=x{i};
        if ~isempty(xdistr), wout.x_distribution=xdistr(i); end
    else
        error('Check axis index or indicies')
    end
end

% Check validity - lots of room for errors in use of this method
[ok,mess,wout]=isvalid(wout);   
if ~ok
    error(mess)
end
