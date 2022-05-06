classdef unique_objects_container < handle
    %UNIQUE_OBJECTS_CONTAINER Turn an instrument-type object into a hash.
    %   Uses the undocumented getByteStreamFromArray to perform the
    %   conversion.
    % Functionality:
    % - add new object to the container with add(...) - stores only unique
    % objects but keeps a non-unique index to this addition
    % - get an object from that unique index
    
    properties (Access=private)
        stored_objects_ = {}; % the actual unique objects
        stored_hashes_ = [];  % their hashes are stored
        idx_ = [];   % array of unique indices for each non-unique object added
        convert_to_stream_ = @getByteStreamFromArray; % function handle for the stream converter used by hashify
                               % defaults to this undocumented java
                               % function (default respecified in
                               % constructor inputParser)
        baseclass_ = ''; % if not empty, name of the baseclass suitable for isa calls
                        % (default respecified in constructor inputParser)
    end
    
    properties (Dependent) % defined only for debug reporting purposes
        stored_objects;
        stored_hashes;
        idx;
        baseclass;
    end
    
    methods % Dependent props get functions - defined only for reporting purposes
        function x = get.stored_objects(self)
            x = self.stored_objects_;
        end
        function x = get.stored_hashes(self)
            x = self.stored_hashes_;
        end
        function x = get.idx(self)
            x = self.idx_;
        end
    end
    
    methods 
        function hash = hashify(self,obj)
            % makes a hash from the argument object
            % which will be unique to any identical object
            %
            % Input:
            % - obj : object to be hashed
            % Output:
            % - hash : the resulting has, a row vector of uint8's
            %
            Engine = java.security.MessageDigest.getInstance('MD5');
            %convert_to_stream_ = @getByteStreamFromArray;
            Engine.update(self.convert_to_stream_(obj));
            hash = typecast(Engine.digest,'uint8');
            hash = hash';
        end
    end    
    
    methods 
        
        function [ix, hash] = is_in_container(self,obj)
            %IS_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj : the object which may or may not be uniquely contained
            %         in self
            % Output: 
            % - ix   : the index of the unique object in self.stored_objects_, 
            %          if it is stored, otherwise empty []
            % - hash : the hash of the object from hashify
            %
            hash = self.hashify(obj);
            if isempty(self.stored_hashes_)
                ix = []; % object not stored as nothing is stored
            else
                % get intersection of array stored_hashes_ with (single) array 
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes. Argout(1), the common data, is just the
                % hash so no need to return it. Argout(2), the index in
                % hash, is 1 (single item) so no need to return it.
                % Argout(3), the index in self.stored_hashes_, is the index
                % we need.
                [~,~,ix] = intersect(hash, self.stored_hashes_, 'rows');
            end
        end
    end
    
    methods
        function self = unique_objects_container(varargin)
            %UNIQUE_OBJECTS_CONTAINER create the container
            % Input:
            % - parameter: 'basecase' - charstring name of basecase of
            %                           contained objects
            % - parameter: 'convert_to_stream' - function doing the stream
            %                                    conversion for hashify

            p = inputParser;
            addParameter(p,'baseclass','',@ischar);
            check_function_handle = @(x) isa(x,'function_handle');
            addParameter(p,'convert_to_stream',@getByteStreamFromArray,check_function_handle);
            parse(p,varargin{:});
            
            self.baseclass_ = p.Results.baseclass;
            self.convert_to_stream_ = p.Results.convert_to_stream;
        end
        
            
        function nuix = add(self,obj)
            %ADD adds an object to the container
            % Input:
            % - obj : the object to be added. This may duplicate an object
            %         in the container, but it will be noted as a duplicate
            %         and will be given its own index, which is returns
            % Output:
            % - nuix : the non-unique index for this object
            %
            % it may be a duplicate but it is still the n'th object you
            % added to the container. The number of additions to the
            % container is implicit in the size of idx_.
            
            % check that obj is of the appropriate base class
            if ~isempty(self.baseclass_)
                if ~isa(obj, self.baseclass_)
                    warning('HERBERT:unique_objects_container:invalid_argument', ...
                          'not correct base class');
                    nuix = 0;
                    return;
                end
            end
            
            % Find if the object is already in the container. ix is
            % returned as the index to the object in the container.
            % hash is returned as the hash of the object. If ix is empty
            % then the object is not in the container.
            [ix,hash] = self.is_in_container(obj);
            
            % If the object is not in the container.
            % store the hash in the stored hashes
            % store the object in the stored objects
            % take the index of the last stored object as the object index
            if isempty(ix) % means obj not in container and should be added
                self.stored_hashes_ = cat(1, self.stored_hashes_, hash);
                self.stored_objects_ = cat(1, self.stored_objects_, {obj});
                ix = numel(self.stored_objects_);
            end
            
            % add index ix to the array of indices
            % know the non-unique object index - the number of times you
            % added an object to the container - say k. idx_(k) is the
            % index of the unique object in the container.
            self.idx_ = [self.idx_(:)', ix]; % alternative syntax: cat(2,self.idx_,ix);
            nuix = numel(self.idx_);
        end
        
        function obj = get(self,nuix)
            % given the non-unique index nuix that you know about for your
            % object (it was returned when you added it to the container
            % with add) get the unique object associated
            %
            % Input:
            % - nuix : non-unique index that has been stored somewhere for
            %          this object
            % Output:
            % - obj : the unique object store for this index
            %
            ix = self.idx_(nuix);
            obj = self.stored_objects{ix};
            % alternative implementation would use subsref for '()' case, but this
            % requires additional code to deal with '.' when calling
            % methods.
        end
        
        function out = disp(self)
            out = sprintf('Unique objects container with %i elements and %i unique elements', ...
                           numel(self.idx_), numel(self.stored_objects_));
            if nargout == 0
                disp(out);
            end
        end
    end
end

