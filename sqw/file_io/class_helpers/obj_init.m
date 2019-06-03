classdef obj_init
    % Class-holder of the initialization information for the classes responsible
    % for binary sqw files access.
    %
    % Used to accelerate and optimize the transfer of binary sqw file service information stored
    % in binary sqw file header from should_load method to a class initialization methods to avoid
    % repetitive reads and extractions of the same information from a file on disk.
    %
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
    %
    properties(Access=protected,Hidden=true)
        file_id_ = -1;
        num_dim_ = 'undefined';
    end
    properties(Dependent)
        % Matlab file identifier, referring to open binary sqw file.
        file_id
        % number of dimensions in the dnd image stored in the sqw file. 
        % Can change from 0 to 4.
        num_dim
    end
    
    methods
        function obj = obj_init(varargin)
            % constructor.
            %Usage:
            %>>obj = obj_init(); % returns empty object
            %
            %>>obj = obj_init(fid,numdim) % returns object containing initialization information
            % where:
            % fid - the Matlab file identifier for open sqw binary file
            % numdim - number of dimensions of the dnd image stored in the sqw binary file
            %
            if nargin==2
                if ~isnumeric(varargin{1}) || varargin{1} < 1
                    error('SQW_FILE_IO:invalid_argument',...
                        'obj_init::constructor: first argument of the constructor must contain open file_id')
                else
                    obj.file_id_ = varargin{1};
                end
                
                obj.num_dim_ = varargin{2};
                %
                % Verify inputs:
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

