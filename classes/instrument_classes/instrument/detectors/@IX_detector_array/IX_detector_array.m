classdef IX_detector_array
    % Set of detector banks. Allows for banks with different detector types e.g.
    % one can be of type IX_det_He3tube and another can be IX_det_slab
    % This is not the same as an array of IX_detector_bank objects, for the
    % following reasons:
    %   (1) Detector array ensures that the detector indicies are unique
    %   (2) The methods for a detector bank do not work on arrays.
    
    properties (Access=private)
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
            %                       detector bank.
            %                       See <a href="matlab:help('IX_detector_bank');">IX_detector_bank</a>
            
            
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
    
end
