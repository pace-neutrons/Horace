classdef (Abstract) SQWDnDBase < serializable
    %SQWDnDBase Abstract SQW/DnD object base class
    %
    %   Abstract class defining common API and atrributes of the SQW and
    %   DnD objects
    methods (Abstract)
        %------------------------------------------------------------------
        % various useful operations and methods. Both internal and
        % producing useful result
        pixels = has_pixels(win);     % Check if sqw or dnd object has pixels.
        %                             % DnD object always returns false.
        [nd,sz] = dimensions(win);    % Return size and shape of the image
        %                             % arrays in sqw or dnd object
        %------------------------------------------------------------------
        save_xye(obj,varargin);       % save xye data into file
        s=xye(w, null_value);         % return a strucute, containing xye data
        %
        wout = smooth(win, varargin); % Run smooth operation over DnD
        %                             % objects or sqw objects without pixels
        [wout,mask_array] = mask(win, mask_array); % mask image data and
        %                             % corresponding pixels if available
        %------------------------------------------------------------------
        % sigvar block
        wout              = sigvar(w); % Create sigvar object from sqw or dnd object
        [s,var,mask_null] = sigvar_get (w); %
        w                 = sigvar_set(win, sigvar_obj);
        sz                = sigvar_size(w);
        %------------------------------------------------------------------
        wout = cut(obj, varargin); % take cut from a sqw or sqw/dnd object
    end
    properties(Constant)
        % the size of the border, used in gen_sqw. The img_db_range in gen_sqw
        % exceeds real pix_range (or input pix_range) by this value.
        border_size = -4*eps
    end


    methods (Static,Hidden) % should be protected but Matlab have some issues with calling this 
        % from children
        %
        function [proj, pbin, opt] = process_and_validate_cut_inputs(data,...
                return_cut, varargin)
            % interface to private cut parameters parser/validator
            % checking and parsing cut inputs in any acceptable form
            ndims = data.dimensions;
            [proj, pbin, opt]= cut_parse_inputs_(data,ndims, return_cut, varargin{:});
        end
        %
        function [alatt,angdeg,cor_mat]=parse_change_crystal_arguments(alatt0,angdeg0,exper_info,varargin)
            % process input parameters for change crystal routine and
            % return standard form of the arguments to use in change_crystal
            % Most commonly:
            %   >> [alatt,angdeg,cor_mat] = change_crystal (alatt0,angdeg0,exper_info,rlu_corr)
            %                               change lattice parameters and orientation
            %
            %  where
            % alat0   -- initial lattice parametes stored in the sqw file
            % angdeg0 -- initial lattice angles stored in the sqw file
            % exper_info -- Experiment class, describing the experiment,
            %             stored in sqw file
            %             May be empty for dnd objects
            %   rlu_corr    Matrix to convert notional rlu in the current crystal lattice to
            %              the rlu in the the new crystal lattice together with any re-orientation
            %              of the crystal. The matrix is defined by the matrix:
            %                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
            %               This matrix can be obtained from refining the lattice and
            %              orientation with the function refine_crystal (type
            %              >> help refine_crystal  for more details).

            %
            % OR
            %   >> [alatt,angdeg,cor_mat] = change_crystal (__,alatt)
            %                               change just length of lattice vectors
            %   >> [alatt,angdeg,cor_mat] = change_crystal (__, alatt, angdeg)
            %                               change all lattice parameters
            %   >> [alatt,angdeg,cor_mat] = change_crystal (__, alatt, angdeg, rotmat)
            %                               change lattice parameters and orientation
            %   >> [alatt,angdeg,cor_mat] = change_crystal (__, alatt, angdeg, u, v)   %
            %                               change lattice parameters and redefine u, v
            %                               (works on sqw objects only)
            % where:
            % alatt -- corrected lattice parameters
            % angdeg -- corrected lattice angles

            [alatt,angdeg,cor_mat]=parse_change_crystal_arguments_(alatt0,angdeg0,exper_info,varargin{:});
        end

    end
    methods(Static,Access=protected)

        
    end

    methods (Abstract, Access = protected)
        wout = unary_op_manager(w, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
        wout = sqw_eval_pix(wout, sqwfunc, ave_pix, pars, outfile, i);
        %
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        %                              % binning of an sqw or dnd object
    end

    methods  % Public
        [sel,ok,mess] = mask_points(win, varargin);
        varargout = change_crystal (varargin);

        cl = save(w, varargin);

        [xout,yout,sout,eout,nout] = convert_bins_for_shoelace(win, wref);
        wout = IX_dataset_1d(w);
        wout = IX_dataset_2d(w);
        wout = IX_dataset_3d(w);
        [q,en]=calculate_q_bins(win); % Calculate qh,qk,ql,en for the centres
        %                             % of the bins of an n-dimensional sqw
        %                             % or dnd dataset
        qw=calculate_qw_bins(win,optstr) % Calculate qh,qk,ql,en for the
        %                             % centres of the bins of an n-dimensional
        %                             % sqw or dnd dataset.

        % rebin an object to the other object with the dimensionality
        % smaller then the dimensionality of the current object
        obj = rebin(obj,varargin);
        %------------------------------------------------------------------
        [wout_disp, wout_weight] = dispersion(win, dispreln, pars) % Calculate
        %                             % dispersion relation for dataset or
        %                             % array of datasets.
        wout = disp2sqw_eval(win, dispreln, pars, fwhh, opt);
        wout = disp2sqw(win, dispreln, pars, fwhh,varargin); % build dispersion relation
        %                             % on image of sqw or dnd object
        %------------------------------------------------------------------
        wout = func_eval(win, func_handle, pars, varargin);
        wout = sqw_eval(win, sqwfunc, pars, varargin);
        %------------------------------------------------------------------
        varargout = multifit_func (varargin);
        varargout = multifit_sqw (varargin);
        varargout = multifit_sqw_sqw (varargin);
    end

    methods (Access = protected)
        wout = binary_op_manager(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);

        wout = sqw_eval_nopix(win, sqwfunc, all_bins, pars); % evaluate function
        %                             % on an image stored in an sqw object
        function [func_handle, pars, opts] = parse_eval_args(win, ...
                func_handle, pars, varargin)
            % paser for funceval function input parameters
            [func_handle, pars, opts] = parse_eval_args_(win, func_handle, ...
                pars, varargin{:});
        end
        function [wout,log_info] = cut_single(obj, tag_proj, targ_axes, outfile,log_level)
            [wout,log_info] = cut_single_(obj, tag_proj, targ_axes, outfile,log_level);            
        end
    end

    methods (Access = private)
        status = adjust_aspect(w);
        [ok,mess,adjust,present]=adjust_aspect_option(args_in);
        dout = smooth_dnd(din, xunit, varargin);
    end
end
