function [ok,mess,pfree]=pfree_valid_syntax(pfree_in,np)
% Determine if an argument is a valid pfree and expand input argument to full argument

if isnumeric(pfree_in)||islogical(pfree_in)
    if isvector(pfree_in) && numel(pfree_in)==np   % note: isvector(arg)==0 if isempty(arg)
        if isnumeric(pfree_in) && all(pfree_in==1|pfree_in==0)
            ok=true;
            pfree=logical(pfree_in);
            mess='';
        elseif islogical(pfree_in)
            ok=true;
            pfree=pfree_in;
            mess='';
        else
            ok=false;
            pfree=true(0);
            mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
        end
    elseif isempty(pfree_in)
        ok=true;
        pfree=true(1,np);
        mess='';
    else
        ok=false;
        pfree=true(0);
        mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
    end
elseif isempty(pfree_in)
    ok=true;
    pfree=true(1,np);
    mess='';
else
    ok=false;
    pfree=true(0);
    mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
end
