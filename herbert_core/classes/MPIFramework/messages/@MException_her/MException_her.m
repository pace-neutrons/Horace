classdef MException_her < MException
    %class define MException, recovered/prepared from serialization
    properties
        stack_r=struct([]);
    end
    
    methods
        function obj = MException_her(anInput,message,stack)
            if isa(anInput,'MException') || isstruct(anInput)
                if isa(anInput,'MException_her')  % Copy constructor
                    identifier = anInput.identifier;
                    message    = anInput.message;
                    stack      = anInput.stack_r;
                else
                    identifier = anInput.identifier;
                    message    = anInput.message;
                    if isfield(anInput,'stack') || isprop(anInput,'stack')
                        stack      = anInput.stack;
                    end
                end
            elseif ischar(anInput)
                identifier= anInput; % all other arguments have to be present
            end
            obj = obj@MException(identifier,message);
            if exist('stack','var') && ~isempty(stack)
                obj.stack_r = stack;
            end
            if (isfield(anInput,'cause') || isprop(anInput,'cause'))...
                    && ~isempty(anInput.cause)
                for i=1:numel(anInput.cause)
                    cs = anInput.cause{i};
                    if ~isa(cs,'MException')
                        if isfield(cs,'stack')
                            cs = MException_her(cs);
                        else
                           cs = MException(cs.identifier,cs.message);
                        end
                    end
                    obj = obj.addCause(cs);
                    
                end
            end
        end
        function bytes = saveobj(obj)
            bytes = serialize_MException_(obj);
        end
    end
    methods(Static)
        function me = loadobj(bytes)
            mes = hlp_deserialize(bytes);
            me = MException_her(mes);
        end
    end
end

