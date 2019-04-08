classdef cut_transf
    % Helper class contains range of parameters necessary to combine
    % equivalent zones, namely defining a zone to combine with another zone
    % and symmetry transformation to apply to coordinates.
    %
    % More generally, it used to describe cut to combine with another cut
    %
    % $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
    %
    properties(Dependent)
        zone_id  %a number, uniquely defining zone to combine
        % also used as base to modify pixel id for each zone
        %
        qh_range % range of the cut in qh direction
        qk_range % range of the cut in qk direction
        ql_range % range of the cut in ql direction
        de_range % range of the cut in energy direction
        cut_range % the property which returns all ranges above as single cellarray with four elements
        %
        zone_center   % hkl coordinates of the zone centre to transform
        %
        target_center % hkl coorinates of the zones to make transformation to
        %
        %
        transf_matrix % 3x3 matrix describing the symmentry transfornaton used
        %  to convert coordinates of this zone into coordinates of target
        %  zone
        shift % 3x1 vector, descibing the shift used to convert coordinates of
        % this zone into coodinates of the target zone.
        
        correct_fun % handle to function, to apply to sqw object correcting
        % some object parameters (e.g. magnetic form factor or Boze factor)
        % function should have form :
        %>>corrected_sqw_obj =correct_fun(source_sqw_object);
        %
        transf_defined % true, if symmetry transformation has been specified
        % and false otherwise
    end
    properties(Access=protected)
        dqe_=[0,0,0,0]
        qe_range_ = [-1,1;-1,1;-1,1;-Inf,Inf]
        zone_center_=[0,0,0]
        target_center_=[0,0,0]
        transf_matrix_=eye(3);
        shift_ = [0,0,0];
        zone_id_ = 0;
        correct_fun_ = [];
        transf_defined_ = false;
    end
    
    
    methods
        function obj=cut_transf(varargin)
            %Cut transformation constructor
            %Usage
            %>>tr = cut_transf(dq,dE) -- define cut transformation in all 4
            %                            directions specifying dq- dE steps
            %                            The q-ranges in this case are
            %                            assumed to be from -1 to 1 (in
            %                            hkl) and E-range will be picked up
            %                            from sqw object.
            %>>tr = cut_transf([q_min,dq,q_max],[e_min,dE,e_max])
            %or
            %>>tr = cut_transf([q_min,q_max],[e_min,dE,e_max])
            %                     -- define cut transformation in all 4
            %                         directions specifying q-dE ranges and
            %                         steps, but all q-ranges are equal
            %                         Behaves like
            %                         cut_sqw, so two ranges mean
            %                         integration in this direction
            % or:
            %tr = cut_transf([qh_min,dqh,qh_max],[qk_min,dqk,qk_max],...
            %                [ql_min,dql,ql_max],[e_min,dE,e_max])
            %        ---  The form equivalet to cut_sqw form, defining cuts
            %             in all 4 directions explicitly
            %
            obj = cut_transf_(obj,varargin{:});
        end
        %-----------------------------------------------------------------
        % Signatures of public methods, defined in class folder
        %
        % caclculates and defines transformation, used by
        % combine_equivalent_zones algorithm (reflection)
        % Nullifies shift transformation if any was defined
        obj=set_sigma_transf(obj);
        % Define shift transformation, used by advanced combine_equivalent_zones
        % algrithm
        % resets any matrix transformations to unit transformaton if any
        % was defined
        obj=set_shift_transf(obj);
        %-----------------------------------------------------------------
        function ok = get.transf_defined(obj)
            ok= obj.transf_defined_;
        end
        function mat = get.transf_matrix(obj)
            % return transformation matrix
            mat = obj.transf_matrix_;
        end
        function obj = set.transf_matrix(obj,val)
            % set 3x3 matrix used to convert q-coordinates
            obj = check_and_set_transf_(obj,val);
            obj.transf_defined_ = true;
        end
        function shift = get.shift(obj)
            % return lattice shift
            shift = obj.shift_;
        end
        function obj = set.shift(obj,val)
            % set lattice shift
            obj = check_and_set_vector_(obj,'shift',val);
            obj.transf_defined_ = true;
        end
        function obj = clear_transformations(obj)
            % clear all existing transformations and set it up to unit
            % transformation with no shift. transf_defined property
            % reads false.
            obj.shift_ = [0,0,0];
            obj.transf_matrix_=eye(3);
            obj.transf_defined_ = false;
        end
        %-----------------------------------------------------------------
        function zc = get.zone_center(obj)
            % hkl center of zone to transform.
            zc = obj.zone_center_;
        end
        function obj = set.zone_center(obj,val)
            % set hkl center of zone to transform.
            obj = check_and_set_vector_(obj,'zone_center',val);
        end
        function zc = get.target_center(obj)
            % hkl center of zone to transform to
            zc = obj.target_center_;
        end
        function obj = set.target_center(obj,val)
            % set hkl center of zone to transform to
            obj = check_and_set_vector_(obj,'target_center',val);
        end
        %--------------------------------------------------------------
        function id = get.zone_id(obj)
            id = obj.zone_id_;
        end
        function obj = set.zone_id(obj,val)
            if val>=0
                obj.zone_id_ = val;
            else
                error('CUT_TRANSFORM:invalid_argument','zone id has to be non-begative number')
            end
        end
        %
        function id = get.correct_fun(obj)
            id = obj.correct_fun_;
        end
        function obj = set.correct_fun(obj,f)
            if isa(f, 'function_handle')
                obj.correct_fun_ = f;
            else
                error('CUT_TRANSFORM:invalid_argument','input argument has to be a function handle')
            end
        end
        %--------------------------------------------------------------
        function range = get.qh_range(obj)
            % range in qh-direction
            range = get_range_(obj,1);
        end
        function range = get.qk_range(obj)
            % range in qk-direction
            range = get_range_(obj,2);
        end
        function range = get.ql_range(obj)
            % range in ql-direction
            range = get_range_(obj,3);
        end
        function range = get.de_range(obj)
            % range in e-direction
            range = get_range_(obj,4);
        end
        %%%
        function obj = set.qh_range(obj,val)
            obj = set_range_(obj,1,val);
        end
        function obj = set.qk_range(obj,val)
            obj = set_range_(obj,2,val);
        end
        function obj = set.ql_range(obj,val)
            obj = set_range_(obj,3,val);
        end
        function obj = set.de_range(obj,val)
            obj = set_range_(obj,4,val);
        end
        %--------------------------------------------------------------
        function range = get.cut_range(obj)
            % Retrieve full cut range in the form of cellarray, suitable
            % for using by cut_sqw/cut_dnd functions
            range = get_cut_range_(obj);
        end
        
    end
    
end
