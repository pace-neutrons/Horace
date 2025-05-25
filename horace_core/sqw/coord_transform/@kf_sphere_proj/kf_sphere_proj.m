classdef kf_sphere_proj<sphere_proj
    % Class defines special projection, used by cut_sqw
    % to make spherical cut in special spherical coordinate system
    % related to the spectrometer frame.
    %
    % Unlike sphere_proj, which calculates spherical coordinates of
    % scattring vector Q, kf_sphere_proj, calculates spherical coordinates
    % of scattering vector kf, where Q = RM*(ki-kf), where RM is rotation
    % matrix which describes the crystal rotation from axis qx to
    % beam direction in Crystal Cartesian coordinate system (see
    % "rundatah/calc_projections" for the details of this transformation)
    %
    %
    % Using simple calculations one may found out that this projection is a
    % degenerated projection, as its two axis dE and kf are bound by
    % arithmetic relation so projection's transformation from pixels to image
    % destroys information about crystal orientation and inverse
    % transformation is ill defined. Having this transformation defined is
    % prerequest of working with normal projection, so this projection can
    % be used in special cuts only, with generic projection property
    % disable_pix_preselection set to true.
    %
    % Currently in the code it should and can be used as part of
    % transformation which provides instrument view only. The instrument
    % view can be obtained for sqw objects only so cuts with this
    % projection will fail on DnD objects.
    %
    % Tested on direct instruments only.
    %
    % Usage (with positional parameters):
    %
    % >>sp = kf_sphere_proj(); %default construction
    % >>sp = kf_sphere_proj(Ei);
    % >>sp = kf_sphere_proj(Ei,u,v);
    % >>sp = kf_sphere_proj(Ei,u,v,type);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg,offset,label,title);
    % >>sp = kf_sphere_proj(Ei,....,emode,cc_to_spec_mat,run_id_mapper)
    %
    % As for any serializable, the positional parameters may be replaced by
    % random set of key-values pairs where keys are the names of the
    % properties to set.
    %
    % Where:
    % Ei -- Incident energy in direct spectrometer. Will work for indirect
    %       too though its meaning a bit unclear.
    % u  -- [1,3] vector of hkl direction of z-axis of the spherical
    %        coordinate system this projection defines. It defines the
    %        direction of ki vector (incident beam)
    %        The axis to calculate theta angle from.
    % v  -- [1,3] vector of hkl direction of x-axis of the spherical
    %       coordinate system, the axis to calculate Phi angle from.
    %
    % type-- 3-letter character array, defining the spherical
    %        coordinate system units (see type property below)
    % alatt-- 3-vector of lattice parameters. Value will be ignored by cut.
    % angdeg- 3-vector of lattice angles. Value will be ignored by cut.
    % offset- 4-vector, defining hkldE value of centre of
    %         coordinates of the spherical coordinate
    %         system.
    % label - 4-element cellarray, which defines axes labels
    % title - character string to title the plots of cuts, obtained
    %         using this projection.
    % emode - instrument operation mode. Only direct (value 1) has been
    %         tested so far.
    % cc_to_spec_mat
    %       - cellarray of martices which convert vectors from spectrometer
    %         frame to Crystal cartesian coordinate system. See Experiment.
    %
    % all parameters may be provided as 'key',value pairs appearing in
    % arbitrary order after positional parameters
    %
    % NOTE 1:
    %       the idea of this projection is that u and v should be set to
    %       the values of u,v vectors, used to obtain sqw object i.e. u
    %       should coicide with beam direction and v selected to define the
    %       uv plane, where rotation occurs.
    % NOTE 2:
    %       This is special projection which would not work without
    %       cc_to_spec_mat and run_id_mapper being defined.
    %
    properties(Dependent)
        Ei  % incident for direct or analyzer for indirect energy.
        ki_mod % read-only parameter. Modulo of vector ki in A^-1.
        % Used for debugging and easy cut range estimation
        %
        emode % data processing mode (1-direct, 2-indirect, 0 -- elastic)
    end
    properties(Dependent,Hidden)
        cc_to_spec_mat;
        run_id_mapper;
    end
    properties(Access=protected)
        Ei_     = [];
        Energy_transfer_ % used for indirect mode only
        ki_mod_ = [];
        ki_     = [];
        emode_  = 1;
        cc_to_spec_mat_ = {}; %cellarray of matrices used to transform each
        % run event coordinates from Crytal Cartesian coordinate system to
        % the spectrometer frame.
        run_id_mapper_ % holder for fast map class which converts actual run-id
        % into the number of IX_experiment array elelment.
    end
    methods
        function obj=kf_sphere_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@sphere_proj();
            obj.type_ = 'add';
            obj.label = {'|kf|','\theta','\phi','En'};
            if nargin>0
                obj = obj.init(varargin{:});
            end
            % Disable pixels preselection, as this projection can not do
            % inverse image->pixels transformation correctly.
            obj.disable_pix_preselection = true;
        end
        function obj = copy_proj_param_from_source(obj,cut_source)
            % overloaded aProjectionBase method, which sets up
            % kf_sphere_proj specific properties necessary for this kind of
            % projection to work.
            %
            % Namely, in addition to standard projection properties, this
            % projection works on sqw objects only and requests incident
            % energies and set of transformation matrices, used for
            % convertion from instrument frame to Crystal Cartesian
            % coordinate system. These matrices are stored in
            % Experiment/IX_dataset array.
            obj = copy_proj_param_from_source@aProjectionBase(obj,cut_source);
            obj = copy_proj_param_from_source_(obj,cut_source);
        end
        function ax_bl = get_proj_axes_block(obj,default_bin_ranges,requested_bin_ranges)
            % Construct the axes block, corresponding to this projection class
            % Returns projection-specific AxesBlockBase class, built from the
            % block ranges or the binning ranges.
            %
            % Overloaded for kf_sphere_projection to add different
            % axes_block title, which highlights limited usage of
            % this projection.
            %
            % Inputs:
            % default_bin_ranges --
            %           cellarray of the binning ranges used as defaults
            %           if requested binning ranges are undefined or
            %           infinite. Usually it is the range of the existing
            %           axes block, transformed into the system
            %           coordinates, defined by cut projection using
            %           dnd.get_targ_range(targ_proj) method.
            % requested_bin_ranges --
            %           cellarray of cut bin ranges, requested by user and
            %           expressed in source coordinate system.
            %
            % Returns:
            % ax_bl -- initialized, i.e. containing defined ranges and
            %          numbers of  bins in each direction, AxesBlockBase
            %          corresponding to the kf_sphere projection.
            %
            ax_bl   = get_proj_axes_block@aProjectionBase(obj,default_bin_ranges,requested_bin_ranges);
            ax_bl   = ax_bl.add_proj_description_function(@(x)sprintf('Instument view along beam direction'));
        end

        %------------------------------------------------------------------
        function emode = get.emode(obj)
            emode = obj.emode_;
        end
        function obj = set.emode(obj,val)
            if ~(isnumeric(val)&&isscalar(val)&&ismember(val,[0,1,2]))
                error('HORACE:kf_sphere_proj:invalid_arguments', ...
                    'emode must be a scalar number in the range 0-2. It is %s',...
                    disp2str(val))
            end
            obj.emode_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function ei = get.Ei(obj)
            ei = obj.Ei_;
        end
        function ki = get.ki_mod(obj)
            ki=obj.ki_mod_;
        end
        function obj = set.Ei(obj,val)
            if ~isnumeric(val)
                error('HORACE:kf_sphere_proj:invalid_arguments', ...
                    'Incident beam values must be numeric. Got %d',val);
            end
            if val<=0
                error('HORACE:kf_sphere_proj:invalid_arguments', ...
                    'Incident beam energy must be poisitive. Got %d',val);
            end
            obj.Ei_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into spectrometer coordinate system defined by the object
            % properties
            %
            % Input:
            % pix_data -- [3-5xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system.
            %             if 5th row of pix_coordinates is present, it
            %             describes run_id-s, referred
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_out -- [3xNpix or [4xNpix]Array the pixels coordinates
            %            transformed into spherical coordinate system
            %            defined by object properties
            %
            if isa(pix_data,'PixelDataBase')
                pix_cc = pix_data.q_coordinates;
                run_id = pix_data.run_idx;
                %shift_ei = obj.offset(4) ~=0; % It is not implemented and
                %does not look like this should be implemented

                ndim = 3;
                input_is_obj = true;
            else % This method needs 5xnpix matrix as acively uses run_id-s
                % if its 3-d -- matrix is 3-dimensional and energy is not shifted
                % anyway
                ndim         = size(pix_data,1);
                pix_cc       = pix_data(1:3,:);
                if ndim<5
                    % a point in Crystal Cartesian may reflected into
                    % multiple points in the instrument frame, depending on
                    % the crystal position
                    run_id = obj.run_id_mapper_.keys(1);
                    run_id       = repmat(run_id,1,size(pix_cc,2));
                else
                    run_id       = pix_data(5,:);
                end
                input_is_obj = false;
            end
            % get indices of transformation martices per each run
            run_id = obj.run_id_mapper_.get_values_for_keys(run_id,true,1);

            np = numel(run_id);
            %desort = fast_map(run_id_sorted,1:np);
            [run_id_sorted,sid] = sort(run_id);
            pix_cc = pix_cc(:,sid);
            un_id  = unique(run_id_sorted);
            % find edges for unique pixels blocks
            bl_edges = [0,find(diff(run_id_sorted)>0),np];
            n_blocks = numel(un_id);
            %used_transf = obj.cc_to_spec_mat_(used_transf_nums);
            pix_sectr = zeros(3,np);
            for i = 1:n_blocks
                mat_num   = un_id(i);
                run_pixels = squeeze(mtimesx_horace(obj.cc_to_spec_mat_{mat_num},reshape(pix_cc(:,bl_edges(i)+1:bl_edges(i+1)),3,1,bl_edges(i+1)-bl_edges(i))));

                run_pos  = ismember(run_id,mat_num);
                pix_sectr(:,run_pos) = run_pixels;
            end

            kf = obj.ki_-pix_sectr;

            pix_transformed = transform_pix_to_img@sphere_proj(obj,kf,varargin{:});
            if ndim > 3 || input_is_obj
                if input_is_obj
                    pix_transformed = [pix_transformed;pix_data.dE];
                else
                    pix_transformed = [pix_transformed;pix_data(4,:)];
                end
            end
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            %
            % This is fake transformation to satisfy the interface. No
            % sufficient information about about reverse transformation is
            % currently stored within the image
            kf = transform_img_to_pix@sphere_proj(obj,pix_transformed,varargin{:});
            % this should be multiplied to appropriate rotation matrix but
            % no into about the matrix is currently present in the
            % image. Image is degenerated.
            pix_cc = obj.ki_-kf;
            if size(pix_transformed,1) > 3
                pix_cc = [pix_cc;kf(4,:)];
            end
        end
    end

    methods(Access = protected)
        function name = get_axes_name(~)
            % return the name of the axes class, which corresponds to this
            % projection
            name = 'sphere_axes';
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods(Access=protected)
        function flds = init_order_fields(obj)
            % overloadeded field construction order to put incident energy
            % first while using sphere_proj initialization procedure.
            flds = init_order_fields@CurveProjBase(obj);
            flds = ['Ei';flds(:);'emode';'cc_to_spec_mat';'run_id_mapper'];
        end
    end

    methods
        % these properties are dangerous to set from interface as this
        % information is usually hidden within experiment. It is here to
        % provide valid serializable interface.
        function mf = get.cc_to_spec_mat(obj)
            mf = obj.cc_to_spec_mat_;
        end
        function obj = set.cc_to_spec_mat(obj,val)
            if ~iscell(val)
                error('HORACE:kf_sphere_proj:invalid_argument',[ ...
                    'Input for cc_to_spec_mat must be celarray of matrices,\n' ...
                    'which convert pixels from crystal cartesian to spectrometer coordinate systen.\n' ...
                    'Provided class is %s'], ...
                    class(val));
            end
            obj.cc_to_spec_mat_ = val;
        end
        function mp = get.run_id_mapper(obj)
            mp = obj.run_id_mapper_;
        end
        function obj = set.run_id_mapper(obj,val)
            if ~isa(val,'fast_map')
                error('HORACE:kf_sphere_proj:invalid_argument',[ ...
                    'Input for run_id_mapper must be instance of fast_map class\n' ...
                    'which sets relationship between pixel''s run-id and number of spectrometer matrix.\n' ...
                    'Provided class is %s'], ...
                    class(val));
            end
            obj.run_id_mapper_ = val;
        end

        function  flds = saveableFields(obj)
            flds = saveableFields@sphere_proj(obj);
            flds = ['Ei';flds(:);'emode';'cc_to_spec_mat';'run_id_mapper'];
        end
        function ver  = classVersion(~)
            ver = 1;
        end
        function obj = check_combo_arg (obj)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws 'HORACE:CurveProjBase:invalid_argument' or
            % 'HORACE:kf_sphere_proj:not_implemented' depending on the
            % issue containing the message suggesting the reason for
            % failure if the inputs are inconsistent with each other.
            %
            % Normalizes input vectors to unity and constructs the
            % transformation to new coordinate system when operation is
            % successful
            obj = check_combo_arg@sphere_proj(obj);
            obj = check_combo_arg_(obj);
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = kf_sphere_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
end
