function [ok,mess,nbp,bplist]=bkd_parameter_valid(bplist_in,bkdfunc)
% Check if form of background parameter object is a valid parameter list
%
% Format is one of the following
%   - a cell array of valid parameter lists, one per background function
%   - a cell array with a single valid parameter list; this will be repeated for each background function
%
%   - a numeric vector; which will be repeated as the parameter list for each background function
%
% Return the number of parameters in the numeric vector.
%
% NOTES:
%   A single cell array is NOT valid, even if it is a valid parameter list, because it could
%   in fact be meant to be a cell array of parameter lists, one per function. That is, its
%   meaning is ambiguous, and so is rejected.
%
%
% A valid parameter list has the recursive form:
%   plist<n+1> = {@func<n>, plist<n>, cn_1, cn_2,...};  
%
%   plist<0> = {p, c0_1, c0_2,...}  or p , where p is a numeric vector
%
%
% Defines a recursive form for the parameter list:
%   plist<0> = p               numeric vector
%         or ={p, c1, c2, ...} cell array, with first parameter a numeric vector
%
%   plist<1> = {@func<0>, plist<0>, c1_1, c1_2,...}
%
%   plist<2> = {@func<1>, {@func<0>, plist<0>, c1_1, c1_2,...}, c2_1, c2_2,...}
%          :


ok=false;
nbp=[]; bplist={};

sz=size(bkdfunc);
if iscell(bplist_in)
    if isscalar(bplist_in)
        [ok_tmp,np]=parameter_valid(bplist_in{1});
        if ok_tmp
            nbp=np*ones(sz);
            bplist=cell(sz);
            for i=1:prod(sz)
                bplist{i}=bplist_in{1};
            end
        else
            mess='Background parameter list invalid';
            return
        end
    elseif isequal(size(bplist_in),sz)
        nbp=zeros(sz);
        bplist=cell(sz);
        for i=1:numel(bplist_in)
            [ok_tmp,np]=parameter_valid(bplist_in{i});
            if ok_tmp
                nbp(i)=np;
                bplist{i}=bplist_in{i};
            elseif isempty(bplist_in{i})
                nbp(i)=0;
                bplist{i}=[];
            else
                nbp=[]; bplist={};
                mess=['Background parameter list invalid for element ',arraystr(sz,i)];
                return
            end
        end
    else
        mess='Background parameter list is not scalar or does not have same size as array of data sources';
        return
    end
    
elseif isvector(bplist_in) && isnumeric(bplist_in) && numel(bplist_in)>0
    % Allow as a special case, even if not strictly adhering to our syntax, but will commonly be used
    nbp=numel(bplist_in)*ones(sz);
    bplist=cell(sz);
    for i=1:prod(sz)
        bplist{i}=bplist_in;
    end
    
else
    mess='Background parameter list must be a cell array';
    return
end

% Valid parameter list if reached here. Now check that bpin{i} is empty for missing background functions,
% and liewise that parameters have been provided for functions that are present
for i=1:numel(bkdfunc)
    if isempty(bkdfunc{i}) && ~isempty(bplist{i})
        nbp=[]; bplist={};
        mess=['Background function ',arraystr(size(bkdfunc),i),' is not given, but parameters have been provided for it'];
        return
    elseif ~isempty(bkdfunc{i}) && isempty(bplist{i})
        nbp=[]; bplist={};
        mess=['Background function ',arraystr(size(bkdfunc),i),' has not been given parameters'];
        return
    end
end
ok=true;
mess='';
