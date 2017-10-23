function [ok,mess]=equal_to_tol_private(a,b,opt,name_a,name_b)
% Check the equality of two arguments within defined tolerance
% Used by public functions equal_to_tol and equaln_to_tol
%
%   >> [ok, mss] = equal_to_tol_private (a, b, opt, obj_name)
%
% Input:
% ------
%   a, b        Arguments to be compared
%   opt         Structure giving comparison options
%                   ignore_str  If true: ignore length and contents of
%                              and cell arrays of strings
%                   nan_equal   If true: NaNs are considered equal
%                   tol         Two element array [abs_tol, rel_tol] of
%                              absolute and relative tolerance. If either is
%                              satisfied then equality within tolerance is
%                              accepted
%   ind         Index of object in an object or cell array


if opt.ignore_str && (iscellstr(a)||ischar(a)) && (iscellstr(b)||ischar(b))
    % Case of strings and cell array of strings if they are to be ignored
    % If cell arrays of strings then contents and number of strings are
    % ignored e.g. {'Hello','Mr'}, {'Dog'} and '' are all considered equal
    
elseif isobject(a) && isobject(b)
    % --------------------------
    % Both arguments are objects
    % --------------------------
    % Check sizes of arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        ok=false;
        mess=sprintf('%s and %s: Sizes of arrays of objects being compared are not equal',...
            name_a,name_b);
        return
    end
    
    % Check fieldnames are identical
    fields=fieldnames(struct(a));       % gets hidden properties too
    if ~isequal(fields,fieldnames(struct(b)))
        ok=false;
        mess=sprintf('%s and %s: Fieldnames of classes being compared are not identical',...
            name_a,name_b);
        return
    end
    
    for i=1:numel(a)
        if numel(a)>1
            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
        else
            name_a_ind = name_a;
            name_b_ind = name_b;
        end
        Sa = struct(a(i));
        Sb = struct(b(i));
        for j=1:numel(fields)
            [ok,mess] = equal_to_tol_private(Sa.(fields{j}), Sb.(fields{j}), opt,...
                [name_a_ind,'.',fields{j}], [name_b_ind,'.',fields{j}]);
            if ~ok, return, end
        end
    end
    
elseif isstruct(a) && isstruct(b)
    % -----------------------------
    % Both arguments are structures
    % -----------------------------
    % Check sizes of structure arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        ok=false;
        mess=sprintf('%s and %s: Sizes of arrays of structures being compared are not equal',...
            name_a,name_b);
        return
    end
    
    % Check fieldnames are identical
    fields=fieldnames(a);
    if ~isequal(fields,fieldnames(b))
        ok=false;
        mess=sprintf('%s and %s: Fieldnames of structures being compared are not identical',...
            name_a,name_b);
        return
    end
    
    % Check contents of each field are the same
    for i=1:numel(a)
        if numel(a)>1
            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
        else
            name_a_ind = name_a;
            name_b_ind = name_b;
        end
        for j=1:numel(fields)
            [ok,mess] = equal_to_tol_private (a(i).(fields{j}), b(i).(fields{j}), opt,...
                [name_a_ind,'.',fields{j}], [name_b_ind,'.',fields{j}]);
            if ~ok, return, end
        end
    end
    
elseif iscell(a) && iscell(b)
    % ------------------------------
    % Both arguments are cell arrays
    % ------------------------------
    % Check sizes of structure arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        ok=false;
        mess=sprintf('%s and %s: Sizes of cell arrays being compared are not equal',...
            name_a,name_b);
        return
    end
    
    % Check contents of each element of the arrays
    for i=1:numel(a)
        name_a_ind = [name_a,'{',arraystr(sz,i),'}'];
        name_b_ind = [name_b,'{',arraystr(sz,i),'}'];
        [ok,mess] = equal_to_tol_private (a{i} ,b{i}, opt, name_a_ind, name_b_ind);
        if ~ok, return, end
    end
    
elseif isnumeric(a) && isnumeric(b)
    % ---------------------------------
    % Both arguments are numeric arrays
    % ---------------------------------
    [ok,mess]=equal_to_tol_numeric(a,b,opt.tol,opt.nan_equal,name_a,name_b);
    if ~ok, return, end
    
elseif ischar(a) && ischar(b)
    % -----------------------------------
    % Both arguments are character arrays
    % -----------------------------------
    % Check sizes of structure arrays are the same
    if ~isequal(size(a),size(b))
        ok=false;
        mess=sprintf('%s and %s: Sizes of character arrays being compared are not equal',...
            name_a,name_b);
        return
    end
    
    if ~strcmp(a,b)
        ok=false;
        mess=sprintf('%s and %s: Character arrays being compared are not equal',...
            name_a,name_b);
        return
    end
    
elseif strcmp(class(a),class(b))
    % ------------------------------------------------------------------------
    % Catch-all for anything else - should hsve been caught by the cases above
    % but Alex had added it (I think), so maybe it was needed
    % ------------------------------------------------------------------------
    if ~isequal(size(a),size(b))
        ok=false;
        mess=sprintf('%s and %s: Sizes of arrays of objects being compared are not equal',...
            name_a,name_b);
        return
    end
    
    if ~isequal(a,b)
        ok=false;
        mess=sprintf('%s and %s: Object (or object arrays) are not equal',...
            name_a,name_b);
        return
    end
    
else
    % -----------------------------------------------
    % Items being compared do not have the same class
    % -----------------------------------------------
    ok=false;
    mess=sprintf('%s and %s: Have different classes: %s and %s',...
        name_a,name_b,class(a),class(b));
    return
end
ok=true; mess='';


%--------------------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_numeric(a,b,tol,nan_equal,name_a,name_b)
% Check two arrays have smae size and each element is the same within
% requested relative or absolute tolerance. 

if isequal(size(a),size(b))
    % Turn arrays into vectors (avoids problems with matlab changing shapes
    % of arrays when logical filtering is performed
    sz=size(a);
    a=a(:);
    b=b(:);
    
    % Treatment of NaN elements
    if nan_equal
        % If NaNs are to be ignored, remove them from consideration
        keep=~isnan(a);
        if ~all(keep==~isnan(b))    % check NaNs have the same locations in both arrays
            ok=false;
            mess=sprintf('%s and %s: NaN elements not in same locations in numeric arrays',...
                name_a,name_b);
            return
        elseif ~any(keep(:))        % if all elements are Nans, can simply return
            ok=true;
            mess='';
            return
        elseif ~all(keep(:))        % filter out elements if some to be ignored
            a=a(keep);
            b=b(keep);
        end
    else
        % If any NaNs the equality fails
        bad=(isnan(a)|isnan(b));
        if any(bad)
            ok=false;
            mess=sprintf('%s and %s: NaN elements in one or both numeric arrays',...
                name_a,name_b);
            return
        end
    end
    
    % Treatment of Inf elements
    infs_mark=isinf(a);
    if any(infs_mark)   % Inf elements are present
        if any(infs_mark~=isinf(b))
            ok=false;
            mess=sprintf('%s and %s: Inf elements not in same locations in numeric arrays',...
                name_a,name_b);
            return;
        end
        if any(sign(a(infs_mark))~=sign(b(infs_mark)))
            ok=false;
            ind=find(infs_mark,1);
            mess=sprintf('%s and %s: Inf elements have different signs; first occurence at element %s',...
                name_a,name_b,['(',arraystr(sz,ind),')']);
            return;
        end
        a=a(~infs_mark);            % filter out Inf elements from further consideration
        b=b(~infs_mark);
    end
    
    % Compare elements. Pass the case of empty arrays - these are considered equal
    if ~isempty(a)
        % All elements to be compared are finite (dealt with Inf and NaN above)
        delta_abs = abs(a-b);
        delta_rel = abs(a-b)./max(abs(a),abs(b));
        abs_tol = tol(1);
        rel_tol = tol(2);
        if abs_tol==0 && rel_tol==0 && any(a~=b)
            % Equality required
            ok = false;
            [max_delta,ind] = max(delta_abs);
            mess=sprintf('%s and %s: Not all elements are equal; max. error = %s at element %s',...
                name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
            return
            
        elseif rel_tol==0 && any(delta_abs>abs_tol)
            % Absolute tolerance must be satisfied
            ok= false;
            [max_delta,ind] = max(delta_abs);
            mess=sprintf('%s and %s: Absolute tolerance failure; max. error = %s at element %s',...
                name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
            return
            
        elseif abs_tol==0 && any(delta_rel>rel_tol)
            % Relative tolerance must be satisfied
            ok= false;
            [max_delta,ind] = max(delta_rel);
            mess=sprintf('%s and %s: Relative tolerance failure; max. error = %s at element %s',...
                name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
            return
            
        elseif any((delta_abs>abs_tol)&(delta_rel>rel_tol))
            % Absolute or relative tolerance must be satisfied
            ok= false;
            [max_delta_abs,ind_abs] = max(delta_abs);
            [max_delta_rel,ind_rel] = max(delta_rel);
            if max_delta_rel>max_delta_abs
                mess=sprintf('%s and %s: Relative tolerance failure; max. error = %s at element %s',...
                    name_a,name_b,num2str(max_delta_rel),['(',arraystr(sz,ind_rel),')']);
            else
                mess=sprintf('%s and %s: Absolute tolerance failure; max. error = %s at element %s',...
                    name_a,name_b,num2str(max_delta_abs),['(',arraystr(sz,ind_abs),')']);
            end
            return
        end
    end
    
else
    ok=false;
    mess=sprintf('%s and %s: Different size numeric arrays',...
        name_a,name_b);
    return
end

ok = true;
mess = '';


%--------------------------------------------------------------------------------------------------
function str=arraystr(sz,i)
% Make a string of the form '2,3,1' (or '23' if vector) from a size array and single index

if numel(sz)==2 && (sz(1)==1||sz(2)==1)
    str=num2str(i);
else
    ind=cell(1,numel(sz));
    [ind{:}]=ind2sub(sz,i);
    str='';
    for j=1:numel(ind)
        str=[str,num2str(ind{j}),','];
    end
    str=str(1:end-1);
end
