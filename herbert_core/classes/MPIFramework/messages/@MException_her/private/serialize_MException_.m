function mess_struc = serialize_MException_(theException)
% Helper function used to serialize MException
%
% The MExeption class can not be serialzied by hlp_serialize as does not
% posess the requested properties. This is why this helper routine is
% necessary
%
%
mess_struc = build_mes_stuct(theException);


function strct = build_mes_stuct(mexc)

persistent flds;
if isempty(flds)
    flds = {'identifier','message'};
end

strct = struct();
for i=1:numel(flds)
    strct.(flds{i}) = mexc.(flds{i});
end
if isprop(mexc,'stack_r') && ~isempty(mexc.stack_r)
    strct.stack =  mexc.stack_r;
elseif isprop(mexc,'stack') && ~isempty(mexc.stack)
    strct.stack =  mexc.stack;
end

if ~isempty(mexc.cause)
    strct.cause = cell(numel(mexc.cause),1);
    for i=1:numel(mexc.cause)
        strct.cause{i} = build_mes_stuct(mexc.cause{i});
    end
end
