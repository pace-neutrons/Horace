classdef horace3_img_interface
    %HORACE3_IMG_INTERFACE class is responsible for providing methods for
    %converting aProjection data into HORACE3 dnd structures (data_sqw_dnd)
    %to save these data in Horace3 file format and maintan compartibility
    %with the algorithms which stil have not been updated from this
    %interface
    %
    properties(Dependent,Hidden)
        % Old confusing u_to_rlu matrix value
        %
        % Matrix to convert from image coordinate system to hklE coordinate
        % system (in rlu or hkle -- both are the same, two different
        % name schemes are used)
        u_to_rlu

        % Three properties below are responsible for support of old binary
        % file format and legacy alignment
        %
        % LEGACY PROPERTY: (used for saving data in old file format)
        % Return the compatibility structure, which may be used as
        % additional input to data_sqw_dnd constructor
        compat_struct;

        % LEGACY PROPERTY:
        % inverted B matrix, obtained from headers and set on
        % projection when loading realigned data from file in the new code
        % as old aligned files modify it and there are no way
        % of identifying if the file was aligned or not. Modern code
        % calculates this matrix on request using alignment matrix attached
        % to pixels
        ub_inv_legacy
        %
        u_to_rlu_legacy; % old u_to_rlu transformation matrix,
        % calculated by original Toby algorithm.
        % scaling factors used in transformation from pix to image
        % coordinate system. Defined by type property
        ulen       % old interface
    end
    properties(Access=protected)
        % inverted ub matrix, used to support alignment as in Horace 3.xxx
        % as real ub matrix is multiplied by alignment matrix there and
        % there are no way of identifying if this happened or not.
        ub_inv_legacy_ = [];        
    end

    methods
        function obj = horace3_img_interface(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here

        end
        %------------------------------------------------------------------
        function ul = get.ulen(obj)
            ul = get_img_scales(obj);
        end
        function ub_inv = get.ub_inv_legacy(obj)
            ub_inv = obj.ub_inv_legacy_;
        end
        function u2rlu_leg = get.u_to_rlu_legacy(obj)
            % U_to_rlu legacy is the matrix, returned by appropriate
            % operation in Horace version < 4.0
            [~,u2rlu_leg] = projaxes_to_rlu_legacy_(obj,[1,1,1]);
            u2rlu_leg = [[u2rlu_leg,zeros(3,1)];[0,0,0,1]];
        end

        function obj = set.ub_inv_legacy(obj,val)
            % no comprehensive checks performed here.  It is compatibility
            % with old file format. The method should be used
            % by saveobj/loadobj only. Use set_ub_inv_compat, which does all
            % necessary checks in any other case.
            obj.ub_inv_legacy_ = val;
        end
        function obj = set_ub_inv_compat(obj,u_to_rlu)
            % Set up inverted ub matrix, used to support alignment as in
            % Horace 3.xxx where the real inverted ub matrix is multiplied
            % by alignment matrix.
            if any(size(u_to_rlu)>3)
                u_to_rlu = u_to_rlu(1:3,1:3);
            end
            obj.ub_inv_legacy_ = u_to_rlu;
        end
        %------------------------------------------------------------------
        function str= get.compat_struct(obj)
            str = struct();
            flds = obj.data_sqw_dnd_export_list;
            for i=1:numel(flds)
                str.(flds{i}) = obj.(flds{i});
            end
        end
        %        
        function obj = set_from_data_mat(obj,u_to_img,ulen)
            % build correct projection from input matrix which tran transformation
            % and ulen matrices.
            %
            [ur,vr,wr,tpe,nonortho]=obj.uv_from_data_rot(u_to_img(1:3,1:3),ulen(1:3));
            check = obj.do_check_combo_arg;
            obj.do_check_combo_arg = false;
            obj.u = ur;
            obj.v = vr;
            obj.w = wr;
            obj.type = tpe;
            obj.nonorthogonal = nonortho;
            obj.do_check_combo_arg = check;
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end
        end
        %------------------------------------------------------------------
        function mat = get.u_to_rlu(obj)
            % get old u_to_rlu transformation matrix from current
            % transformation matrix. Used in legacy code and axes captions
            %
            %
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to pixels in hkl(dE) (rlu) coordinate
            % system
            %
            mat = get_u_to_rlu_mat(obj);
        end        
    end
    methods(Access=protected)
        function  mat = get_u_to_rlu_mat(obj)
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to coordinates in hkl(dE) (rlu) coordinate
            % system
            %
            mat = inv(obj.get_pix_img_transformation(4)*obj.bmatrix(4));
        end        
    end
    methods(Static)
        function lst = data_sqw_dnd_export_list()
            % Method, which define the values to be extracted from projection
            % to convert to old style data_sqw_dnd class.
            % New data_sqw_dnd class (rather dnd class) contains the whole
            % projection, so this method is left for compatibility with
            % old Horace
            lst = {'u_to_rlu','nonorthogonal','alatt','angdeg','uoffset','label'};
        end
    end
    %======================================================================
    methods(Abstract,Access=protected)
    end
    
end