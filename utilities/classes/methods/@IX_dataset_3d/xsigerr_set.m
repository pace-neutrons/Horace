function wout=xsigerr_set(win,iax,x,signal,err,xdistr)
% Set signal, error and selected axes in a single instance of an IX_dataset_3d object
%
%   >> wout=xsigerr_set(win,iax,x,signal,err)
%   >> wout=xsigerr_set(win,iax,x,signal,err,xdistr)
%
%   win     Input IX_dataset_2d
%   iax     Array of axes indicies
%   x       Cell array of coordinate values
%   signal  Signal
%   err     Associated error bars
%   xdistr  (Optional) replacement distribution flag (scalar or array)
%
%   wout    Output IX_dataset_3d

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
    elseif iax(i)==2
        wout.y=x{i};
        if ~isempty(xdistr), wout.y_distribution=xdistr(i); end
    elseif iax(i)==3
        wout.z=x{i};
        if ~isempty(xdistr), wout.z_distribution=xdistr(i); end
    else
        error('Check axis index or indicies')
    end
end

% Check validity - lots of room for errors in use of this method
[ok,mess,wout]=isvalid(wout);   
if ~ok
    error(mess)
end
