classdef MException_her < MException
    %class define MException, recovered/prepared from/to custom serialization
    %
    %
    properties
        % holder for stack variable, which can not be set up on MException
        % class.
        stack_r=struct([]);
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
            % overload, giving access to custom saveobj
            bytes = serialize_MException_(obj);
        end
        %
        function [rep,fs] = getReport(obj)
            % function generates the report for custom serializable
            % extension.
            err = obj.stack_r;
            fs = cell(numel(err),1);
            form = ['Error using <a href="matlab:matlab.internal.language.introspective.errorDocCallback(''%s'', ''%s'', %d)"',...
                'style="font-weight:bold">%s</a>',...
                ' (<a href="matlab: opentoline(''%s'',%d,0)">line %d</a>)\n%s\n'];
            fs{1} = sprintf(form,err(1).name,err(1).file,err(1).line,...
                    obj.message,...
                    err(1).file,err(1).line,err(1).line,err(1).name);                        
            for i=2:numel(err)
                %fs{i} = sprintf('line: %d ; fun: %s ; file: %s\n',...
                fs{i} = sprintf(form,err(i).name,err(i).file,err(i).line,...
                    err(i).name,...
                    err(i).file,err(i).line,err(i).line,err(i).name);
            end
            rep = [fs{:}];
        end
    end
    methods(Static)
        function me = loadobj(bytes)
            % overload, giving access to custom loadobj
            mes = hlp_deserialize(bytes);
            me = MException_her(mes);
        end
    end
end

