function varargout = multifit_gateway (varargin)
% Gateway function to multifit
%
% For help on multifit, type:
%
%   >> help multifit
%
% This function exists for two purposes:
% -  It enables one to write a method for a class to be called 'multifit'. Such a
%   method will always have precedence over the generic multifit. With this function
%   the method called multifit simply needs to call multifit_gateway.
% -  With the 'parsefunc_' keword set to true, it locates the global fitting function
%   and any background functions in the input arguments and performs some
%   syntax checking, withut actually fitting. This has a use, for example, when
%   repackaging the input for a custom call to multifit.
%
% Syntax to match regular use of multifit:
%   >> [wfit,fitdata,ok,mess] = multifit_gateway (...)
%
% Syntax when the 'parsefunc_' keyword is given the value true:
%   >> [pos,func,plist,bpos,bfunc,bplist,ok,mess] = multifit_gateway (...,'parsefunc_')
%
% Output arguments:
% *EITHER*
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           Has the same form as the input data. The only exception is if x,y,e were given as
%          three separate arrays, only ycalc is returned.
%           If there was a problem i.e. ok==false, wout=[]
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of global parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%           If there was a problem i.e. ok==false, fitdata=[]
%
%   ok      True if all ok, false if problem fitting. 
%
%   mess    Character string contaoning error message if ~ok; '' if ok
%
% *OR*
%   pos     position of global fit function handle in input argument list
%   func    function handle to global fit function
%   plist   parameter list to global function
%   bpos    position of argument giving background function handle(s) in input argument list
%   bfunc   cell array of background function handle(s)
%   bplist  cell array of background parameter lists, one per background function
%   ok      True if all ok, false if problem fitting. 
%   mess    Character string contaoning error message if ~ok; '' if ok

[ok,mess,output]=multifit_main(varargin{:});
nout=numel(output);
if ok || nout<nargout   % if not ok, then ok is a return argument
    n=min(nout,nargout);
    varargout(1:n)=output(1:n);
    if nargout>=nout+1, varargout{nout+1}=ok; end
    if nargout>=nout+2, varargout{nout+2}=mess; end
else
    error(mess)
end
