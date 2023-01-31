classdef dnd_data < serializable
    %DND_DATA class contains N-D data arrays, describing DND image stored in
    % dnd object and indended for providing specific format of storing these
    % data in horace binary files.
    %
    properties(Access=protected)
        sig_;
        err_;
        npix_;
    end

    properties(Dependent)
        dimensions  % number of dimensions in dnd data arrays
        data_size;  % the result of size() operation applied to a dnd data
        %           % array
        sig;        % signal array (s in dnd object)
        err;        % error array  (e in dnd object
        npix;       % npix array   (npix in dnd object)
    end

    methods
        function obj = dnd_data(varargin)
            %DND_DATA Construct an instance of this class
            if nargin == 0
                return;
            end
            dnd_obj = varargin{1};
            if isa(dnd_obj,'DnDBase')
                obj.do_check_combo_arg = false;
                obj.sig = dnd_obj.s;
                obj.err = dnd_obj.e;
                obj.npix= dnd_obj.npix;
                obj.do_check_combo_arg = true;
                obj = obj.check_combo_arg();
            else
                flds = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:dnd_data:invalid_argument',...
                        ' Class constructor has been invoked with non-recognized parameters: %s',...
                        disp2str(remains));
                end
            end
        end
        %------------------------------------------------------------------
        function nd = get.dimensions(obj)
            nd = numel(size(obj.sig_));
            if nd == 1
                nd = 2; % Matlab arrays are always 2-dimensional
            end
        end
        function sz = get.data_size(obj)
            sz = size(obj.sig_);
        end

        function val = get.sig(obj)
            val = obj.sig_;
        end
        function obj = set.sig(obj, s)
            obj = set_senpix(obj,s,'sig');
        end
        %
        function val = get.err(obj)
            val = obj.err_;
        end
        function obj = set.err(obj, e)
            if any(e(:)<0)
                error('HORACE:dnd_data:invalid_argument',...
                    'errors values can not be negative')
            end
            obj = set_senpix(obj,e,'err');
        end
        %
        function val = get.npix(obj)
            val = obj.npix_;
        end
        function obj = set.npix(obj, npix)
            if any(npix(:)<0)
                error('HORACE:dnd_data:invalid_argument',...
                    'npix values can not be negative')
            end
            obj = set_senpix(obj,npix,'npix');
        end

    end
    methods(Access=protected)
        function obj = set_senpix(obj,val,field)
            % set signal error or npix value to a class field
            if ~isnumeric(val)
                error('HORACE:dnd_data:invalid_argument',...
                    'input %s must be numeric array',field)
            end
            obj.([field,'_']) = val;
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained dnd object. Return the result of the check and the
            % reason for failure.
            %
            sz = size(obj.sig_);
            if any(sz ~= size(obj.err_))
                error('HORACE:dnd_data:invalid_argument', ...
                    'size of signal array: [%s] different from size of error array: [%s]', ...
                    num2str(sz),num2str(size(obj.err_)));
            end

            if any(sz ~= size(obj.npix_))
                error('HORACE:DnDBase:invalid_argument', ...
                    'size of npix array: [%s] different from sizes of signal and error arrays: [%s]', ...
                    num2str(sz),num2str(size(obj.npix_)))
            end
        end

        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            % Return cellarray of public property names, which fully define
            % the state of a serializable object, so when the field values are
            % provided, the object can be fully restored from these values.
            %
            flds = {'sig','err','npix'};
        end
    end
end