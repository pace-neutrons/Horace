classdef kf_sphere_proj<sphere_proj
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % Unlike sphere_proj, which calculates spherical coordinates of
    % scattrging vector Q, kf_sphere_proj calculates spherical coordinates
    % of scattering vector kf, where Q = ki-kf;
    %
    % Usage (with positional parameters):
    %
    % >>sp = kf_sphere_proj(); %default construction
    % >>sp = kf_sphere_proj(Ei);
    % >>sp = kf_sphere_proj(Ei,u,v);
    % >>sp = kf_sphere_proj(Ei,u,v,type);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg,offset,label,title);
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
    % NOTE:
    %       the idea of this projection is that u and v should be set to
    %       the values of u,v vectors, used to obtain sqw object i.e. u
    %       should coicide with beam direction and v selected to define the
    %       uv plane, where rotation occurs.
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
    %
    % all parameters may be provided as 'key',value pairs appearing in
    % arbitrary order after positional parameters
    % e.g.:
    % >>sp = kf_sphere_proj(10,[1,0,0],[0,1,0],'arr','offset',[1,1,0]);
    % >>sp = kf_sphere_proj(10,[1,0,0],'type','arr','v',[0,1,0],'offset',[1,1,0]);
    %
    % Default angular coordinates names and meaning of the coordinate system,
    % defined by sphere_proj are chosen as follows:
    % |kf|    -- coordinate 1 is the modulus of the scattering momentum.
    % theta   -- coordinate 2, the angle between axis u
    %            and the direction of the kf.
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the plane defined by vector v and
    %            perpendicular to u.
    % dE      -- coordinate 4 the energy transfer direction
    %
    % parent's class "type" property describes which scales are avaliable for
    % each direction:
    % for |Q|:
    % 'a' -- Angstrom,
    % 'r' -- scale = max(\vec{u}*\vec{e_h,e_k,e_l}) -- projection of u to
    %                                       unit vectors in hkl directions
    % 'p' -- |u| = 1 -- i.e. scale = |u|
    % 'h','k' or 'l' -- i.e. scale = (a*,b* or c*);
    % for angular units theta, phi:
    % 'd' - degree, 'r' -- radians
    % For energy transfer:
    % 'e'-energy transfer in meV (no other scaling so may be missing)
    %
    properties(Dependent)
        Ei  % incident energy for direct spectrometer or analyzer energy 
        % for indirect spectrometer.
        ki_mod % modulo of vector ki in A^-1. Used for debugging and easy
        % cut range estimation
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
            kf = transform_img_to_pix@sphere_proj(obj,pix_transformed,varargin{:});
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
            obj.cc_to_spec_mat_ = val;
        end
        function mp = get.run_id_mapper(obj)
            mp = obj.run_id_mapper_;
        end
        function obj = set.run_id_mapper(obj,val)
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
