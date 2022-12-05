classdef obj_init
    % Class-holder of the initialization information for the classes
    % responsible for binary sqw files access.
    %
    % Used to accelerate and optimize the transfer of binary sqw file
    % service information stored in binary sqw file header
    % from should_load method to a class initialization methods
    % to avoid repetitive reads and extractions of the same information
    % from a file on disk.
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
        function obj = obj_init(fid,numdim)
            % constructor.
            %Usage:
            %>>obj = obj_init(); % returns empty object
            %
            %>>obj = obj_init(fid,numdim) % returns object containing initialization information
            % where:
            % fid - the Matlab file identifier for open sqw binary file
            % numdim - number of dimensions of the dnd image stored in the sqw binary file
            %
            if nargin == 0
                return;
            end
            obj.file_id = fid;
            obj.num_dim = numdim;
        end
        function is = defined(obj)
            is = obj.file_id_ > 0 && isnumeric(obj.num_dim_);
        end
        %
        function id = get.file_id(obj)
            id  = obj.file_id_;
        end
        function obj = set.file_id(obj,fid)
            if ~isnumeric(fid) || fid<1
                error('HORACE:sqw_file_interface:invalid_argument',...
                    'First argument of the constructor must contain open file_id. It is: %s', ...
                    disp2str(fid))
            end
            obj.file_id_ = fid;
        end
        function nd = get.num_dim(obj)
            nd = obj.num_dim_;
        end
        function obj= set.num_dim(obj,numdim)
            if isempty(numdim) || (ischar(numdim)&&strcmp(numdim,'undefined'))
                obj.num_dim_ = 'undefined';
                return
            end
            if ~(isnumeric(numdim)&&(numdim>=0 && numdim <=4))
                error('HORACE:sqw_file_interface:invalid_argument',...
                    'Second argument of the constructor has to be a number of dimensions in range [0-4] or word "undefined". It is: %s',...
                    disp2str(numdim))
            end
            obj.num_dim_ = numdim;
        end
    end

end


