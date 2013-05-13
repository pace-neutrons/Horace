function [ok,mess,bpfree]=bkd_pfree_valid_syntax(bpfree_in,nbp)
% Determine if an argument is a valid background pfree and expand input argument to full argument

ok=false;
bpfree={};
if iscell(bpfree_in) && ~isempty(bpfree_in)
    if isscalar(bpfree_in)
        [ok_tmp,mess,bpfree_tmp]=pfree_valid_syntax(bpfree_in{1},nbp(1));
        if ~ok_tmp
            mess=['Background ',arraystr(size(nbp),1),': ',mess];
            return
        end
        if ~all(nbp(:)==nbp(1))
            mess='Single background free parameter list only valid if all background functions have same number of parameters';
            return
        end
        bpfree=cell(size(nbp));
        for i=1:numel(nbp)
            bpfree{i}=bpfree_tmp;
        end
        ok=true;
        mess='';
    elseif isequal(size(bpfree_in),size(nbp))
        bpfree=cell(size(nbp));
        for i=1:numel(nbp)
            [ok,mess,bpfree{i}]=pfree_valid_syntax(bpfree_in{i},nbp(i));
            if ~ok
                bpfree={};
                mess=['Background ',arraystr(size(nbp),i),': ',mess];
                return
            end
        end
        ok=true;
        mess='';
    else
        mess='Background free parameters list is not scalar or does not have same size as array of data sources';
        return
    end

elseif isempty(bpfree_in)
    % We will allow this as a special case, as so commonly will be entered, even if not rigorously valid syntax
    bpfree=cell(size(nbp));
    for i=1:numel(nbp)
        [ok_tmp,mess,bpfree{i}]=pfree_valid_syntax({},nbp(i));
    end
    ok=true;
    mess='';
    
elseif isnumeric(bpfree_in)
    % We will allow the form [1,0,1,1] as a special case, as so commonly will be entered, even if not rigorously valid syntax
    [ok_tmp,mess,bpfree_tmp]=pfree_valid_syntax(bpfree_in,nbp(1));
    if ~ok_tmp
        mess=['Background: ',mess];
        return
    end
    if ~all(nbp(:)==nbp(1))
        mess='Single background free parameter list only valid if all background functions have same number of parameters';
        return
    end
    bpfree=cell(size(nbp));
    for i=1:numel(nbp)
        bpfree{i}=bpfree_tmp;
    end
    ok=true;
    mess='';

else
    mess='Background free parameter list must be empty, numeric array or a cell array';
    return
end
