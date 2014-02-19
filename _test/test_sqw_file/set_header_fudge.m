function wout=set_header_fudge(w,field,val)
% Fudge to get around the object hierarchy in set functions that prevents direct assignment
% of sample or instrument fields to objects
wout=w;
tmp=wout.header;
if isstruct(tmp)
    if numel(val)~=1, error('Check number of values'), end
    tmp.(field)=val;
else
    if numel(val)==1
        for i=1:numel(tmp)
            tmp{i}.(field)=val;
        end
    elseif numel(val)==numel(tmp)
        for i=1:numel(tmp)
            tmp{i}.(field)=val(i);
        end
    else
        error('Check number of values')
    end
end
wout.header=tmp;
