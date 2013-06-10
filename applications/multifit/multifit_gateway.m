function varargout = multifit_gateway (varargin)
% Interface function so that Horace multifit functions can work with latest multifit.
%
% Earlier multifit was designed for only a single foreground function.
% It had only one interface function, multifit_gateway, with two facets:
%
% - If keyword 'parsefunc_' is true in input arguments, parse the function arguments:
%   >> [pos,func,plist,bpos,bfunc,bplist,ok,mess] = multifit_gateway (varargin{:});
%
% - Otherwise, perform the fit:
%   >> [wout,fitdata,ok,mess] = multifit_gateway (varargin{:});
%
% This interface has now replaced with two different function calls:
%
%   >> [ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] =...
%                   multifit_gateway_parsefunc (varargin{:});
%
%   >> [ok,mess,wout,fitdata] = multifit_gateway_main (varargin{:});
%
% There were some small syntactical differences in the output too. This
% function provides an interface to reporduce the previous output.
%
% *** THIS IS A LEGACY FUNCTION ONLY - USE multifit_gateway_parsefunc AND multifit_gateway_main ***

%disp('*** Legacy function call to multifit_gateway. Please update the calling function.')

[ok,mess,parsing,output]=multifit_main(varargin{:});

if parsing
    if ~ok && nargout<=6
        error(mess)
    else
        if numel(output{2})==1  % only a single foreground fuinction is permitted
            func=output{2}{1};
            plist=output{3}{1};
        else
            error('This legacy function in being used where it is not valid')
        end
        if nargout>=1, varargout{1}=output{1}; end
        if nargout>=2, varargout{2}=func; end
        if nargout>=2, varargout{3}=plist; end
        if nargout>=2, varargout{4}=output{6}; end
        if nargout>=2, varargout{5}=output{7}; end
        if nargout>=2, varargout{6}=output{8}; end
        if nargout>=7, varargout{7}=ok; end
        if nargout>=8, varargout{8}=mess; end
    end
else
    if ~ok && nargout<=2
        error(mess)
    else
        if nargout>=1, varargout{1}=output{1}; end
        if nargout>=2, varargout{2}=convert_fitpar(output{2}); end
        if nargout>=3, varargout{3}=ok; end
        if nargout>=4, varargout{4}=mess; end
    end
end

%--------------------------------------------------------------------------------------------------
function fitpar_out = convert_fitpar (fitpar_in)
% Convert current output format for fit parameter to legacy multifit format
fitpar_out=fitpar_in;
for i=1:numel(fitpar_in)
    if isfield(fitpar_in,'bp') && ~iscell(fitpar_in(i).bp)
        fitpar_out(i).bp={fitpar_in(i).bp};
    end
    if isfield(fitpar_in,'bsig') && ~iscell(fitpar_in(i).bsig)
        fitpar_out(i).bsig={fitpar_in(i).bsig};
    end
    if isfield(fitpar_in,'bpnames') && ~iscell(fitpar_in(i).bpnames{1})
        fitpar_out(i).bpnames={fitpar_in(i).bpnames};
    end
end
