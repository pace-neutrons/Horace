classdef IX_map < serializable
    % IX_map   Definition of map class
    
    properties (Access=private)
        % Row vector of spectrum indices in workspaces, concatenated
        % according to increasing workspace number.
        % Spectrum numbers are sorted into numerically increasing
        % order for each workspace.
        s_ = zeros(1,0)
        
        % Row vector of workspace numbers for each spectrum, with same size as s_
        % Workspace numbers are monotonically increasing
        w_ = zeros(1,0)
        
        % Cached properties
        % -----------------
        % Dependent properties that may be expensive to evaluate
        % (Code must keep these consist with the independent properties; use
        % check_combo_arg to do this)

        % Row vector of the number of spectra in each workspace.
        ns_ = zeros(1,0)

        % Row vector of unique workspace numbers
        % Each element is >= 1
        wkno_ = zeros(1,0)
    end
    
    properties (Dependent)
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        s       % Row vector of spectrum numbers
        w       % Row vector of corresponding workspace numbers
        
        % Other dependent properties
        % --------------------------
        nstot   % Total number of spectra
        nwtot   % Total number of workspaces
        ns      % Row vector of number of spectra in each workspace
        wkno    % Row vector of Workspace numbers
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_map (varargin)
            % Constructor for IX_map object.
            %
            % Single spectrum or array of spectra:
            %   >> w = IX_map (isp)         % single spectraum
            %   >> w = IX_map (isp_array)   % general case of array of spectra
            %   >> w = IX_map (isp_array, 'wkno', iw_array)
            %
            % Block of contiguous spectra to contiguous workspaces:
            %   >> w = IX_map (isp_beg, isp_end)
            %   >> w = IX_map (isp_beg, isp_end, step)
            %   >> w = IX_map (..., 'wkno', iw)
            %
            % Either of the two cases above:
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % Note:
            % - Spectrum and workspace numbers must be greater or equal to one.
            % - Spectra can be mapped to more than one workspace, but a warning
            %   message will be printed as this is an unusual occurence
            %
            % Description:
            % ------------
            % The most general form of the constructor are: 
            %
            %   >> w = IX_map (isp_array, 'wkno', iw_array,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            %   >> w = IX_map (isp_beg, isp_end, step, 'wkno', iw_beg,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % The first maps isp_array(1) to iw_array(1), isp_array(2) to iw_array(2) etc.
            % and then repeats this mapping nrepeat times with the two arrays incremented
            % by delta_isp and delta_iw respectively.
            %
            % The second case maps spectra from isp_beg to isp_end in groups of |step|,
            % starting at workspace number iw. The workspace numbers are counting up if
            % step>0 i.e. iw, iw+1, iw+2,... , or counting down if step<0 i.e. iw, iw-1, iw-2,...
            % The mapping is then repeated nrepeat times with isp_beg and iw_beg incremented
            % by delta_isp and delta_iw respectively
            %
            % EXAMPLE
            %   >> w = IX_map (1256, 1001, -10, 'iw', 416, 'repeat', [16, 1000, -26])
            %
            % indicates that a total of 256 spectra, running from 1256 to 1001, are
            % ganged in groups of 10 into the workspaces numbered 416, 415, 414 ...391.
            % Workspace 416 contains spectra 1256-1247, workspace 415 contains spectra
            % 1246-1237 and so on until workspace 391, which contains spectra 1006-1001.
            % There are 26 workspaces in the block of spectra, with the final workspace
            % containing just 6 spectra as 256 is not divisible exactly by 10. The
            % mapping is repeated 16 times, with the initial spectrum numbers
            % incrementing by 1000, i.e. 1256, 2256 ... 16256, and the initial workspace
            % numbers are successively decreasing by 26 i.e. 416, 390, 366 ... 26
            %
            % It is equivalent to
            %   >> w = IX_map ([1256:-10:1001], 'wkno', [416:-1:391], 'repeat', [12, 1000, -26])
            %
            % The block of spectra-to-workspace mapping is repeated nrepeat times, with
            % the starting value for spectra being isp_beg + delta_isp, isp_beg + 2*delta_isp,...
            % and the starting value of workspaces being iw, iw + delta_iw, iw + 2*delta_iw,...
            %
            %
            % In detail:
            % 
            % Single spectrum to single workspace:
            % ====================================
            %   >> w = IX_map (isp)                      % Single workspace with a single spectrum                                           % Default is workspace is numbered 1
            %   >> w = IX_map (isp, 'wkno', iw)          % Workspace given explicit number iw (need not be =1)
            % 
            %
            % Explicit mapping of multiple spectra to multiple workspaces:
            % ============================================================
            %   >> w = IX_map (isp_array)                    % Array of workspaces, one spectrum per workspace
            %   >> w = IX_map (isp_array, 'wkno', iw_array)  % With explicit array of workspace numbers
            %                                                % isp_array and iw_array must have same length
            % EXAMPLES
            %   >> w = IX_map ([1,2,11,12,13])
            %       Map has 5 workspaces, one spectrum each
            %
            %   >> w = IX_map ([1,2,11,12,13], 'wkno', [4,4,14,14,14])
            %       Map has 2 workspaces, w4 with spectra 1 and 3, workspace 14 with spectra 11,12,13
            % 
            %
            % Mapping of a sequence of spectra to a sequence of workspaces:
            % =============================================================
            % - Multiple workspaces, one spectrum per workspace:
            %   ------------------------------------------------
            %    First workspace contains spectrum isp_beg and last workspaces contains spectrum
            %   isp_end (note that isp_beg can be bigger than isp_end) 
            %
            %   >> w = IX_map (isp_beg, isp_end)             % Workspaces numbered 1,2,3...
            %   >> w = IX_map (isp_beg, isp_end, 'wkno', iw) % Workspaces are numbered iw, iw+1...
            %
            %
            % - Multiple workspaces each with a group of spectra:
            %   -------------------------------------------------
            %    Map spectra starting from isp_beg in groups of |step| (step can be +ve or -ve)
            %   The sign of step determines if the workspace number increases or decreases between
            %   groups e.g. if iw=10 and step>0 then they are numbered 10,11,12,... but if step<0
            %   then the workspaces are numbered 10,9,8,...
            %
            %   >> w = IX_map (isp_beg, isp_end, step)
            %   >> w = IX_map (isp_beg, isp_end, step, 'wkno', iw)
            %
            %
            % Repeated blocks of workspaces:
            % ==============================
            % Any of the above blocks of workspaces can be repeated multiple times, with the
            % starting value for spectra being isp_beg, (isp_beg + delta_isp), (isp_beg + 2*delta_isp),...
            % and the starting value of workspaces being iw, (iw + delta_iw), (iw + 2*delta_iw),...
            % Note: Either or both of delta_isp and delta_iw can be negative
            % Note: delta_iw=0 is permitted as you may want to accumulate many spectra to a 
            % single workspace. It is possible to have delta_isp=0 too (which means that a given
            % spectrum will be accumulated into several workspaces), although this is unusual.
            %
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % 
            % Multiple lines
            % ==============
            % The arguments isp_beg, isp_end, step, iw, nrepeat delta_isp and delta_iw
            % can be vectors. The result is equivalent to the concatenation of IX_map applied
            % to the arguments element-by-element e.g.
            %   >> w = IX_map (is_lo, is_hi, step)
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (is_lo(1), is_hi(1), step(1))
            %   >> wtmp(2) = IX_map (is_lo(2), is_hi(2), step(2));
            %           :
            %   >> w = combine (wtmp)
            %
            %
            % One or more of the workspace numbers iw(i) can be set to NaN. This indicates iw(i)
            % are set so that the bounding range of workspace numbers for the ith entry are
            % immediately adjacent to the bounding range for the previous entry,
            % at larger workspace number. Likewise, within an entry, delta_iw(i)
            % can be NaN, indicting that a block is repeated so that the set of
            % blocks forms a contiguous set of workspace numbers.

            [is, iw, ns, wkno, unique_map, unique_spec] = parse_IX_map_args (varargin{:});
            
            obj.s_ = is';   % make row vector
            obj.w_ = iw';   % make row vector

            
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj = set.s (obj, val)
            [ok, mess] = is_integer_id (val);   % this also checks numel(val)>=1
            if ~ok
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Detector ', mess])
            end
            obj.id_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
    end
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save_ascii (obj, file)
            % Save a map object to an ASCII file
            %
            %   >> save_ascii (obj)              % prompts for file
            %   >> save_ascii (obj, file)
            %
            % Input:
            % ------
            %   w       Map object (single object only, not an array)
            %   file    [optional] File for output.
            %           If none given, then prompts for a file
            
            
            % Get file name - prompting if necessary
            % --------------------------------------
            if nargin==1
                file='*.map';
            end
            [file_full, ok, mess] = putfilecheck (file);
            if ~ok
                error ('IX_map:save:io_error', mess)
            end
            
            % Write data to file
            % ------------------
            disp(['Writing map data to ', file_full, '...'])
            put_map (obj, file_full);
            
        end
    end
    
    methods (Static)
        function obj = read_ascii (file)
            % Read map data from an ASCII file
            %
            %   >> obj = IX_map.read_ascii           % prompts for file
            %   >> obj = IX_map.read_ascii (file)
            
            
            % Get file name - prompt if file does not exist
            % ---------------------------------------------
            % The chosen file resets default seach location and extension
            if nargin==0 || ~is_file(file)
                file = '*.map';     % default for file prompt
            end
            [file_full, ok, mess] = getfilecheck (file);
            if ~ok
                error ('IX_map:read:io_error', mess)
            end
            
            % Read data from file
            % ---------------------
            map = get_map(file_full);
            obj = IX_map (map);
            
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
            flds = {'s', 'w'};
        end
    end
    
end
