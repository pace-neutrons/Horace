classdef Hashing
    %HASHING Independent class providing hash creation functions
    %   Moved from unique_objects_container to allow greater flexibility
    %   of implementation.
    %
    %   provides one single static method which performs the hash
    
    properties
        
    end
    
    methods (Static)
        
        function hash = hashify_obj(obj,reset_count)
            % makes a hash from the argument object which will be unique 
            % when generated from any identical object
            %
            % Input:
            % - obj :         object to be hashed
            % - reset_count : when the counter code is enabled, reset the
            %                 counter to zero
            % Output:
            % - hash :        the resulting has, a row vector of uint8's
            %

            % get config to use use_mex
            hhc = hor_config;
            
            % In case the java engine is going to be used, initialise it as
            % a persistent object
            persistent Engine;
            if isempty(Engine) && ~hhc.use_mex
                Engine = java.security.MessageDigest.getInstance('MD5');
            end

            %{
            % monitor for use of hashing. As the issue of counting number of
            % hashes may continue, leaving it in the code.
            
            persistent count;
            if nargin>2
                count=0;
                hash = []; % unused null value for this case
                return;
            end
            if isempty(count)
                count=0;
            end
            count=count+1;
            count
            disp(class(obj));
            %}

            if isa(obj,'serializable') 
                bytestream = (obj.serialize());
            else
                bytestream = serialize(obj);
            end
            
            if hhc.use_mex
                % mex version to be used, use it
                hash = GetMD5(bytestream);
            else
                % mex version not to be used, manually construct from the
                % Java engine
                Engine.update(bytestream);
                hash0 = Engine.digest;
                
                %using the following typecast to remedy that dec2hex
                %does not work with negative numbers before Matlab 2020b.
                %the typecast moves negative numbers to twos-complement
                %positive representation, as is automatically done by the
                %later dec2hex
                hash1 = typecast(hash0,'uint8');

                hash2 = dec2hex(hash1);
                hash3 = cellstr(hash2);
                hash4 = horzcat(hash3{:});
                hash = lower(hash4);
            end
        end
    end
end
