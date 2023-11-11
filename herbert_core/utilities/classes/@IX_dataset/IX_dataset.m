classdef IX_dataset < data_op_interface & serializable
    % Abstract parent class for IX_datasets_Nd;
    properties(Dependent)
        %title:  dataset title (will be plotted on a grapth)
        title;
        % signal -- array of signal...
        signal
        % error  -- array of errors
        error
        % s_axis -- IX_axis class containing signal axis caption
        s_axis
    end


    properties(Access=protected)
        title_={};
        % emtpy signal
        signal_=zeros(0,1);
        % empty error
        error_=zeros(0,1);
        % has empty signals-IX_axis
        s_axis_=IX_axis('Counts');
        %
        % generic n-D binning data;
        xyz_;
        % generic n-D  axis array
        xyz_axis_
        % generig n-D distribution sign
        xyz_distribution_;
        %
    end
    %======================================================================
    methods(Abstract,Static)
        % get number of class dimensions
        nd  = ndim()
    end
    %======================================================================
    methods(Abstract,Access=protected)
        % Generic checks:
        % verify and set signal or error arrays
        obj = check_and_set_sig_err(obj,field_name,value);
    end

    %======================================================================
    methods(Abstract,Static,Access=protected)
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, wout_x);
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax, xbounds_true);
    end

    %======================================================================
    methods(Static)
        % Read object or array of objects of an IX_dataset type from
        % a binary matlab file. Inverse of save.
        obj = read(filename);
        % Access internal function for testing purposes
        function [x_out, ok, mess] = bin_boundaries_from_descriptor(xbounds, x_in)
            [x_out, ok, mess] = bin_boundaries_from_descriptor_(xbounds, x_in);
        end

    end
    %======================================================================
    methods
        % Take absolute value of an IX_dataset_nd object or array of IX_dataset_nd objects
        wout = abs(w)
        %------------------------------------------------------------------
        %Sqeeze singleton dimensions awaay in IX_dataset_nd objects
        %to get to object of lower dimensionality
        wout=squeeze_IX_dataset(win,iax)
        % Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
        [wout,ok,mess] = rebin_IX_dataset (win, integrate_data,...
            point_integration_default, iax, descriptor_opt, varargin)
        %

        % Save object or array of objects of class type to binary file.
        % Inverse of read.
        save(w,file)

        %
        % get sigvar object from the dataset
        wout = sigvar (w)
        %Get signal and variance from object, and a logical array of which values to keep
        [s,var,msk] = sigvar_get (w)
        % Set output object signal and variance fields from input sigvar object
        w = sigvar_set(w,sigvarobj)
        %Matlab size of signal array
        sz = sigvar_size(w)
        %------------------------------------------------------------------
        % accessors, whcih do not use properties
        %------------------------------------------------------------------
        function xyz = get_xyz(obj,nd)
            % get x (y,z) values without checking for their validity
            if ~exist('nd', 'var')
                xyz  = obj.xyz_;
            else
                xyz  = obj.xyz_{nd};
            end
        end
        %
        function sig = get_signal(obj)
            % get signal without checking for its validity
            sig = obj.signal_;
        end
        %
        function sig = get_error(obj)
            % get error without checking for its validity
            sig = obj.error_;
        end
        function dis = get_isdistribution(obj)
            % get boolean array informing if the state of distribution
            % along all axis
            dis= obj.xyz_distribution_;
        end

        % Set signal, error and selected axes in a single instance of an IX_dataset object
        wout=set_simple_xsigerr(win,iax,x,signal,err,xdistr)

        %===================================================================
        % Properties:
        %===================================================================
        function tit = get.title(obj)
            tit = obj.title_;
        end
        %
        function sig = get.signal(obj)
            sig = obj.signal_;
        end
        %
        function err = get.error(obj)
            err = obj.error_;
        end
        %------------------------------------------------------------------
        %
        function ax = get.s_axis(obj)
            ax = obj.s_axis_;
        end
        %
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function obj = set.title(obj,val)
            obj = check_and_set_title_(obj,val);
        end
        %
        %
        function obj = set.s_axis(obj,val)
            obj.s_axis_ = obj.check_and_build_axis(val);
        end
        %
        %------------------------------------------------------------------
        %
        function obj = set.signal(obj,val)
            obj = check_and_set_sig_err(obj,'signal',val);
            if obj.do_check_combo_arg
                obj = check_combo_arg (obj);
            end
        end
        %
        function obj = set.error(obj,val)
            obj = check_and_set_sig_err(obj,'error',val);
            if obj.do_check_combo_arg
                obj = check_combo_arg (obj);
            end
        end
        %
        function wout = copy(win)
            wout = win;
        end
    end
    %======================================================================
    methods(Access=protected)
        % common auxiliary service methods, which can be overloaded if
        % requested
        xyz = get_xyz_data(obj,nax)
        % set x, y or z axis data
        obj = set_xyz_data(obj,nax,val)
        % Integrate an IX_dataset object or array of IX_dataset
        % objects along the axes, defined by direction
        wout = integrate_xyz(win,array_is_descriptor, dir, varargin)
        % Make a cut from an IX_dataset object or array of IX_dataset objects along
        % specified axess direction(s).
        wout = cut_xyz(win,dir,varargin)
        % Rebin an IX_dataset object or array of IX_dataset objects along
        % along the axes, defined by direction
        wout = rebin_xyz(win, array_is_descriptor,dir,varargin)

        %w = unary_op_manager (w1, unary_op)
    end
    %======================================================================
    methods(Static,Access=protected)
        % verify if x,y,z field data are correct
        val = check_xyz(val);
        % Internal function used to verify and set up an axis
        obj = check_and_build_axis(val);
    end
    %======================================================================
    % Abstract interface:
    %======================================================================
    methods(Abstract)
        % (re)initialize object using constructor' code
        obj = init(obj,varargin);
        % Find number of dimensions and extent along each dimension of the signal arrays.
        [nd,sz] = dimensions(w)
        % Return array containing true or false depending on dataset being
        % histogram or point;
        status=ishistogram(w,n)
        % Get information for one or more axes and if it has histogram data
        % for each axis
        [ax,hist]=axis(w,n)
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant, Access=private)
        % list of filenames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_ = {'title','signal','error','s_axis'}
    end
    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 2;
        end

        function flds = saveableFields(~)
            flds = IX_dataset.fields_to_save_;
        end
    end
    methods(Access = protected)
        function [S_updated,obj] = convert_old_struct(obj, S, varargin)
            fn = fieldnames(S);
            data = struct2cell(S);
            fnm = cellfun(@(x)regexprep(x,'_$',''),fn,'UniformOutput',false);
            S_updated = cell2struct(data,fnm);
            if isfield(S_updated,'xyz')
                xyz_prop = {'x','y','z'};
                xyz_dist = {'x_distribution','y_distribution','z_distribution'};
                xyz_axiz   = {'x_axis','y_axis','z_axis'};
                for i=numel(S_updated.xyz)
                    S_updated.(xyz_prop{i}) = S_updated.xyz{i};
                    S_updated.(xyz_dist{i}) = S_updated.xyz_distribution(i);
                    S_updated.(xyz_axiz{i}) = S_updated.xyz_axis(i);
                end
            end
        end
    end

end

