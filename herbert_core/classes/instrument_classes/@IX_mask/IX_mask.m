classdef IX_mask < serializable
    % IX_mask   Definition of mask class
    
    properties
        % Spectra to be masked. Row vector of integers greater than zero
        msk
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mask (val)
            % Create IX_mask object.
            %
            %   >> obj = IX_mask (iarray)       % Array of spectra
            %   >> obj = IX_mask (filename)     % Read arrays from ascii file
            %
            % A mask object contains a list of spectra to be masked, where
            % all spectrum numbers are greater than or equal to one. The
            % array is sorted into numerically increasing order, with all
            % duplicates removed.
            %
            % Input:
            % ------
            %   iarray      Array of spectra to be masked
            %
            % *OR*
            %   filename    Name of ASCII file with list of spectra to mask
            %               The file can have comment lines indicated by
            %              %, !, or blank lines
            %               Spectrum numbers are indicated by the contents
            %              of any valid matlab array constructor (i.e. with
            %              the leading '[' and closing ']' missing
            %
            %               EXAMPLE:
            %                   % A comment line
            %                   1:10, 15:20
            %
            %                   % Another comment line
            %                   11:3:35      % an in-line comment
            
            if nargin==0 || isempty(val)
                % No argument or empty argument
                obj.msk = zeros(1,0);
                
            else
                if is_string (val)
                    % Assume a filename
                    if ~isempty(val)
                        msk = IX_mask.read_ascii(val);
                    else
                        error ('HERBERT:IX_mask:invalid_argument',...
                            'File name cannot be an empty string')
                    end
                    
                elseif isnumeric(val)
                    % Numeric input
                    msk = val;
                    
                else
                    % Unrecognised input
                    error ('HERBERT:IX_mask:invalid_argument',...
                        'Input must be an array or file name')
                end
                obj.msk = msk;
            end
            
        end
    end
    
    
    %------------------------------------------------------------------
    % Set method
    %------------------------------------------------------------------
    methods
        function obj = set.msk (obj, val)
            % Performs the checks on value, and sets with unique values
            % or empty value - defines the contents from all routes
            
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<1) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_mask:invalid_argument',...
                    'Spectrum numbers must be integers greater or equal to 1')
            end
            
            if ~isempty(val)
                obj.msk = unique(val(:)');
            else
                obj.msk = zeros(1,0);
            end
        end
    end
    
    
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save_ascii (obj, file)
            % Save a mask object to an ASCII file (conventional extension: .msk)
            %
            %   >> save_ascii (obj, file)
            %
            % See <a href="matlab:help('IX_mask/read_ascii');">IX_mask/read_ascii</a> for file format details and examples
            %
            % Input:
            % ------
            %   obj     Mask object (single object only, not an array)
            %   file    Name of file for output
            %
            % EXAMPLE
            %   >> save_ascii ('c:\temp\bad_spectra.msk')
            
            put_mask_ascii (obj, file);   % private function to IX_mask          
        end
    end
    
    methods (Static)
        function obj = read_ascii (file)
            % Read mask data from an ASCII file (conventional extension: .msk)
            %
            %   >> obj = IX_mask.read_ascii (file)
            %
            % EXAMPLE
            %   >> my_map = IX_mask.read_ascii ('c:\temp\bad_spectra.msk')
            %
            %
            % Format of an ascii mask file:
            % -----------------------------
            % The file consists of lists of indices in various forms, for
            % example '7 12:15, 5:-2:1' will specify [7,12,13,14,15,5,3,1])
            %
            % Blank lines and comment lines (lines beginning with ! or %) are ignored.
            % Comments can also be put at the end of lines following ! or %.
            % As an example of the full contents of a valid .msk file:
            %
            %           ! A little mask
            %           60:-1:50,2-5,30-40
            %           19-23
            %
            %           ! Another comment
            %           38-42
            %           10,11,12        ! in-line comment
            %
            %           % Matlab style comment
            %           12, 32, 56-62   % another in-line comment
            
            obj = get_mask_ascii(file);  % private function to IX_mask
        end
        
    end
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================

    methods
        function ver = classVersion(~)
            % Current version of class definition
            ver = 1;
        end
        
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            flds = {'msk'};
        end
    end
    
end
