function [ok,mess,pfree,pbind]=function_optional_args_parse(isforeground,np,nbp,varargin)
% Parse the optional fit function arguments
%
%   >> [ok,mess,pfree,pbind]=pbind_parse(isforeground,np,nbp)
%   >> [ok,mess,pfree,pbind]=pbind_parse(isforeground,np,nbp,pfree)
%   >> [ok,mess,pfree,pbind]=pbind_parse(isforeground,np,nbp,pfree,pbind)
%
% Input:
% ------
%   isforeground  Logical flag
%                - true  if binding descrption is for foreground function(s)
%                - false if binding descrption is for background function(s)
%
%   np          Number of parameters in foreground functions
%               (array with same size as foreground functions array)
%
%   nbp         Number of parameters in background functions
%               (array with same size as background functions array)
%
%   pfree_in    Description of which parameters are free and which are fixed
%               See function pfree_parse for details
%
%   pbind       Binding descriptions
%               See function pbind_parse for details
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%
%   pfree       Cell array with same size as input argument np or nbp (as
%              determined by the value of input argument isforeground), of logical
%              row vectors, where the number of elements of the ith vector
%              equals the number of parmaeters for the ith function, and with
%              elements =true for free parameters, =false for fixed parameters
%               If not OK, pfree={}
%
%   pbind       Structure with four fields, each a cell array with the same size
%              as the corresponding functions array as given by size(np) or size(nbp)
%  
%       ipbound     Cell array of column vectors of indicies of bound parameters,
%                  one vector per function
%       ipboundto   Cell array of column vectors of the parameters to which those
%                  parameters are bound, one vector per function
%       ifuncboundto  Cell array of column vectors of single indicies of the functions
%                  corresponding to the free parameters, one vector per function. The
%                  index is ifuncfree(i)<0 for foreground functions, and >0 for
%                  background functions.
%       pratio      Cell array of column vectors of the ratios (bound_parameter/free_parameter),
%                  if the ratio was explicitly given. Will contain NaN if not (the
%                  ratio will be determined from the initial parameter values). One
%                  vector per function.
%               If not OK, then pbind=struct([]) (i.e. empty structure)

if isforeground
    func_type_str='Foreground function(s): ';
    np_in=np;
else
    func_type_str='Background function(s): ';
    np_in=nbp;
end

pfree_err={};           % empty cell array
pbind_err=struct([]);   % empty structure

narg=numel(varargin);
if narg<=2
    if narg==0
        pfree_in={};
        pbind_in={};
    elseif narg==1
        pfree_in=varargin{1};
        pbind_in={};
    elseif narg==2
        pfree_in=varargin{1};
        pbind_in=varargin{2};
    end
    % Check pfree
    [ok,mess,pfree]=pfree_parse(pfree_in,np_in);
    if ~ok
        mess=[func_type_str,mess];
        pfree=pfree_err; pbind=pbind_err; return
    end
    % Check pbind
    [ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse(pbind_in,isforeground,np,nbp);
    pbind=struct('ipbound',{ipbound},'ipboundto',{ipboundto},'ifuncboundto',{ifuncboundto},'pratio',{pratio});
    if ~ok
        pfree=pfree_err; pbind=pbind_err; return
    end
    
else
    ok=false;
    mess=[func_type_str,'Too many optional arguments'];
    pfree=pfree_err;
    pbind=pbind_err;
    return
end
