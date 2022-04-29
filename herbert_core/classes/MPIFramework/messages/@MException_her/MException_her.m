classdef MException_her < MException
    %class define MException, recovered/prepared from/to custom serialization
    % as we can not set up and restore dbstack for normal Matlab exception
    %
    properties
        % holder for stack variable, which can not be set up on MException
        % class.
        stack_r=struct(zeros(0,1));
    end
    
    methods
        
        function obj = MException_her(anInput,message,stack)
            % Custom MException constructor
            if isa(anInput,'MException') || isstruct(anInput)
                if isa(anInput,'MException_her')  % Copy constructor
                    identifier = anInput.identifier;
                    message    = anInput.message;
                    stack      = anInput.stack_r;
                else % restore from MExeption or recovered structure
                    identifier = anInput.identifier;
                    message    = anInput.message;
                    if isfield(anInput,'stack') || isprop(anInput,'stack')
                        stack      = anInput.stack;
                    end
                end
            elseif ischar(anInput)  % use MException form
                identifier= anInput; % message also have to be present.
                anInput = struct();
            end
            obj = obj@MException(identifier,message);
            if exist('stack', 'var') && ~isempty(stack)
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
        %
        function mex_struc = saveobj(obj)
            % overload, giving access to custom saveobj
            mex_struc = MException_to_struct_(obj);
        end
        %
        function [rep,exc] = getReport(obj)
            % function generates the report for custom serializable
            % extension.
            exc = obj.build_MException(obj);
            rep = getReport(exc);
        end
    end
    methods(Access=protected)
    end
    methods(Static)
        function me = loadobj(mex_struc)
            % overload, giving access to custom loadobj
            me = MException_her(mex_struc);
        end
        function MEx = build_MException(input)
            % build normal exception from the contents of the
            % MException_her class provided as input
            %
            if ~isa(input,'MException')
                error('HERBERT:MException_her:invalid_argument',...
                    'the function needs to be called with the instance of MException or MException_her');
            end
            try
                if isa(input,'MException_her')
                    if isempty(input.stack_r)
                        rethrow(struct('identifier',input.identifier,...
                        'message',input.message));
                    else
                        rethrow(struct('identifier',input.identifier,...
                        'message',input .message,'stack',input.stack_r));
                    end
                else % its already MException
                   rethrow(input);
                end
            catch MEx
                if ~strcmpi(MEx.identifier,input.identifier) % MException has been build as a class and can not be rethown
                    % stack has no value, so can be ignored.
                    MEx = input;
                end
            end
            if (isfield(input,'cause') || isprop(input,'cause')) && ...
                    ~isempty(input.cause)
                for i=1:numel(input.cause)
                    cse = input.cause{i};
                    me = MException_her.build_MException(cse);
                    MEx = MEx.addCause(me);
                end
            end
        end
        
    end
end

