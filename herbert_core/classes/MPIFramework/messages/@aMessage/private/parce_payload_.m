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




if iscell(payload)
    payload_p  = cellfun(@(c)parce_payload_(c),payload,...
        'UniformOutput',false);
elseif isstruct(payload)
    names=fieldnames(payload);
    if numel(payload) > 1
        % NOT IMPLEMENTED EFFICIENTLY. NEEDS RETHINKING
        data = struct2cell(payload);
        data = cellfun(@(c)parce_payload_(c),data,...
            'UniformOutput',false);
        payload_p = cell2struct(data,names,1);
    else
        for j=1:numel(names)
            payload_p.(names{j}) = parce_payload_(payload.(names{j}));
        end
    end
elseif isobject(payload)
    
    if isa(payload,'MException')
        payload   = MException_her(payload);
    end
    try
        payload_p = payload.saveobj();
    catch ME % left for debugging purposes.
        payload_p  = parce_payload_(struct(payload));
    end
    % service field used by a parce_payload_ /restore_payload_  only to
    % identify class.
    % let's make it strange and unique for aMessage. And shorter, as its
    % serialized too.
    payload_p.cln_4_amess = class(payload);
else
    payload_p = payload;
end

