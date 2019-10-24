function varargout = testgateway_tobyfit (dummy, func_name, varargin)
% Gateway function to enable test of functions in sqw/prvate
%
%   >> [b1,b2,...] = testgateway_tobyfit (sqw, 'myfunc', a1, a2, ...)
%
% This will evaluate the following line from the @sqw/private folder:
%
%   >> [b1,b2,...] = myfunc (a1, a2, ...)
%
% This function is useful to give access to function in the sqw/private
% folder, which otherwise cannot be directly called or debugged.


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


if ~isa(dummy,'sqw')
    error('First argument must be an sqw object (which will be ignored)')
end

if is_string(func_name) && ~isempty(func_name)
    rootpath=fileparts(mfilename('fullpath'));
    full_func_name=fullfile(rootpath,'private',func_name);
    if ~exist(full_func_name,'file')
        error(['File does not exist: ',full_func_name])
    end
else
    error('Check second argument is the name of a function')
end

nout=nargout;
nfunc=nargout(func_name);
func_handle=str2func(func_name);

if nfunc>=0 && nout>nfunc
    % Function being called does not have varargout in output argument list, and
    % there are too many output arguments
    error('Too many output arguments')
else
    % Evaluate function. Need to use eval in general, but best avoided (see
    % Matlab documentation). Therefore hard code the cases for a few return arguments
    if nout==0
        func_handle(varargin{:});
    elseif nout==1
        varargout{1}=func_handle(varargin{:});
    elseif nout==2
        [varargout{1},varargout{2}]=func_handle(varargin{:});
    elseif nout==3
        [varargout{1},varargout{2},varargout{3}]=func_handle(varargin{:});
    elseif nout==4
        [varargout{1},varargout{2},varargout{3},varargout{4}]=func_handle(varargin{:});
    elseif nout==5
        [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}]=func_handle(varargin{:});
    else
        cmdstr='[';
        for i=1:nout
            cmdstr=[cmdstr,'varargout{',num2str(i),'},'];
        end
        cmdstr(end:end)=']';
        cmdstr=[cmdstr,'=',func_name,'(varargin{:});'];
        eval(cmdstr);
    end
end
