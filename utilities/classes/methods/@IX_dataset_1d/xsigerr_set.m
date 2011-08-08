function wout=xsigerr_set(win,iax,x,signal,err)
% Set signal, error and selected axes in a single instance of an IX_dataset_1d object
%
%   >> wout=xse_set(win,iax,x,signal,err)
%
%   win     Input IX_dataset_1d
%   iax     Array of axes indicies (can only be iax=1)
%   x       Cell array of coordinate values
%   signal  Signal
%   err     Associated error bars
%
%   wout    Output IX_dataset_1d
%
% This method exists only for syntactical compatibility with IX_dataset_2d, _3d objects
% so generic methods can apply to all types.

% Set fields
wout=win;
wout.signal=signal;
wout.error=err;
if numel(iax)==1 && ~iscell(x), x={x}; end  % convert to cell for convenience
for i=1:numel(iax)
    if iax(i)==1
        wout.x=x{i};
    else
        error('Check axis index or indicies')
    end
end

% Check validity - lots of room for errors in use of this method
[ok,mess,wout]=isvalid(wout);   
if ~ok
    error(mess)
end
