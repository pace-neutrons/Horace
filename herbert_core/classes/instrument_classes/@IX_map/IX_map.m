classdef IX_map < serializable
    % IX_map   Definition of spectrum to workspace mapping class
    
    properties (Access=private)
        % Row vector of unique workspace numbers
        % Each element is >= 1
        wkno_ = zeros(1,0)
        
        % Row vector of the number of spectra in each workspace.
        % Each element is >= 0
        ns_ = zeros(1,0)
        
        % Row vector of spectrum indices in workspaces, concatenated
        % according to increasing workspace number.
        % Spectrum numbers are sorted into numerically increasing
        % order for each workspace.
        s_ = zeros(1,0)
        
        % Cached dependent properties
        % ---------------------------
        % Dependent properties that may be expensive to evaluate
        % (Code must keep these consistent with the independent properties; use
        % check_combo_arg to do this)
        
        % Row vector of workspace numbers for each spectrum, with same size as s_
        % Workspace numbers are monotonically increasing
        % Note: there can be workspaces with no spectra; those workspace numbers
        % will not appear in this list
        w_ = zeros(1,0)
        
        % Logical flag: true if each spectrum is mapped to only one workspace;
        % false if at least one spectrum is mapped to two or more workspaces
        unique_spec_ = true
    end
    
    properties (Dependent)
        % Mirrors of private properties that define object state
        % ------------------------------------------------------
        wkno    % Row vector of workspace numbers
        ns      % Row vector of number of spectra in each workspace [get only]
        s       % Row vector of spectrum numbers
        
        % Other dependent properties
        % --------------------------
        w           % Row vector of workspace for each spectrum in the order of property s [get only]
        wkno_filled % Row vector of workspaces with at least one spectrum [get only]
        wkno_empty  % Row vector of workspaces with no spectra [get only]
        nwkno       % Number of workspaces [get only]
        nstot       % Total number of spectra in the workspaces [get only]
        unique_spec % true if each spectrum is mapped to only one workspace [get only]
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_map (varargin)
            % Constructor for IX_map object, which maps spectra to workspaces,
            % either one-to-one or in groups of spectra per workspace:
            %
            % Single spectrum to single workspace, one-to-one mapping of spectra
            % to workspaces, or general many-to-one mapping:
            % ----------------------------------------------
            %   >> w = IX_map (s)   % s scalar: single spectrum to workspace 1
            %                       % s array:  one spectrum in each of workspaces 1,2,3...
            %   >> w = IX_map (s, 'wkno', wkno)
            %                       % wkno scalar: all spectra mapped into that workspace
            %                       % wkno array:  one spectrum per workspace
            %   >> w = IX_map (s, 'ns', ns)
            %                       % Spectra grouped in workspaces by the number of spectra
            %                       % per workspace in ns. Workspaces numbered 1,2,3...
            %   >> w = IX_map (s, 'wkno', wkno, 'ns', ns)
            %                       % Workspace numbers and number of spectra in each
            %                       % of the workspaces
            %
            % Groups of contiguous spectra to contiguous workspace numbers:
            % -------------------------------------------------------------
            %   >> w = IX_map (s_beg, s_end)            % one spectrum per workspace
            %   >> w = IX_map (s_beg, s_end, step)      % |step| spectra per workspace
            %   >> w = IX_map (..., 'wkno', wkno_beg)   % Mapped to workspaces starting at
            %                                           % wkno_beg, ascending or descending
            %                                           % according as the sign of step
            %
            % With either of the two cases above, the mapping can be repeated multiple times
            % with successive increments of the spectra and workspace number for each repeat
            % of the block:
            %   >> ... = parse_IX_map_args (..., 'repeat', [nrepeat, delta_s, delta_w])
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
            %   >> w = IX_map (s, 'wkno', wkno,...
            %                   'repeat', [nrepeat, delta_s, delta_wkno])
            %
            %   >> w = IX_map (s_beg, s_end, step, 'wkno', wkno_beg,...
            %                   'repeat', [nrepeat, delta_s, delta_wkno])
            %
            % The first case:
            % ---------------
            %  This maps s(1) to wkno(1), s(2) to wkno(2) etc. and then repeats this mapping
            % nrepeat times with the two arrays incremented by delta_s and delta_wkno
            % respectively. That is, the first repeat maps (s(1) + delta_s) to
            % (wkno(1) + delta_wkno), (s(2) + delta_s) to (wkno(2) + delta_wkno) ...; the
            % next repeat block maps (s(1) + 2*delta_s) to (wkno(1) + 2*delta_wkno),
            % (s(2) + 2*delta_s) to (wkno(2) + 2*delta_wkno) ... and so on.
            %
            % EXAMPLE
            %   >> w = IX_map (1001:1010, 'wkno', 10:-1:1, 'repeat', [5, 1000, 0])
            %
            % maps spectrum 1001 to workspace 10, spectrum 1002 to workspace 9,.. 1010 to
            % workspace 1. It then maps spectrum 2001 also to workspace 10, 2002 to workspace 9
            % etc., until the final repeat block maps spectrum 5001 to workspace 10,
            % spectrum 5002 to workspace 9 ... spectrum 5010 to workspace 1.
            %
            % The second case:
            % ----------------
            %  This maps spectra from s_beg to s_end in groups of |step|, starting at
            % workspace number wkno_beg. The workspace numbers for succesive blocks
            % of spectra increase if step>0 i.e. they  go as wkno_beg, (wkno_beg+1),
            % (wkno_beg+2),... ; the workspace numbers decrease if step<0 i.e. they go as
            % wkno_beg, (wkno_beg-1), (wkno_beg-2),... The mapping is then repeated nrepeat
            % times with s_beg and wkno_beg incremented by delta_s and delta_wkno respectively.
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
            % numbers are successively decreasing by 26 i.e. 416, 390, 366 ... 26.
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
            %   >> w = IX_map (s)                   % Array of workspaces, one spectrum
            %                                       % per workspace
            %   >> w = IX_map (s, 'wkno', wkno)     % With explicit array of workspace
            %                                       % numbers. Note s and wkno
            %                                       % must have same length or wkno
            %                                       % is a scalar (and all spectra are
            %                                       % mapped to that one workspace)
            % EXAMPLES
            %   >> w = IX_map ([1,3,11,12,13])
            %       Map has 5 workspaces, one spectrum 1 to workspace 1, spectrum 3 to
            %       workspace 2, ... spectrum 13 to workspace 5
            %
            %   >> w = IX_map ([1,3,11,12,13], 'wkno', [4,4,14,14,14])
            % or equivalently:
            %   >> w = IX_map ([1,3,11,12,13], 'wkno', [4,14], 'ns', [2,3])
            %       Map has 2 workspaces, spectra 1 and 3 mapped to workspace 4, and
            %       spectra 11,12,13 mapped to workspace 14
            %
            %   >> w = IX_map ([1,3,11,12,13], 'wkno', 101)
            %       All five spectra are mapped to workspace 101
            %
            %
            % Mapping of a sequence of spectra to a sequence of workspaces:
            % =============================================================
            % - One spectrum per workspace:
            %   ---------------------------
            %   First workspace contains spectrum s_beg and last workspaces contains spectrum
            %   s_end (note that s_beg can be bigger than s_end)
            %
            %   >> w = IX_map (s_beg, s_end)                    % Workspaces numbered 1,2,3...
            %   >> w = IX_map (s_beg, s_end, 'wkno', wkno_beg)  % Workspaces are numbered
            %                                                   % wkno_beg, wkno_beg+1...
            %
            %
            % - Group of spectra to each workspace:
            %   -----------------------------------
            %   Map spectra starting from s_beg in groups of |step| (step can be +ve or -ve)
            %   The sign of step determines if the workspace number increases or decreases
            %   between groups e.g. if wkno_beg=10 and step>0 then they are numbered 10,11,12,...
            %   but if step<0 then the workspaces are numbered 10,9,8,...
            %
            %   >> w = IX_map (s_beg, s_end, step)
            %   >> w = IX_map (s_beg, s_end, step, 'wkno', wkno_beg)
            %
            %
            % Repeated blocks of workspaces:
            % ==============================
            % Any of the above blocks of workspaces can be repeated multiple times:
            %
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_s, delta_wkno])
            %
            % starting value for spectra in succesive repeat blocks being s_beg,
            % (s_beg + delta_s), (s_beg + 2*delta_s),... and the starting value of
            % workspaces being wkno_beg, (wkno_beg + delta_wkno), (wkno_beg + 2*delta_wkno),...
            %
            % Note:
            % - Either or both of delta_s and delta_wkno can be negative
            % - delta_wkno=0 is permitted as you may want to accumulate many spectra to a
            %   single workspace.
            % - delta_s=0 is permitted too, which means that a given spectrum will be
            %   accumulated into several workspaces, although this is unusual.
            %
            %
            % Multiple lines
            % ==============
            % In the case of grouping of contiguous spectra into contiguous workspace blocks,
            % the arguments s_beg, s_end, step, wkno_beg, nrepeat delta_s and delta_wkno
            % can be vectors. The result is equivalent to the concatenation of IX_map applied
            % to the arguments element-by-element
            %
            % EXAMPLES
            %
            %   >> w = IX_map (s_beg, s_end, step, 'wkno', wkno_beg)
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (s_beg(1), s_end(1), step(1), 'wkno', wkno_beg(1));
            %   >> wtmp(2) = IX_map (s_beg(2), s_end(2), step(2), 'wkno', wkno_beg(2));
            %           :
            %   >> w = combine (wtmp)
            %
            % and similarly
            %   >> w = IX_map (..., 'repeat', [nrepeat, delta_s, delta_wkno])
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (..., 'repeat', [nrepeat(1), delta_s(1), delta_wkno(1)]);
            %   >> wtmp(2) = IX_map (..., 'repeat', [nrepeat(2), delta_s(2), delta_wkno(2)]));
            %           :
            %   >> w = combine (wtmp)
            %
            %
            % One or more of the workspace numbers wkno_beg(i) can be set to NaN. This indicates
            % that the wkno_beg(i) are set so that the bounding range of workspace numbers for the
            % ith entry is contiguous with the bounding range for the previous entry, at larger
            % workspace number. By default, the values of wkno_beg are equal to NaN.
            % Therefore, if 'wkno' is omitted, successive 'rows' (s_beg(i), s_end(i), step(i))
            % will be concatenated (i.e. blocks of workspaces are placed one after another,
            % rather than combined).
            %
            % EXAMPLE
            % In contrast to the example above:
            %
            %   >> w = IX_map (s_beg, s_end, step)
            %
            % is equivalent to:
            %   >> wtmp(1) = IX_map (s_beg(1), s_end(1), step(1), 'wkno', wkno_beg(1));
            %   >> wtmp(2) = IX_map (s_beg(2), s_end(2), step(2), 'wkno', wkno_beg(2));
            %           :
            %   >> w = concatenate (wtmp)
            %
            % Likewise, within a repeat-block entry, delta_wkno(i) can be NaN,
            % indicting that a block is repeated so that the set of blocks forms a contiguous
            % set of workspace numbers.
            
            
            if nargin==0 || (nargin==1 && isempty(varargin{1}))
                % No arguments or one argument only and it is empty e.g. [] or '' or {}.
                % Default constructor - so do nothing
                
            elseif nargin==1 && isa(varargin{1},'IX_map')
                % Input object is already an IX_map, so just pass through
                obj = varargin{1};
                
            elseif nargin==1 && is_string(varargin{1})
                % Input is a character string. Assume it is a filename
                obj = IX_map.read_ascii(varargin{1});
                
            elseif nargin>0
                % All other input
                [obj.wkno_, obj.ns_, obj.s_] = parse_IX_map_args (varargin{:});
                obj = check_combo_arg (obj);
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties that define object state
        % ------------------------------------------------------
        function obj = set.wkno (obj, val)
            % Change the numerical 'names' of the workspaces, obj.wkno.
            % All workspace numbers must be unique integers greater or equal to unity.
            % The values of wkno are changed in the order of the current wkno.
            %
            % EXAMPLE
            %   >> my_map.wkno
            %   ans =
            %        1     3     5
            %   >> my_map.wkno = [101, 3, 1];
            %
            % relabels the workspace number for the first workspace from 1 to 101,
            % the second left unchanged as 3, and the third is relabelled from 5 to 1.
            % The spectra that were previously held as being in workspace 1 are now in
            % workspace 101, and those in the original workspace 5 are in the
            % new workspace 1.
            
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<1) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    'Workspace numbers must be integers greater or equal to 1')
            end
            
            if numel(val)~=obj.nwkno || numel(val)~=numel(unique(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    ['Workspace numbers must be unique integers, one for each ',...
                    'of the workspaces'])
            end
            
            obj.wkno_ = val(:)';    % empty val ==> zeros(1,0), which is desired
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.ns (obj, val)
            % Change the number of spectra in each workspace
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<0) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    'Number of spectra in each workspace must be an integer greater or equal to 0')
            end
            
            obj.ns_ = val(:)';  % empty val ==> zeros(1,0), which is desired
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.s (obj, val)
            % All spectrum numbers must be integers greater or equal to unity.
            % Any spectrum number can appear multiple times
            if ~isnumeric(val) || any(round(val(:))~=val(:)) || any(val(:)<1) ||...
                    any(~isfinite(val(:)))
                error ('HERBERT:IX_map:invalid_argument',...
                    'Spectrum numbers must be integers greater or equal to 1')
            end
            
            obj.s_ = val(:)';   % empty val ==> zeros(1,0), which is desired
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        % Other settable dependendant properties
        % --------------------------------------
        
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        %------------------------------------------------------------------
        
        function val = get.wkno(obj)
            % Unique workspace numbers
            val = obj.wkno_;
        end
        
        function val = get.ns(obj)
            % Number of spectra in each workspace
            val = obj.ns_;
        end
        
        % Mirrors of private properties that define object state
        function val = get.s(obj)
            % Spectrum numbers
            val = obj.s_;
        end
        
        function val = get.w(obj)
            % Workspace numbers for each spectrum number
            val = obj.w_;
        end
        
        function val = get.wkno_filled(obj)
            % Workspace numbers with at least one spectrum
            val = obj.wkno_(obj.ns_>0);
        end
        
        function val = get.wkno_empty(obj)
            % Workspace numbers with no spectra
            val = obj.wkno_(obj.ns_==0);
        end
        
        function val = get.nwkno(obj)
            % Number of unique workspaces
            val = numel(obj.wkno_);
        end
        
        function val = get.nstot(obj)
            % Total number of spectra
            val = numel(obj.s_);
        end
        
        function val = get.unique_spec(obj)
            % True if each spectrum is mapped to only one workspace
            val = obj.unique_spec_;
        end
        
    end
    
    
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save_ascii (obj, file)
            % Save a map object to an ASCII file (conventional extension: .map)
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
            
            put_map_ascii (obj, file);   % private function to IX_map
        end
    end
    
    methods (Static)
        function obj = read_ascii (file)
            % Read map data from an ASCII file (conventional extension: .map)
            %
            %   >> obj = IX_map.read_ascii (file)
            %
            % EXAMPLE
            %   >> my_map = IX_map.read_ascii ('c:\temp\maps_4to1.map')
            %
            %
            % Format of an ascii map file:
            % ----------------------------
            %       <nwkno (the number of workspaces)>
            %       <wkno(1) (the workspace number>
            %       <ns(1) (number of spectra in 1st workspace>
            %       <list of spectrum numbers across as many lines as required>
            %           :
            %       <wkno(2) (the workspace number>
            %       <ns(2) (number of spectra in 1st workspace>
            %       <list of spectrum numbers across as many lines as required>
            %           :
            %       <wkno(iw) (the workspace number>
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
            % the workspaces have numbers 1,2,3...nwkno, and there was also
            % information about the effective detector positions that is now
            % redundant. This format can no longer be written as it is obsolete:
            %
            %   <nwkno (the number of workspaces)>
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
        function [wkno_out, ns_out, s_out] = test_repeat_s_w_arrays (~, varargin)
            [wkno_out, ns_out, s_out] = repeat_s_w_arrays (varargin{:});
        end
        
        function [wkno_out, ns_out, s_out] = test_repeat_s_w_blocks (~, varargin)
            [wkno_out, ns_out, s_out] = repeat_s_w_blocks (varargin{:});
        end
        
        function [ix_beg, delta_ix, ix_min, ix_max] = test_resolve_repeat_blocks (~, varargin)
            [ix_beg, delta_ix, ix_min, ix_max] = resolve_repeat_blocks (varargin{:});
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
            flds = {'wkno', 'ns', 's'};
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
            if numel(obj.wkno_) ~= numel(obj.ns_)
                error('HERBERT:IX_map:invalid_argument', ...
                    ['The number of workspace numbers in ''wkno'' and the length of ',...
                    'the list of number spectra in each workspace, ''ns'', do not match'])
            end
            
            % Check number of spectra and workspace indices match
            if numel(obj.s_) ~= sum(obj.ns_)
                error('HERBERT:IX_map:invalid_argument', ...
                    'The number of spectra does not match the sum of the number of spectra in each workspace')
            end
            
            % Sort spectra and workspaces to match definition of ordering, and
            % compute cached dependent properties
            [obj.wkno_, obj.ns_, obj.s_, obj.w_, obj.unique_spec_] = ...
                sort_s_w (obj.wkno_, obj.ns_, obj.s_);
        end
        
    end
    
end
