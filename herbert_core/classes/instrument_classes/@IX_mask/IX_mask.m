classdef IX_mask
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
            
            if nargin>0 && ~isempty(val)
                if is_string (val)
                    % Assume a filename
                    if ~isempty(val)
                        msk = get_mask(val);
                    else
                        error ('IX_mask:invalid_argument',...
                            'File name cannot be an empty string')
                    end
                    
                elseif isnumeric(val)
                    % Numeric input
                    msk = val;
                    
                else
                    % Unrecognised input
                    error ('IX_mask:invalid_argument',...
                        'Input must be an array or file name')
                end
                obj.msk = msk;
            else
                obj.msk = zeros(1,0);
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
            if isnumeric(val) && ~(any(val<1) || any(~isfinite(val)))
                if ~isempty(val)
                    obj.msk = unique(val(:)');
                else
                    obj.msk = zeros(1,0);
                end
            else
                error ('IX_mask:set:invalid_argument',...
                    'Spectrum numbers must be finite and greater or equal to 1')
            end
        end
    end
    
    
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save (obj, file)
            % Save a mask object to an ASCII file
            %
            %   >> save (obj)              % prompts for file
            %   >> save (obj, file)
            %
            % Input:
            % ------
            %   w       Mask object (single object only, not an array)
            %   file    [optional] File for output.
            %           If none given, then prompts for a file
            
            
            % Get file name - prompting if necessary
            % --------------------------------------
            if nargin==1
                file='*.msk';
            end
            [file_full, ok, mess] = putfilecheck (file);
            if ~ok
                error ('IX_mask:save:io_error', mess)
            end
            
            % Write data to file
            % ------------------
            disp(['Writing mask data to ', file_full, '...'])
            put_mask (obj.msk, file_full);
            
        end
    end
    
    methods (Static)
        function obj = read (file)
            % Read mask data from an ASCII file
            %
            %   >> obj = IX_mask.read           % prompts for file
            %   >> obj = IX_mask.read (file)
            
            
            % Get file name - prompt if file does not exist
            % ---------------------------------------------
            % The chosen file resets default seach location and extension
            if nargin==0 || ~is_file(file)
                file = '*.msk';     % default for file prompt
            end
            [file_full, ok, mess] = getfilecheck (file);
            if ~ok
                error ('IX_mask:read:io_error', mess)
            end
            
            % Read data from file
            % ---------------------
            msk = get_mask(file_full);
            obj = IX_mask (msk);
            
        end
        
    end
    
end
