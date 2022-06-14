function [ok,mess,pfree]=pfree_parse(pfree_in,np)
% Determine if an argument is a valid pfree and expand input argument to full argument
%
%   >> [ok,mess,pfree]=pfree_parse(pfree_in,np)
%
% Input:
% ------
%   pfree_in    Description of which parameters are free and which are fixed
%
%               If there is only one function, that is, it applies globally
%              to all datasets, then pfree_in must be:
%                - An empty argument (which means all parameters are free)
%                - A row vector of zeros and ones (or a row of logicals)
%                 indicating which parameters are fixed or free for a function.
%                Equivalently:
%                - A cell array with a single row vector
%
%               If there is more than one function, that is they apply locally,
%              one function per dataset, then pfree_in must be:
%                - An empty argument (which means all parameters are free for all functions)
%                - A cell array of row vectors, one per function
%                - A single row vector (or a cell array with a single row vector) which
%                 will be repeated for each function
%
%   np          Array with number of parameters for each function
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   pfree       Cell array with same size as input argument np, of logical
%              row vectors, where the number of elements of the ith vector
%              equals the number of parameters for the ith function, and with
%              elements =true for free parameters, =false for fixed parameters
%               If not OK, pfree={}
%
%
%  EXAMPLES of pfree_in:
%   If just one function:
%      [0,1,1,0]
%     {[0,1,1,0]}   % valid, but it is unnecessary to make it a cell
%
%   If two functions:
%      [0,1,1,0]    % applies to both functions; valid if both have four parameters
%     {[0,1,1,0]}   % equivalent syntax
%     {[0,1,1,0],[0,0,1,0]}     % to have different free parameters
%     {[0,1,1,0],[0,0,1]}       % if the functions have four and three parameters respectively


ok=false;
pfree={};

if isempty(pfree_in)    % Empty argument; assume all parameters are free
    pfree=cell(size(np));
    for i=1:numel(np)
        [ok_tmp,mess,pfree{i}]=pfree_parse_single({},np(i));
    end
    ok=true;
    mess='';
    
elseif iscell(pfree_in)
    if isscalar(pfree_in)   % the parameter list is assumed to apply for every function
        [ok_tmp,mess,pfree_tmp]=pfree_parse_single(pfree_in{1},np(1));
        if ~ok_tmp
            mess=['Function index ',arraystr(size(np),1),': ',mess];
            return
        end
        if ~all(np(:)==np(1))
            mess='A single free parameter list only valid if all functions have same number of parameters';
            return
        end
        pfree=cell(size(np));
        for i=1:numel(np)
            pfree{i}=pfree_tmp;
        end
        ok=true;
        mess='';
    elseif numel(pfree_in)==numel(np)
        pfree=cell(size(np));
        for i=1:numel(np)
            [ok,mess,pfree{i}]=pfree_parse_single(pfree_in{i},np(i));
            if ~ok
                pfree={};
                mess=['Function index ',arraystr(size(np),i),': ',mess];
                return
            end
        end
        ok=true;
        mess='';
    else
        mess='Array of free parameters lists is not scalar or does not have same size as array of data sources';
        return
    end
    
elseif isnumeric(pfree_in)  % Numeric argument; assume applies to all functions
    [ok_tmp,mess,pfree_tmp]=pfree_parse_single(pfree_in,np(1));
    if ~ok_tmp
        return
    end
    if ~all(np(:)==np(1))
        mess='A single free parameter list only valid if all functions have same number of parameters';
        return
    end
    pfree=cell(size(np));
    for i=1:numel(np)
        pfree{i}=pfree_tmp;
    end
    ok=true;
    mess='';
    
else
    mess='Free parameter list must be empty, numeric or logical array or a cell array of numeric or logical arrays';
    return
end

%----------------------------------------------------------------------------------------------------------------------
function [ok,mess,pfree]=pfree_parse_single(pfree_in,np)
% Determine if an argument is a valid pfree and expand input argument to full argument
%
%   >> [ok,mess,pfree]=pfree_parse_single(pfree_in,np)
%
% Input:
% ------
%   pfree_in    Vector describing which parameters are free and which are fixed. Must be:
%               - empty, then all parameters are free
%               - numeric vector of zeros and ones, or logical vector
%   np          Number of parameters in total
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   pfree       Logical row vector length np with elements =true for free parameters,
%              and =false for fixed parameters

if isempty(pfree_in)
    ok=true;
    pfree=true(1,np);
    mess='';
elseif (isnumeric(pfree_in)||islogical(pfree_in))
    if isvector(pfree_in) && numel(pfree_in)==np   % note: isvector(arg)==0 if isempty(arg)
        if isnumeric(pfree_in) && all(pfree_in==1|pfree_in==0)
            ok=true;
            pfree=logical(pfree_in(:)');
            mess='';
        elseif islogical(pfree_in)
            ok=true;
            pfree=pfree_in(:)';
            mess='';
        else
            ok=false;
            pfree=true(0);
            mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
        end
    else
        ok=false;
        pfree=true(0);
        mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
    end
else
    ok=false;
    pfree=true(0);
    mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
end
