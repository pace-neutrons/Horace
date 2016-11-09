classdef test_const_blocks_map <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxliary methods, availble on this class
    %
    
    %
    properties
        test_folder;
    end
    methods(Static)
        function pos = modify_test_pos(pos_var)
            pos = pos_var.pos;
            pos.num_contrib_files_ = 4;
            sz = pos.detpar_pos_-pos.header_pos_;
            header_pos = zeros(1,4);
            header_inf = repmat(pos.header_pos_info_,1,4);
            for i=1:4
                header_pos(i)  = pos.header_pos_+(i-1)*sz;
                fn = fieldnames(pos.header_pos_info_);
                for j=1:numel(fn)
                    fld = fn{j};
                    header_inf(i).(fld) = pos.header_pos_info_.(fld)+(i-1)*sz;
                end
            end
            pos.header_pos_ = header_pos;
            pos.header_pos_info_ = header_inf;
            pos.detpar_pos_  = pos.detpar_pos_ + 3*sz;
        end
    end
    methods
        function obj = test_const_blocks_map(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
        end
        
        
        function obj=test_sqw_4head_block_map_construct(obj)
            
            pos = load('pos_to_test.mat');
            pos = obj.modify_test_pos(pos);
            
            
            bsc = const_blocks_map();
            bsc = bsc.init(pos);
            
            
            assertEqual(bsc.cblocks_map.Count,uint64(10));
            val1 = bsc.cblocks_map('dnd_data');
            assertEqual(val1,[3414;10000])
            assertTrue(bsc.cblocks_map.isKey('dnd_methadata'));
            
            val = bsc.cblocks_map('header');
            
            assertEqual(val,[147,691,1235,1779;536,536,536,536])
            assertEqual(val(2,1),val(2,2))
            assertEqual(val(2,3),val(2,4))


            must_fit = bsc.get_must_fit();
            assertEqual(must_fit.Count,uint64(6));

            bsc2 = const_blocks_map(pos);

            ok = bsc.check_equal_sizes(bsc2);
            assertTrue(ok);
        end
        
        
        
        function obj=test_sqw_2head_block_map_construct(obj)
            
            warning('off','SQW_FILE_IO:legacy_data');
            clob = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));
            samp = fullfile(obj.test_folder,...
                'test_sqw_read_write_v0_t.sqw');
            
            tob = sqw_formats_factory.instance().get_loader(samp);
            
            pos = tob.get_pos_info();
            
            bsc = const_blocks_map();
            bsc = bsc.init(pos);
            
            
            assertEqual(bsc.cblocks_map.Count,uint64(5));
            val1 = bsc.cblocks_map('dnd_data');
            assertEqual(val1,[677080;4096])
            assertFalse(bsc.cblocks_map.isKey('dnd_methadata'));
            
            val = bsc.cblocks_map('header');
            %valn = bsc.cblocks_map('$n_header');
            
            assertEqual(val(:,1),[152;336])
            assertEqual(val(:,2),[562;336])
            
            assertEqual(val(2,1),val(2,2))
            assertEqual(pos.header_pos_info_(1).efix_pos_,val(1,1));
            assertEqual(pos.header_pos_info_(2).efix_pos_,val(1,2));
            
            
        end
        
        function obj=test_sqw_block_map_construct(obj)
            
            samp = fullfile(obj.test_folder,...
                'test_sqw_file_read_write_v3_1.sqw');
            
            tob = sqw_formats_factory.instance().get_loader(samp);
            
            pos = tob.get_pos_info();
            
            bsc = const_blocks_map();
            bsc = bsc.init(pos);
            
            
            assertEqual(bsc.cblocks_map.Count,uint64(10));
            val1 = bsc.cblocks_map('dnd_data');
            assertEqual(val1(2),10000)
            val2 = bsc.cblocks_map('dnd_methadata');
            assertEqual(val2(2),304)
            assertEqual(val1(1),val2(1)+val2(2))
            
            val = bsc.cblocks_map('header');
            
            assertEqual(val,[147;536])
            
            
            
        end
        
        function obj=test_block_map_construct(obj)
            
            samp = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_d1d.sqw');
            
            tob = dnd_binfile_common_tester();
            tob = tob.init(samp);
            
            pos = tob.get_pos_info();
            
            bsc = const_blocks_map();
            bsc = bsc.init(pos);
            
            assertTrue(bsc.cblocks_map.isKey('dnd_methadata'))
            assertTrue(bsc.cblocks_map.isKey('dnd_data'))
            
            
            assertEqual(bsc.cblocks_map.Count,uint64(2));
            val1 = bsc.cblocks_map('dnd_data');
            assertEqual(val1(2),1296)
            val2 = bsc.cblocks_map('dnd_methadata');
            assertEqual(val2(2),528)
            assertEqual(val1(1),val2(1)+val2(2))

            must_fit = bsc.get_must_fit();
            assertEqual(must_fit.Count,uint64(2));
            
        end
        
    end
    
end

