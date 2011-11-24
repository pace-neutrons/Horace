function [ok,mess,ibpbind,ibpfree,ibfuncbind,rbpbind]=bkd_pbind_valid_syntax(bpbind_in,np,nbp)
% Determine if an argument has syntax to be a valid binding description for a function
%
%   >> [ok,mess,ipbind,ipfree,ifuncbindrbpbind]=pbind_valid_syntax(bpbind_in,np,nbp,ind)
%
% Input:
% ------
%   bpbind  Binding description that is made from a cell array of binding descriptions
%           for a single function:
%           Binding description element can be:
%               {}              empty cell array
%               {1,3}           cell array with 2 scalars
%               {1,3,0}
%               {1,3,[7,3,2]}   cell array with 2 scalars and a vector
% 
%           Full binding description can be a cell array of such objects
%
%   np      Number of parameters in global function
%   nbp     Number of parameters in background functions
%           Note: size(nbp)=size of array of data objects
%
% Output:
% -------
%   ok          =true if valid, =false if not
%   mess        Error message if ~OK; is '' if OK
%   ibpbind     Cell array of arrays of indicies of bound parameter in the range 1->nbp(ind)
%               for 1<=ind<=numel(nbp)
%   ibpfree     Cell array of arrays of the parameters to which those parameters are bound, in the
%               range 1->np(ifuncbind(i)) for each element i of the array.
%   ibfuncbind  Cell array of arrays of single indicies of the functions corresponding
%               to the free parameters
%   rpbind      Cell array of arrays of the ratios bound_parameter/free_parameter, if given. Will contain NaN if not.

ok=false;
ibpbind={}; ibpfree={}; ibfuncbind={}; rbpbind={};

if iscell(bpbind_in) && ~isempty(bpbind_in)
    if isscalar(bpbind_in)
        ibpbind=cell(size(nbp)); ibpfree=cell(size(nbp)); ibfuncbind=cell(size(nbp)); rbpbind=cell(size(nbp));
        for i=1:numel(nbp)
            [ok,mess,ibpbind{i},ibpfree{i},ibfuncbind{i},rbpbind{i}]=pbind_valid_syntax(bpbind_in{1},np,nbp,i);
            if ~ok
                ibpbind={}; ibpfree={}; ibfuncbind={}; rbpbind={};
                mess=['Background ',arraystr(size(nbp),i),': ',mess];
                return
            end
        end
        ok=true;
        mess='';
    elseif isequal(size(bpbind_in),size(nbp))
        ibpbind=cell(size(nbp)); ibpfree=cell(size(nbp)); ibfuncbind=cell(size(nbp)); rbpbind=cell(size(nbp));
        for i=1:numel(nbp)
            [ok,mess,ibpbind{i},ibpfree{i},ibfuncbind{i},rbpbind{i}]=pbind_valid_syntax(bpbind_in{i},np,nbp,i);
            if ~ok
                ibpbind={}; ibpfree={}; ibfuncbind={}; rbpbind={};
                mess=['Background ',arraystr(size(nbp),i),': ',mess];
                return
            end
        end
        ok=true;
        mess='';
    else
        mess='Background bind parameters list is not scalar or does not have same size as array of data sources';
        return
    end

elseif isempty(bpbind_in)
    % We will allow this as a special case, as so commonly will be entered, even if not rigorously valid syntax
    ibpbind=cell(size(nbp)); ibpfree=cell(size(nbp)); ibfuncbind=cell(size(nbp)); rbpbind=cell(size(nbp));
    for i=1:numel(nbp)
        [ok,mess,ibpbind{i},ibpfree{i},ibfuncbind{i}]=pbind_valid_syntax({},np,nbp,i);
    end
    ok=true;
    mess='';
    
else
    mess='Background bind parameter list must be empty, numeric array or a cell array';
    return
end
