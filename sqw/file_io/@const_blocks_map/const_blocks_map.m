classdef const_blocks_map
    % Class to support the map of the constant blocks in sqw/dnd file,
    % where const blocks are the blocks which can be overwritten.
    %
    %
    % $Revision: 1315 $ ($Date: 2016-11-03 14:36:26 +0000 (Thu, 03 Nov 2016) $)
    %
    properties(Access =protected)
        cblocks_map_=[];
    end
    
    properties(Dependent)
        cblocks_map;
    end
    properties(Constant,Access=private)
        % list of position fields which define boundareis of constant data
        % blocks
        block_names_ = {'main_header',...
            '$0_header','$n_header',... % virtual fields to transform to 'header' field on output
            'detpar',...
            'dnd_methadata','dnd_data',...
            'pix',...
            'instr_head','instrument',...
            'sample_head','sample'}
        block_positions_ = {...
            {{'main_head_pos_info_','nfiles_pos_'},'header_pos_'},... %main header
            {{'header_pos_info_','efix_pos_'},'detpar_pos_'},...      % the only one or last header
            {{'header_pos_info_','filename_pos_'},{'header_pos_info_','efix_pos_'}},...  % n-header
            {{'detpar_pos_info_','ndet_pos_'},'data_pos_'},...      % detpar
            {{'data_fields_locations_','alatt_pos_'},'s_pos_'},...  % methadata block positions
            {'s_pos_','dnd_eof_pos_'},...                           % data block positions
            {'urange_pos_','eof_pix_pos_'},...                       % pix block position
            {'instrument_head_pos_','instrument_pos_'},... % instrument header | -- these four are not
            {'instrument_pos_','sample_head_pos_'},...     % instrument block  |
            {'sample_head_pos_','sample_pos_'},...         % sample header     | srcicly necessary, but provided
            {'sample_pos_','instr_sample_end_pos_'},...    % sample block      |
            };                                             %                   | for consistency
        const_block_map_ = containers.Map(const_blocks_map.block_names_,...
            const_blocks_map.block_positions_);
        % number of fields which must fit if upgrade is possible
        nfld_must_fit_ =logical([1,1,1,1,1,1,0,0,0,0])
        
    end
    
    methods
        %
        function obj = const_blocks_map(varargin)
        % constructor. If provided with parameters, 
        % calls init method on parameters.
        %
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function mp = get.cblocks_map(obj)
            mp = obj.cblocks_map_;
        end
        %
        function mp = get_must_fit(obj)
            % function returns only the part of the map which must fit for upgrade to
            % be possible
            if isempty(obj.cblocks_map_)
                mp = containers.Map();
            else
                nonf = obj.block_names_(~obj.nfld_must_fit_);
                mp = remove(obj.cblocks_map_,nonf);
            end
        end
        % initialize block map using blocks position as input
        obj = init(obj,pos_info);
        % check
        ok = check_equal_size(obj,other_obj)
    end
    
end

