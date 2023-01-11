classdef IX_map
    % IX_map   Definition of map class
    
    properties (Access=private)
        % Row vector size [1,n], n>=0, of number of spectra in each workspace.
        % The case of no workspaces is permitted (i.e. numel(ns)==0).
        % Workspaces can contain zero spectra (i.e. ns(i)==0 for some i)
        ns_ = zeros(1,0)

        % Row vector of spectrum indices in workspaces, concatenated
        % according to increasing workspace number.
        % Spectrum numbers are sorted into numerically increasing
        % order for each workspace.
        % The order of workspaces is numerically increasing workspace number
        % and in the case of un-numbered workspaces, the order they appear 
        % in the constructor
        s_ = zeros(1,0)

        % Row vector of workspace numbers (think of them as the 'names' of
        % the workspaces).
        % Must be unique, and greater than or equal to one.
        % If [], this means leave undefined.
        wkno_ = []
    end
    
    properties (Dependent)
        nw      % Number of workspaces
        wkno    % Workspace numbers
        ns      % Row vector of number of spectra in each workspace
        s       % Row vector spectrum indices
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_map (varargin)
            % Constructor for IX_map object. There are numerous ways to specify the map
            %
            % Spectrum numbers:
            % -----------------
            % The most general form is: 
            %
            %   >> w = IX_map (isp_array, 'wkno', iw_array,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            %   >> w = IX_map (isp_beg, isp_end, nstep, 'wkno', iw,...
            %                   'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % This maps spectra from isp_beg to isp_end in groups of |nstep|, starting at
            % workspace number iw. The workspace numbers are counting up if nstep>0
            % i.e. iw, iw+1, iw+2,... ,or counting down if nstep<0 i.e. iw, iw-1, iw-2,...
            %
            % EXAMPLE
            %   >> w = IX_map (1256, 1001, -10, 'iw', 416, 'repeat', [12, 1000, -26])
            %
            % indicates that a total of 256 spectra, running from 1256 to 1001, are
            % ganged in groups of 10 into the workspaces numbered 350, 349, 348 ...325.
            % Workspace 350 contains spectra 1256-1247, workspace 349 contains spectra
            % 1246-1237 and so on until workspace 325, which contains spectra 1006-1001.
            % There are 26 workspaces in the block of spectra, with the final workspace
            % containing just 6 spectra as 256 is not divisible exactly by 10. The
            % mapping is repeated 12 times, with the initial spectrum numbers
            % incrementing by 1000, i.e. 1256, 2256 ... 6256, and the initial workspace
            % numbers are successively decreasing by 26 i.e. 416, 390, 366 ...
            %
            % It is equivalent to
            %   >> w = IX_map ([1256:-10:1001], 'iw', [416:-1:381], 'repeat', [12, 1000, -26])
            %
            % The block of spectra-to-workspace mapping is repeated nrepeat times, with
            % the starting value for spectra being isp_beg + delta_isp, isp_beg + 2*delta_isp,...
            % and the starting value of workspaces being iw, iw + delta_iw, iw + 2*delta_iw,...
            %
            % Single workspace with single spectrum:
            % --------------------------------------
            %   >> w = IX_map(isp)                      % Single workspace with a single spectrum
            %                                           % Default is workspace is numbered 1
            %   >> w = IX_map(isp, 'wkno', iw)          % Workspace given number iw (need not be =1)
            % 
            % Multiple workspaces, one spectrum per workspace:
            % ------------------------------------------------
            %  First workspace contains spectrum isp_beg and last workspaces contains spectrum
            % isp_end (note that isp_beg can be bigger than isp_end) 
            %   >> w = IX_map(isp_beg, isp_end)             % Workspaces numbered 1,2,3...
            %   >> w = IX_map(isp_beg, isp_end, 'wkno', iw) % Workspaces are numbered iw, iw+1...
            %
            % Multiple workspaces each with a group of spectra:
            % -------------------------------------------------
            % Map spectra starting from isp_beg in groups of |nstep| (nstep can be +ve or -ve)
            % The sign of nstep determines if the workspace number increases or decreases between
            % groups e.g. if iw=10 and nstep>0 then they are numbered 10,11,12,... but if nstep<0
            % then the workspaces are numbered 10,9,8,...
            %   >> w = IX_map(isp_beg, isp_end, nstep)
            %   >> w = IX_map(isp_beg, isp_end, nstep, 'wkno', iw)
            %
            % Repeated blocks of workspaces:
            % ------------------------------
            % Any of the above blocks of workspaces can be repeated multiple times, with the
            % starting value for spectra being isp_beg + delta_isp, isp_beg + 2*delta_isp,...
            % and the starting value of workspaces being iw, iw + delta_iw, iw + 2*delta_iw,...
            % Note: One or both of delta_isp and delta_iw can be negative
            % Note: delta_iw=0 is permitted as you may want to accumulate many spectra to a 
            % single workspace. It is possible to have delta_isp=0 too, although this is unusual
            % and a warning message will be printed.
            %
            %   >> w = IX_map(..., 'repeat', [nrepeat, delta_isp, delta_iw])
            %
            % 
            %
            %
            % The arguments isp, isp_beg, isp_end, nstep etc. can be vectors. The result is
            % equivalent to the concatenation of IX_map applied to the arguments element-
            % by-element e.g.
            %       IX_map (is_lo, is_hi, step)
            %
            % is equivalent to a combination of the output of
            %       IX_map(is_lo(1), is_hi(1), nstep(1))
            %       IX_map(is_lo(2), is_hi(2), nstep(2))
            %           :
            %
            %
            % Cell array specification:
            % -------------------------
            % Cell array where each element is an array of spectrum numbers
            %   >> w = IX_map(cell)             
            %
            %   >> w = IX_map(cell, 'wkno', iw)     % starting workspace (scalar) (increment +ve)
            %                                       % or array length equal to number spectra
            %
            %
            % Read from file:
            % ---------------
            % Read from ascii file containing map (usually extension .map)
            %   >> w = IX_map(filename)                 % Read from ascii file
            %   >> w = IX_map(filename, 'wkno', TF)     % TF = True:  Read workspace numbers (default)
            %                                           % TF = False: Ignore worspace numbers
            %
            % In all cases, if the workspace numbers are not given (i.e. they are 'un-named')
            % they will be left undefined, and workspaces can be addressed by their index
            % in the range 1 to nw, where nw is the total number of workspaces.
            
            
        end
    end
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save (obj, file)
            % Save a map object to an ASCII file
            %
            %   >> save (obj)              % prompts for file
            %   >> save (obj, file)
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
            put_mask (obj, file_full);
            
        end
    end
    
    methods (Static)
        function obj = read (file)
            % Read map data from an ASCII file
            %
            %   >> obj = IX_map.read           % prompts for file
            %   >> obj = IX_map.read (file)
            
            
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
    
end
