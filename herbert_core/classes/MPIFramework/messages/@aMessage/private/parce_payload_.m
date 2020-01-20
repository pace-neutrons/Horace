function payload_p = parce_payload_(payload)
% Analyse the data structure, provided as input and modify the classes
% which are not serializable into the form, accepting serialization
%
%
% Itput:
% ------
%   payload -- the class, structure or variable to analyze
%
% Output:
% -------
%   payload_p  -- modified input, containing all serializable classes


payload_p = payload;

if iscell(payload)
    for i=1:numel(payload)
        payload_p{i}= parce_payload_(payload{i});
    end
    
elseif isstruct(payload)
    names=fieldnames(payload);
    for i=1:numel(payload)
        for j=1:numel(names)
            payload_p(i).(names{j}) = parce_payload_(payload(i).(names{j}));
        end
    end
elseif isobject(payload)
    if isa(payload,'MException')
        payload_p = MException_her(payload);
    end
end

