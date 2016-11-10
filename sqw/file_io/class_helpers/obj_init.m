classdef obj_init
    % Small class used as holder for faccess classes initialization properties;
    %
    %   Detailed explanation goes here
    
    properties(Access=protected)
        file_id_ = -1;
        num_dim_ = -1;
    end
    properties(Dependent)
        file_id
        num_dim
    end
    
    methods
        function obj = obj_init(varargin)
            % constructor:
            %Usage:
            %>>obj = obj_init(); % empty object
            %>>obj = obj_init(fid,numdim) % contains initialization information
            if nargin==2
                if ~isnumeric(varargin{1}) || varargin{1} < 1
                    error('SQW_FILE_IO:invalid_argument',...
                        'obj_init::constructor: first argument of the constructor must contain open file_id')
                else
                    obj.file_id_ = varargin{1};
                end
                %
                obj.num_dim_ = varargin{2};
                %
                if ~(ischar(obj.num_dim_) || isnumeric(obj.num_dim_))
                    error('SQW_FILE_IO:invalid_argument',...
                        'obj_init::constructor: second argument of the constructor has to be a number of dimensions or word "undefined"')
                end
                if ischar(obj.num_dim_)
                    if ~strcmp(obj.num_dim_,'undefined')
                        error('SQW_FILE_IO:invalid_argument',...
                            'obj_init::constructor: second argument of the constructor has to be a number of dimensions or word "undefined"')
                    end
                else
                    obj.num_dim_ = double(obj.num_dim_);
                    if obj.num_dim_<0 || obj.num_dim_>4
                        error('SQW_FILE_IO:invalid_argument',...
                            'obj_init second argument is number of dimensions, which can change from 0 to 4 but get: %d ',...
                            obj.num_dim_)
                    end
                end
            else
                if nargin~=0
                    error('SQW_FILE_IO:invalid_argument',...
                        'obj_init::constructor: must be called with 2 or no arguments')
                end
            end
        end
        %
        function id = get.file_id(obj)
            id  = obj.file_id_;
        end
        function nd = get.num_dim(obj)
            nd = obj.num_dim_;
        end
    end
    
end

