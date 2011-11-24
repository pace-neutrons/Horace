function varargout=multifit_gateway(varargin)
% Gateway function to multifit
%
% For help on multifit, type:
%
%   >> help multifit

% This function exists to enable a method for a class to be called 'multifit'
%
%   >> [ok,mess,wfit,fitdata] = multifit_main (...)
%   >> [ok,mess,pos,func,plist,bpos,bfunc,bplist] = multifit_main (...)

[ok,mess,output]=multifit_main(varargin{:});
if ok
    n=min(numel(output),nargout);
    varargout(1:n)=output(1:n);
else
    error(mess)
end
