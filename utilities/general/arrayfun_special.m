function varargout = arrayfun_special (func_handle, varargin)
% Fixup arrayfun so that it works for classes for which it *should* work but doesn't
%
%   >> [B1, B2,...] = arrayfun_fixup (funchandle, A1, A2, ...)
%
% Input:
% ------
%   funchandle      Function handle
%                   Must have form:
%                       [B1, B2,...] = arrayfun_fixup (funchandle, A1, A2, ...)
%                  where B1,B2,... and A1,A2,... are scalars
%                   Note that array expansion and nonuniform output are not
%                  permitted in this simple fixup
%
%   A1, A2, ...     Arrays of input arguments
%
% Output:
% -------
%   B1, B2,...      Arrays of output arguments


% Check input arguments
if numel(varargin)>=2 && is_string(varargin{end-1}) &&...
        strncmpi(varargin{end-1},'UniformOutput',numel(varargin{end-1})) &&...
        islognumscalar(varargin{end})
    UniformOutput = logical(varargin{end});
    narg = numel(varargin) - 2;
else
    UniformOutput = true;
    narg = numel(varargin);
end

args = [cell(1,narg),'UniformOutput',UniformOutput];
for i=1:narg
    args{i} = num2cell(varargin{i});
end

% Evaluate function. Need to use eval in general, but best avoided (see
% Matlab documentation). Therefore hard code the cases for a few return arguments
nout = nargout;
if nout==0
    func_handle(args{:});
elseif nout==1
    varargout{1} = cellfun(func_handle,args{:});
elseif nout==2
    [varargout{1},varargout{2}] = cellfun(func_handle,args{:});
elseif nout==3
    [varargout{1},varargout{2},varargout{3}] = cellfun(func_handle,args{:});
elseif nout==4
    [varargout{1},varargout{2},varargout{3},varargout{4}] = cellfun(func_handle,args{:});
elseif nout==5
    [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = cellfun(func_handle,args{:});
else
    cmdstr=[{'['},arrayfun(@(x)(['varargout{',num2str(x),'},']),(1:nout-1),'UniformOutput',0),...
        {['varargout{',num2str(nout),'}] = cellfun(@',func2str(func_handle),', args{:});']}];
    eval(strcat(cmdstr{:}));
end
