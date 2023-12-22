classdef IX_map < serializable
    % IX_map   Definition of spectrum to workspace mapping class
    
    properties (Access=private)
        % Row vector of spectrum indices in workspaces, concatenated
        % according to increasing workspace number.
        % Spectrum numbers are sorted into numerically increasing
        % order for each workspace.
        s_ = zeros(1,0)
        
        % Row vector of workspace numbers for each spectrum, with same size as s_
        % Workspace numbers are monotonically increasing
        w_ = zeros(1,0)
        
        % Cached dependent properties
        % ---------------------------
        % Dependent properties that may be expensive to evaluate
        % (Code must keep these consistent with the independent properties; use
        % check_combo_arg to do this)
        
        % Row vector of the number of spectra in each workspace.
        ns_ = zeros(1,0)
        
        % Row vector of unique workspace numbers
        % Each element is >= 1
        wkno_ = zeros(1,0)
        
        % Logical flag: true if each spectrum is mapped to only one workspace;
        % false if at least one spectrum is mapped to two or more workspaces
        unique_spec_ = true
    end
    
    properties (Dependent)
        % Mirrors of private properties that define object state
        % ------------------------------------------------------
        s       % Row vector of spectrum numbers
        w       % Row vector of corresponding workspace numbers
        
        % Other dependent properties
        % --------------------------
        wkno    % Row vector of Workspace numbers
        nw      % Number of workspaces
        ns      % Row vector of number of spectra in each workspace
        nstot   % Total number of spectra in the workspaces
        unique_spec % true if each spectrum is mapped to only one workspace
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_map (varargin)
            % Constructor for IX_map object, which maps spectra to workspaces,
            % either one-to-one or in groups of spectra per workspace:
            %
            % Single spectrum to single workspace, or one-to-one mapping of spectra
            % to workspaces:
            %   >> w = IX_map (isp)         % single spectrum to workspace 1
            %   >> w = IX_map (isp_array)   % general case of array of spectra
            %   >> w = IX_map (isp_array, 'wkno', iw_array)
            %                               % if iw_array is scalar, all spectra
            %                               % are mapped into that workspace
            %
            % Groups of contiguous spectra to contiguous workspace numbers:
            %   >> w = IX_map (isp_beg, isp_end)        % one spectrum per workspace
            %   >> w = IX_map (isp_beg, isp_end, step)  % |step| spectra per workspace
            %   >> w = IX_map (..., 'wkno', iw_beg)     % Mapped into succesive workspaces starting
            %                                           % at iw_beg, ascending or descending
            %                                           % according as the sign of step
            %
            % With either of the two cases above, the mapping can be repeated
            % multiple times with successive increments of the spectra and
            % workspace number for each repeat block:
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % Note:
            % - Spectrum and workspace numbers must be greater or equal to one.
            % - Spectra can be mapped to more than one workspace, This is an
            %   unusual occurence in practice; you can query the property
            %   unique_spec which is false in this case.
            %
            %
            % Full description:
            % =================
            % The most general forms of the constructor are:
            %
            %   >> w = IX_map (isp_array, 'wkno', iw_array,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            %   >> w = IX_map (isp_beg, isp_end, step, 'wkno', iw_beg,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % The first case:
            % ---------------
            %  This maps isp_array(1) to iw_array(1), isp_array(2) to iw_array(2) etc.
            % and then repeats this mapping nrepeat times with the two arrays incremented
            % by delta_isp and delta_iw respectively. That is, the first repeat
            % maps isp_array(1) + delta_isp to iw_array(1) + delta_iw, isp_array(2) + delta_isp
            % to iw_array(2) + delta_iw ...; the next repeat block maps isp_array(1) + delta_isp
            % to iw_array(1) + delta_iw, isp_array(2) + delta_isp to iw_array(2) + delta_iw ...
            % and so on.
            %
            % EXAMPLE
            %   >> w = IX_map (1001:1010, 'wkno', 10:-1:1, 'repeat', [5, 1000, 0])
            %
            % maps spectrum 1001 to workspace 10, spectrum 1002 to workspace 9,.. 1010 to
            % workspace 1. It then maps spectrum 2001 also to workspace 10, 2002 to workspace 9
            % etc.
            %
            % The second case:
            % ----------------
            %  This maps spectra from isp_beg to isp_end in groups of |step|,
            % starting at workspace number iw_beg. The workspace numbers for succesive blocks
            % of spectra increase if step>0 i.e. they  go as iw_beg, iw_beg+1, iw_beg+2,... ;
            % the workspace numbers decrease if step<0 i.e. they go as iw_beg, iw_beg-1,
            % iw_beg-2,... The mapping is then repeated nrepeat times with isp_beg and iw_beg
            % incremented by delta_isp and delta_iw respectively.
            %
            % EXAMPLE
            %   >> w = IX_map (1256, 1001, -10, 'wkno', 416, 'repeat', [16, 1000, -26])
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
            %
            % Other examples:
            %
            % Single spectrum to single workspace:
            % ====================================
            %   >> w = IX_map (isp)                 % Single spectrum mapped to workspace 1
            %   >> w = IX_map (isp, 'wkno', iw)     % Workspace given explicit number iw
            %
            % EXAMPLES
            %   >> w = IX_map (5)
            %       Spectrum 5 mapped to workspace 1
            %
            %   >> w = IX_map (5, 'wkno', 10)
            %       Spectrum 5 mapped to workspace 10
            %
            %
            % Explicit mapping of multiple spectra to multiple workspaces:
            % ============================================================
            %   >> w = IX_map (isp_array)                   % Array of workspaces, one spectrum
            %                                               % per workspace
            %   >> w = IX_map (isp_array, 'wkno', iw_array) % With explicit array of workspace
            %                                               % numbers. Note isp_array and iw_array
            %                                               % must have same length or iw_array
            %                                               % is a scalar (and all spectra are
            %                                               % mapped to that one workspace)
            % EXAMPLES
            %   >> w = IX_map ([1,3,11,12,13])
            %       Map has 5 workspaces, one spectrum 1 to workspace 1, spectrum 3 to workspace 2, ...
            %       spectrum 13 to workspace 5.
            %
            %   >> w = IX_map ([1,3,11,12,13], 'wkno', [4,4,14,14,14])
            %       Map has 2 workspaces, spectra 1 and 3 mapped to workspace 4, and spectra 11,12,13
            %       mapped to workspace 14
            %
            %   >> w = IX_map ([1,3,11,12,13], 'wkno', 101)
            %       All five spectra are mapped to workspace 101
            %
            %
            % Mapping of a sequence of spectra to a sequence of workspaces:
            % =============================================================
            % - One spectrum per workspace:
            %   ---------------------------
            %   First workspace contains spectrum isp_beg and last workspaces contains spectrum
            %   isp_end (note that isp_beg can be bigger than isp_end)
            %
            %   >> w = IX_map (isp_beg, isp_end)                    % Workspaces numbered 1,2,3...
            %   >> w = IX_map (isp_beg, isp_end, 'wkno', iw_beg)    % Workspaces are numbered
            %                                                       % iw_beg, iw_beg+1...
            %
            %
            % - Group of spectra to each workspace:
            %   -----------------------------------
            %   Map spectra starting from isp_beg in groups of |step| (step can be +ve or -ve)
            %   The sign of step determines if the workspace number increases or decreases
            %   between groups e.g. if iw_beg=10 and step>0 then they are numbered 10,11,12,...
            %   but if step<0 then the workspaces are numbered 10,9,8,...
            %
            %   >> w = IX_map (isp_beg, isp_end, step)
            %   >> w = IX_map (isp_beg, isp_end, step, 'wkno', iw_beg)
            %
            %
            % Repeated blocks of workspaces:
            % ==============================
            % Any of the above blocks of workspaces can be repeated multiple times:
            %
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % starting value for spectra being isp_beg, (isp_beg + delta_isp),
            % (isp_beg + 2*delta_isp),... and the starting value of workspaces being iw,
            % (iw + delta_iw), (iw + 2*delta_iw),...
            %
            % Note:
            % - Either or both of delta_isp and delta_iw can be negative
            % - delta_iw=0 is permitted as you may want to accumulate many spectra to a
            %   single workspace.
            % - delta_isp=0 is permitted too, which means that a given spectrum will be
            %   accumulated into several workspaces, although this is unusual.
            %
            %
            % Multiple lines
            % ==============
            % In the case of grouping of contiguous spectra into contiguous workspace blocks,
            % the arguments isp_beg, isp_end, step, iw_beg, nrepeat delta_isp and delta_iw
            % can be vectors. The result is equivalent to the concatenation of IX_map applied
            % to the arguments element-by-element e.g.
            %
            %   >> w = IX_map (is_lo, is_hi, step, 'wkno', iw_beg)
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (is_lo(1), is_hi(1), step(1), 'wkno', iw_beg(1));
            %   >> wtmp(2) = IX_map (is_lo(2), is_hi(2), step(2), 'wkno', iw_beg(2));
            %           :
            %   >> w = combine (wtmp)
            %
            % and similarly
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (..., 'repeat', [nrepeat(1), delta_isp(1), delta_iw(1)]);
            %   >> wtmp(2) = IX_map (..., 'repeat', [nrepeat(2), delta_isp(2), delta_iw(2)]));
            %           :
            %   >> w = combine (wtmp)
            %
            % One or more of the workspace numbers iw_beg(i) can be set to NaN. This indicates
            % that the iw(i) are set so that the bounding range of workspace numbers for the
            % ith entry is contiguous with the bounding range for the previous entry at larger
            % workspace number. Likewise, within a repeat-block entry, delta_iw(i) can be NaN,
            % indicting that a block is repeated so that the set of blocks forms a contiguous
            % set of workspace numbers.
            
            if nargin==0
                % Case of default object - no spectra or workspaces
                return
            end
            [obj.s_, obj.w_] = parse_IX_map_args (varargin{:});
            obj = check_combo_arg (obj);
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties that define object state
        % ------------------------------------------------------
        function obj = set.s (obj, val)
            % All spectrum numbers must be integers greater or equal to unity.
            % A spectrum number can appear multiple times
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<1) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    'Spectrum numbers must be integers greater or equal to 1')
            end
            
            if ~isempty(val)
                obj.s_ = val(:)';
            else
                obj.s_ = zeros(1,0);
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.w (obj, val)
            % All workspace numbers must be integers greater or equal to unity.
            % A workspace number can appear multiple times
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<1) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    'Workspace numbers must be integers greater or equal to 1')
            end
            
            if ~isempty(val)
                obj.w_ = val(:)';
            else
                obj.w_ = zeros(1,0);
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties that define object state
        function val = get.s(obj)
            % Spectrum numbers
            val = obj.s_;
        end
        
        function val = get.w(obj)
            % Workspace numbers for each spectrum number
            val = obj.w_;
        end
        
        function val = get.wkno(obj)
            % Unique workspace numbers
            val = obj.wkno_;
        end
        
        function val = get.nw(obj)
            % Number of unique workspaces
            val = numel(obj.wkno_);
        end
        
        function val = get.ns(obj)
            % Number of spectra in each workspace
            val = obj.ns_;
        end
        
        function val = get.unique_spec(obj)
            % True if each spectrum is mapped to only one workspace
            val = obj.unique_epec_;
        end
        
    end
    
    
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save_ascii (obj, file)
            % Save map data to an ASCII file (conventional extension: .map)
            %
            %   >> save_ascii (obj, file)
            %
            % See <a href="matlab:help('IX_map/read_ascii');">IX_map/read_ascii</a> for file format details and examples
            %
            % Input:
            % ------
            %   obj     Map object (single object only, not an array)
            %   file    Name of file for output
            %
            % EXAMPLE
            %   >> save_ascii (my_map_object, 'c:\temp\maps_4to1.map')
            %
            
            put_map_ascii (obj, file);   % private function to IX_map
        end
    end
    
    methods (Static)
        function obj = read_ascii (file)
            % Read map data from an ASCII file (conventional extension: .map)
            %
            %   >> obj = IX_map.read_ascii           % prompts for file name
            %   >> obj = IX_map.read_ascii (file)
            %
            % EXAMPLE
            %   >> my_map = IX_map.read_ascii('c:\temp\maps_4to1.map')
            %
            %
            % Format of an ascii map file:
            % ----------------------------
            %       <nw (the number of workspaces)>
            %       <wkno(1) (the workspace number>
            %       <ns(1) (number of spectra in 1st workspace>
            %       <list of spectrum numbers across as many lines as required>
            %           :
            %       <wkno(2) (the workspace number>
            %       <ns(2) (number of spectra in 1st workspace>
            %       <list of spectrum numbers across as many lines as required>
            %           :
            %       <wkno(nw) (the workspace number>
            %       <no. spectra in last workspace>
            %       <list of spectrum numbers across as many lines as required>
            %           :
            %
            % The list of spectrum numbers can take the form e.g. '12:15, 5:-2:1'
            % to specify ranges (in this case [12,13,14,15,5,3,1])
            %
            % Blank lines and comment lines (lines beginning with ! or %) are ignored.
            % Comments can also be put at the end of lines following ! or %.
            %
            % For examples, see:
            %
            %
            % NOTE: The old VMS format is also supported. This assumes
            % the workspaces have numbers 1,2,3...nw, and there was also
            % information about the effective detector positions that is now
            % redundant. This format can no longer be written as it is obsolete:
            %
            %   <nw (the number of workspaces)>
            %   <no. spectra in 1st workspace>   <dummy value>   <dummy value>    <dummy value>
            %   <list of spectrum numbers across as many lines as required>
            %       :
            %   <no. spectra in 2nd workspace>   <dummy value>   <dummy value>    <dummy value>
            %   <list of spectrum numbers across as many lines as required>
            %       :

            obj = get_map_ascii(file);  % private function to IX_map
        end
        
    end
    
    
    %======================================================================
    % Interface to test private functions
    %======================================================================
    % Private functions and methods are not accesible to testing without a
    % public interface. Instead, these protected methods access private methods
    % and functions which in turn can be called by a dummy class that
    % inherits IX_map. The dummy class can be placed in a test folder so
    % is not accesible unless the test folder is placed on the Matlab path.
    % Thereby users of IX_map will not have access to these protected
    % methods
    
    methods (Access=protected)
        function [is_out, iw_out] = test_repeat_s_w_arrays (~, varargin)
            [is_out, iw_out] = repeat_s_w_arrays (varargin{:});
        end
        
        function [is_out, iw_out] = test_repeat_s_w_blocks (~, varargin)
            [is_out, iw_out] = repeat_s_w_blocks (varargin{:});
        end
        
        function [iw_beg, delta_iw, iw_min, iw_max] = test_resolve_repeat_blocks (~, varargin)
            [iw_beg, delta_iw, iw_min, iw_max] = resolve_repeat_blocks (varargin{:});
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
        
        function obj = check_combo_arg (obj)
            % Verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check.
            %
            % Recompute any cached arguments.
            %
            % Throw an error if the properties are inconsistent and return
            % without problem it they are not.
            
            % Check number of spectra and workspace indices match
            if numel(obj.s_) ~= numel(obj.w_)
                error('HERBERT:IX_map:invalid_argument', ...
                    'The numbers of spectrum and workspace indices must match')
            end
            
            % Sort spectra and workspaces to match definition of ordering, and
            % compute cached dependent properties
            [obj.s_, obj.w_, obj.ns_, obj.wkno_, ~, obj.unique_spec_] = ...
                sort_s_w (obj.s_, obj.w_);
        end
        
    end
    
end
