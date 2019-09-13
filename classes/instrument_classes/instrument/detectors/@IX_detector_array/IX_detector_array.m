classdef IX_detector_array
    % Set of detector banks. Allows for banks with different detector types e.g.
    % one detector bank can contain detectors exclusively of type IX_det_He3tube
    % and another can contain detectors exclusively of type IX_det_slab.
    %
    % An IX_detector_array object is different to an array of IX_detector_bank
    % objects, for the following reasons:
    %   (1) IX_detector_array ensures that the detector indicies are unique
    %       across all of the detector banks
    %   (2) Methods such as calculation of detector efficieny will operate
    %       on the entire array, calling the correct functions for each of
    %       the different detector types in the differnt banks.
    
    properties (Access=private)
        % Class version number
        class_version_ = 1;
        % Array of IX_detector_bank objects (column vector)
        det_bank_ = IX_detector_bank
    end
    
    properties (Dependent)
        % Detector identifiers, unique integers greater or equal to one
        id
        % Sample-detector distances (m) (column vector)
        x2
        % Scattering angles (degrees, in range 0 to 180) (column vector)
        phi
        % Azimuthal angles (degrees) (column vector)
        % The sense of rotation is that sitting on the beamstop and looking at the
        % sample, azim = 0 is east, azim = 90 is north
        azim
        % Detector orientation matrices [3,3,ndet]
        % The matrix gives components in the secondary spectrometer coordinate
        % frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Cell array of detector banks (column vector)
        % Each bank is an object of type IX_detector_bank
        det_bank
        % Number of detectors
        ndet
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_detector_array (varargin)
            % Create a set of detector banks
            %
            % From existing IX_detector_bank objects:
            %   >> obj = IX_detector_array (bank1, bank2, ...)
            %
            % Create an instance with just a single detector bank:
            %   >> obj = IX_detector_array (id, x2, ...)
            %
            % Input:
            % ------
            %   bank1, bank2,...    Arrays of IX_detector_bank objects
            %
            % *OR*
            %
            %   id, x2, ...         Arguments as needed to create a single
            %                       detector bank object. For more details
            %                       see <a href="matlab:help('IX_detector_bank');">IX_detector_bank</a>
            
            
            if nargin>0
                ok = cellfun(@(x)(isa(x,'IX_detector_bank')), varargin);
                if all(ok)
                    % All inputs have class IX_detector_bank; Concatenate into a single array
                    tmp = cellfun(@(x)(x(:)),varargin,'uniformOutput',false);
                    obj.det_bank_ = cat(1,tmp{:});
                    clear tmp
                    % Check that the detector identifiers are all unique
                    id = arrayfun(@(x)(x.id),obj.det_bank_,'uniformOutput',false);
                    id_all = cat(1,id{:});
                    if ~is_integer_id(id_all)
                        error('Detector indentifiers must all be unique')
                    end
                else
                    obj.det_bank_ = IX_detector_bank(varargin{:});
                end
            end
            
            
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.id(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.id), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.id;
            end
        end
        
        function val = get.x2(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.x2), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.x2;
            end
        end
        
        function val = get.phi(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.phi), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.phi;
            end
        end
        
        function val = get.azim(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.azim), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.azim;
            end
        end
        
        function val = get.dmat(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.dmat), obj.det_bank_,'uniformOutput',false);
                val = cat(3,tmp{:});
            else
                val = obj.det_bank_.dmat;
            end
        end
        
        function val = get.det_bank(obj)
            val = obj.det_bank_;
        end
        
        function val = get.ndet(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(numel(x.id)), obj.det_bank_);
                val = sum(tmp);
            else
                val = obj.det_bank_.ndet;
            end
        end
        
        %------------------------------------------------------------------
    end
    
    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
