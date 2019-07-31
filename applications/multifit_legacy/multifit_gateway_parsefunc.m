function [ok,mess,varargout] = multifit_gateway_parsefunc (varargin)
% Gateway function to argument testing capability of multifit_main
%
%   >> [ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] =...
%                   multifit_gateway_parsefunc (...)
%
% This function checks the syntax for the functions, the argument lists and
% consistency of free parameters and parameter bindings. It can be useful to
% check these arguments and take appropriate action in a calling function, or
% the return arguments can be manipulated in more sophisticated use of
% multifit (e.g. nesting functions)
%
% Input:
% ------
%   ...         Arguments as they would be passed to multifit
%
% Output:
% -------
%   ok          True if all ok, false if there is a syntax problem.
%   mess        Character string containing error message if ~ok; '' if ok
%   pos         Position of foreground function handle argument in input
%              argument list
%   func        Cell array of function handle(s) to foreground function(s)
%   plist       Cell array of parameter lists, one per foreground function
%   pfree       Cell array of logical row vectors, one per foreground function,
%              describing which parameters are free or not
%   pbind       Structure defining the foreground function binding, each field
%              a cell array with the same size as the corresponding functions
%              array:
%           ipbound     Cell array of column vectors of indicies of bound
%                      parameters, one vector per function
%           ipboundto   Cell array of column vectors of the parameters to
%                      which those parameters are bound, one vector per
%                      function
%           ifuncboundto  Cell array of column vectors of single indicies
%                      of the functions corresponding to the free parameters,
%                      one vector per function. The index is ifuncfree(i)<0
%                      for foreground functions, and >0 for background functions.
%           pratio      Cell array of column vectors of the ratios
%                      (bound_parameter/free_parameter),if the ratio was
%                      explicitly given. Will contain NaN if not (the ratio
%                      will be determined from the initial parameter values).
%                      One vector per function.
%   bpos        Position of background function handle argument in input 
%              argument list
%   bfunc       Cell array of function handle(s) to background function(s)
%   bplist      Cell array of parameter lists, one per background function
%   bpfree      Cell array of logical row vectors, one per background function,
%              describing which parameters are free or not
%   bpbind      Structure defining the background function binding, with the
%              same format as the foreground binding structure above.
%   narg        Total number of arguments excluding keyword-value options
%
% The size of the cell arrays is the same as the func array or bfunc array
% for the foreground and background parameter output.
%
% If there is an error (i.e. ok==false) then the output arguments are all =[].
%
% To convert the binding structures back into cell arrays as required for input
% into multifit, use the function multifit_gateway_pbind_struct_to_cell. For
% example:
%   >> [ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] =...
%                   multifit_gateway_parsefunc (varargin{:});
%   >> pbind_cell = multifit_gateway_pbind_struct_to_cell (pbind);
%   >> bpbind_cell= multifit_gateway_pbind_struct_to_cell (bpbind);
 
 
% Original author: T.G.Perring 
% 
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $) 


[ok,mess,parsing,output]=multifit_main(varargin{:},'parsefunc_');
nout=nargout-2;
varargout(1:nout)=output(1:nout);   % appears to work even if nout<=0
