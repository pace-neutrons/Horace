classdef multifit_class
    % Object-oriented multifit for clearer syntax of bound parameters
    %
    % Multifit is used to simultaneously fit a function to several datasets, with
    % optional background functions. 
    % 
    % The data to be fitted can be a set or sets of of x,y,e arrays, or an 
    % object or array of objects of a class. [Note: if you have written your own 
    % class, there are some required methods for this fit function to work. 
    % See notes at the end of this help] 
    % 
    % Syntax:
    %   >> mf = multifit                   % Creates empty multifit object
    %   >> mf = multifit(w);               % Creates multifit object with data 
    %                                      %   to fit as per standard syntax
    %
    %   >> mf = multifit('data',x,y,e)     % Constructor for a single dataset
    %   >> mf = multifit('data',w)         % Constructor for dataset(s) w
    %   >> mf = multifit(...,'ffun',@f)    % Specify foreground fit function(s)
    %   >> mf = multifit(...,'bfun',@f)    % Specify background fit function(s)
    %   >> mf = multifit(...,'fpin',@f)    % Specify foreground fit input params
    %   >> mf = multifit(...,'bpin',@f)    % Specify background fit input params
    %   >> mf = multifit(...,'fpfree',pf)  % Specify foreground fit free params
    %   >> mf = multifit(...,'bpfree',bf)  % Specify background fit free params
    %   >> mf = multifit(...,'fpbind',pb)  % Specify foreground fit bound params
    %   >> mf = multifit(...,'bpbind',bb)  % Specify background fit bound params
    %
    % Legacy syntax:
    %   >> mf = multifit(varargin)         % Syntax as for the multifit function.
    %
    % Example:
    %   >> f = multifit;
    %   >> f.add_dataset(cut1, 'background', @slope, [a1 c]);
    %   >> f.add_dataset(cut2, 'background', @slope, [a2 c]);
    %   >> f.add_dataset(cut3, 'background', @slope, [a3 c]);
    %   >> f.add_binding([1 2],[2 2]); % Binds par 2 of func 2 to par 2 of func 1
    %   >> f.add_binding([1 2],[3 2]); % Binds par 2 of func 3 to par 2 of func 1
    %   >> f.data = {cut1 cut2 cut3};
    %   >> f.bfun = @slope;
    %   >> f.bpin = {[a1 c] [a2 c] [a3 c]};
    %   >> f.local_background = true;
    %   >> f.add_dataset(cut4, 'background', @slope, [a4 c]);   % Error if global_background=true
    %   >> f.ffun = @heisenberg;
    %   >> f.fpin = [J1 J2 D];
    %   >> [fitted_datasets,fit_values] = f.run_fit();
    %
    % Or:
    %  >> [fitted_datasets,fit_values] = multifit({cut1 cut2 cut3}, ...
    %      @heisenberg, [J1 J2 D], ...          % Global foreground
    %      @slope, {[a1 c] [a2 c] [a3 c]}, ...  % Local background, initial values
    %              {[1 1] [1 1] [1 1]}, ...     % All parameters are free
    %              {{},{2,2,1},{2,2,1}})        % Bind parameters 2 of datasets 2,3 to set 1
    %
    % For datasets which are arbitrary classes, multifit requires the following methods:
    %   sigvar_get   - returns the signal, variance and empty mask of the data
    %                  See IX_dataset_1D/sigvar.m for an example.
    %   mask         - applies a mask to an input dataset, returning the masked set
    %                  See IX_dataset_1D/mask.m for an example.
    % and either:
    %   mask_points  - returns a mask for a dataset like the mask_points_xye() function
    %                  See sqw/mask_points.m for an example
    % or
    %   sigvar_getx  - returns the ordinate(s) [bin-centres] of the dataset
    %                  See IX_dataset_1D/sigvar_getx.m for an example. 
    % In addition, all fit functions must be class methods, or a wrapper function must
    % be provided.

    properties
        data
        ffun
        bfun
        fpin
        bpin
        fpfree
        bpfree
        fpbind
        bpbind
        local_foreground
        global_foreground
        local_background
        global_background
    end

    properties (SetAccess = private)
        wout
        fitdata
    end

    properties (Hidden = true, Access = private)
        % By default have one global foreground function, 
        % and a local background function for each dataset.
        foreground_is_local = false;
        background_is_local = true;
        % Need these flags for binding
        all_ffun_present = false;
        all_fpin_present = false;
        all_bfun_present = false;
        all_bpin_present = false;
        np
        nbp
    end

    methods
        % Constructor
        function obj = multifit_class(varargin)
            if nargin>0
                obj.data = varargin{1};
            end
        end
        % Set methods / help files for each field
        function obj = set.data(obj,in_dat)
            obj.data = data(obj,in_dat);
        end
        function obj = set.ffun(obj,in_fun)
            obj.ffun = ffun(obj,in_fun);
            if numel(obj.ffun)==numel(obj.data)
                obj.all_ffun_present = true;
            else
                obj.all_ffun_present = false;
            end
        end
        function obj = set.bfun(obj,in_fun)
            obj.bfun = bfun(obj,in_fun);
            if numel(obj.bfun)==numel(obj.data)
                obj.all_bfun_present = true;
            else
                obj.all_bfun_present = false;
            end
        end
        function obj = set.fpin(obj,in_par)
            [obj.fpin,obj.np] = fpin(obj,in_par);
            if numel(obj.np)==numel(obj.data)
                obj.all_fpin_present = true;
            else
                obj.all_fpin_present = false;
            end
        end
        function obj = set.bpin(obj,in_par)
            [obj.bpin,obj.nbp] = bpin(obj,in_par);
            if numel(obj.nbp)==numel(obj.data)
                obj.all_bpin_present = true;
            else
                obj.all_bpin_present = false;
            end
        end
        function obj = set.fpbind(obj,in_bind)
            obj.fpbind = fpbind(obj,in_bind);
        end
        function obj = set.bpbind(obj,in_bind)
            obj.bpbind = bpbind(obj,in_bind);
        end
        % Set/get the local/global pairs - variables are connected, so we
        % need to use a hidden property or otherwise get infinite recursion
        function obj = set.local_foreground(obj,val)
            obj = local_foreground(obj,val);
        end
        function out = get.local_foreground(obj)
            out = obj.foreground_is_local;
        end
        function obj = set.local_background(obj,val)
            obj = local_background(obj,val);
        end
        function out = get.local_background(obj)
            out = obj.background_is_local;
        end
        function obj = set.global_foreground(obj,val)
            obj = global_foreground(obj,val);
        end
        function out = get.global_foreground(obj)
            out = ~(obj.foreground_is_local);
        end
        function obj = set.global_background(obj,val)
            obj = global_background(obj,val);
        end
        function out = get.global_background(obj)
            out = ~(obj.background_is_local);
        end
    end
end
