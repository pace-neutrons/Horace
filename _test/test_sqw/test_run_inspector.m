classdef test_run_inspector< TestCase
    %
    % Validate sqw object replication
    %

    properties
        this_dir;
        sqw_source = 'test_sqw_file/sqw_4d.sqw'

        source_sqw4D;
        source_sqw2D;        
        source_sqw1D;                
    end

    methods
        function obj=test_run_inspector(name)
            if ~exist('name','var')
                name = 'test_run_inspector';
            end
            obj=obj@TestCase(name);
            obj.this_dir = fileparts(mfilename('fullpath'));
            [fp,fn,fe] = fileparts(obj.sqw_source);
            source_data = fullfile(fileparts(obj.this_dir),fp,[fn,fe]);
            obj.source_sqw4D = read_sqw(source_data);
            obj.source_sqw2D = cut(obj.source_sqw4D,[-0.2,0.2],[-0.2,0.2],[],[]);
            obj.source_sqw1D = cut(obj.source_sqw4D,[-0.2,0.2],[-0.2,0.2],[-0.2,0.2],[]);            

        end
        % tests
        function test_run_inspector_1D(obj)

        end
        function test_split(obj)
            n_pix = obj.source_sqw4D.npixels;
            w_spl = split(obj.source_sqw4D);

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).data.pix.run_idx);
                assertEqual(keys{1},id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);
        end
    end
end
