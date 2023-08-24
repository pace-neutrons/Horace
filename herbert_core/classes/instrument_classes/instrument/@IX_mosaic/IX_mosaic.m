classdef IX_mosaic < serializable
    % Mosaic spread object
    properties (Access=protected)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        xaxis_ = [1,0,0];
        yaxis_ = [0,1,0];
        % default mosaic pdf function handle
        mosaic_pdf_ = @rand_mosaic_gaussian;
        parameters_ = 0;
    end

    properties (Dependent)
        % Mirrors of private properties
        xaxis
        yaxis
        mosaic_pdf
        parameters
    end
    properties(Dependent,Hidden)
        % the string which corresponds to string representation
        % (func2str applied) of the handle to mosaic_pdf custom function.
        mosaic_pdf_string
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mosaic (varargin)
            % Create sample object
            %
            %   >> mosaic = IX_mosaic (xaxis, yaxis, mosaic_pdf, parameters)
            %
            % Default Gaussian mosaic spread:
            % - isotropic Gaussian (fwhh_deg a scalar):
            %   >> mosaic = IX_mosaic (fwhh_deg)
            %
            % - anisotropic Gaussian (fwhh_deg a 3-vector, or 3x3 matrix)
            %   >> mosaic = IX_mosaic (xaxis, yaxis, fwhh_deg)
            %
            % - generic mosaic function with default xaxis and yaxis
            %   >> mosaic = IX_mosaic (mosaic_pdf, parameters)
            %
            %
            %   xaxis           Direction of x-axis of rotation matrix description
            %                   A vector in reciprocal lattice units
            %                   Default: [1,0,0]
            %
            %   yaxis           Direction of y-axis of rotation matrix description
            %                   A vector in reciprocal lattice units.
            %                   Default: [0,1,0]
            %
            %                   xaxis and yaxis together define the orinetation
            %                   of the orthonormal frame in which the random
            %                   rotation vectors produced by the mosaic function
            %                   below are expressed
            %
            %                   The frame is defined in the usual way: the x-axis
            %                   is along xaxis; the y-axis is in the plane of
            %                   xaxis and yaxis perpendicular to xaxis and with
            %                   a positive component along yaxis; the z-axis is
            %                   perpendicular to the x-axis and y-axis in the
            %                   right-handed sense.
            %
            %   mosaic_pdf      Mosaic spread distribution function that
            %                   returns random rotation vectors. Function handle.
            %
            %                   Default: @rand_mosaic_gaussian
            %
            %                   The mosaic spread function must have the form:
            %                       V = my_random_vectors (object, sz, p1, p2,...)
            %                   where:
            %                       object      IX_mosaic object
            %                       sz          Size vector for output
            %                       p1, p2, ... Parameters for the pdf
            %
            %                       V           Array size [3,sz] of rotation
            %                                   vectors. If sz starts with a leading
            %                                   singleton, this is suppressed e.g.
            %                                   if sz=[1,7] then size(V) = [3,7]
            %
            %                   EXAMPLE:
            %                       V = my_lorentzian_mosaic (sz, fwhh_deg)
            %                   and set
            %                       mosaic_pdf
            %
            %
            %   parameters      Parameters for the mosaic spread function above:
            %                   Single, non-cell array argument p1:
            %                       parameters = p1
            %
            %                   Single cell array argument p1:
            %                       parameters = {p1}   % to avoid ambiguity with general form
            %
            %                   General form:
            %                       parameters = {p1, p2,...}
            %
            %                   EXAMPLE For the function mosaic_lorentzian above, the
            %                   value of parameters is simply fwhh_deg:
            %                       >> mos = IX_mosaic (@my_lorentzian_mosaic, fwhh_deg)
            %
            %
            %
            % The default is a Gaussian mosaic spread defined by the full widdth
            % half height in degrees:
            %   - fwhh                      Isotropic Gaussian mosaic spread
            %                               There is no need to give
            %
            %   - [fwhh_x,fwhh_y,fwhh_z]    Mosaic with fwhh (deg) rotation about
            %                               each of the x,y,z axes
            %
            %   - (fwhh_array).^2 (size=[3x3]) Mosaic matrix that incorporates
            %                               correlations between the axes:
            %                               - diagonals are fwhh^2
            %                               - off-diagonal are corresponding
            %                                 cross-correlations
            %                               The matrix is just the covariance
            %                               matrix, multipied by log(256) so
            %                               that the elements are scaled to
            %                               refer to FWHH
            %
            %
            % Note: the default function is an isotropic gaussian mosaic spread.
            % Only the fwhh of the mosaic spread needs to be given in this case.
            % There is no need to specify the x and y axes for the


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_mosaic.loadobj(varargin{1});

            elseif nargin>0
                if nargin==1
                    val_out = check_mosaic_matrix (varargin{1});
                    obj.parameters = val_out;

                elseif nargin==2
                    obj.mosaic_pdf = varargin{1};
                    if ~iscell(varargin{2})
                        obj.parameters = varargin{2};
                    else
                        obj.parameters = varargin{2}(:)';
                    end
                elseif nargin==3 || nargin==4
                    obj.do_check_combo_arg = false;
                    obj.xaxis = varargin{1};
                    obj.yaxis = varargin{2};
                    obj.do_check_combo_arg = true;
                    obj = obj.check_combo_arg();

                    if nargin==3
                        val_out = check_mosaic_matrix (varargin{3});
                        obj.parameters = val_out;
                    end

                    if nargin==4
                        obj.mosaic_pdf = varargin{3};
                        if ~iscell(varargin{4})
                            obj.parameters = varargin{4};
                        else
                            obj.parameters = varargin{4}(:)';
                        end
                    end

                else
                    error('HERBERT:IX_mosaic:invalid_argument', ...
                        'Incorrect number of input arguments (%d)',nargin)
                end
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.

        function obj=set.xaxis(obj,val)
            if ~(isnumeric(val) && numel(val)==3 && ~all(val==0))
                error('HERBERT:IX_mosaic:invalid_argument', ...
                    '"xaxis" must be a three-vector')
            end
            obj.xaxis_=val(:)';
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.yaxis(obj,val)
            if ~(isnumeric(val) && numel(val)==3 && ~all(val==0))
                error('HERBERT:IX_mosaic:invalid_argument', ...
                    '"yaxis" must be a three-vector')
            end
            obj.yaxis_=val(:)';
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.mosaic_pdf(obj,val)
            if isscalar(val) && isa(val,'function_handle')
                obj.mosaic_pdf_ = val;
            else
                error('HERBERT:IX_mosaic:invalid_argument', ...
                    'Mosaic distribution function must be a function handle')
            end
        end
        function obj=set.mosaic_pdf_string(obj,val)
            if ~(isstring(val)||ischar(val))
                error('HERBERT:IX_mosaic:invalid_argument', ...
                    'Mosaic distribution function string must be a string convertable to a mosaic_pdf function handle. Its type is %s', ...
                    class(val))
            end
            obj.mosaic_pdf = str2func(val);
        end
        function obj=set.parameters(obj,val)
            obj.parameters_=val;
        end
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.xaxis(obj)
            val=obj.xaxis_;
        end

        function val=get.yaxis(obj)
            val=obj.yaxis_;
        end

        function val=get.mosaic_pdf(obj)
            val=obj.mosaic_pdf_;
        end

        function val=get.parameters(obj)
            val=obj.parameters_;
        end
        function val= get.mosaic_pdf_string(obj)
            val = func2str(obj.mosaic_pdf_);
        end
        %------------------------------------------------------------------
        function X = rand_rot_vect(obj,dis_size)
            % Get random rotation vectors in the xaxis-yaxis frame
            func = obj.mosaic_pdf_;
            if ~iscell(obj.parameters_)
                X = func(dis_size, obj.parameters_);
            else
                X = func(dis_size, obj.parameters_{:});
            end
        end
        % Determine if the mosaic corresponds to the default of no mosaic spread
        status = mosaic_crystal(obj)
        %------------------------------------------------------------------
    end
    %======================================================================
    methods
        % SERIALIZABLE INTERFACE
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end

        function flds = saveableFields(~)
            % Return cellarray of independent properties of the class
            %
            flds = {'xaxis','yaxis','mosaic_pdf_string','parameters'};
        end

        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.

            if norm(cross(obj.xaxis_,obj.yaxis_))/(norm(obj.xaxis_)*norm(obj.yaxis_)) < 1e-5
                error('HERBERT:IX_mosaic:invalid_argument', ...
                    '"xaxis=%s" and "yaxis=%s" are colinear, or almost colinear',...
                    disp2str(obj.xaxis_),disp2str(obj.yaxis_));
            end
        end
    end
    methods(Access=protected)
        %------------------------------------------------------------------
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            inputs = convert_old_struct_(obj,inputs);
        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = IX_mosaic();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end
    %======================================================================

end
