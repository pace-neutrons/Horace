classdef test_upgrade_pix_pixrange< TestCase
    %
    % Validate if the update works
    %
    properties
        test_dir;
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_upgrade_pix_pixrange(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
            
            this.test_dir = fullfile(fileparts(mfilename('fullpath')));
        end
        
        % tests
        function obj = test_upgrade_v3_1_toV3_3(obj)
            test_source = fileparts(obj.test_dir);
            test_fname = 'test_cut_sqw_sym.sqw'; % v3.1 source test file
            source_file = fullfile(test_source,'test_sym_op',test_fname );
            test_file   = fullfile(tmp_dir(),test_fname);
            copyfile(source_file ,test_file);
            clob = onCleanup(@()delete(test_file));
            
            modify_pix_ranges(test_file)
            
            ld1 = faccess_sqw_v3_3();
            ld1 = ld1.init(test_file);
            
            ld0 = faccess_sqw_v3();
            ld0 = ld0.init(source_file);
            
            assertEqual(ld1.get_main_header('-keep_original'),ld0.get_main_header('-keep_original'));
            assertEqual(ld1.get_header(),ld0.get_header());
            d1 = ld1.get_data();
            pix1 = d1.pix;
            d1.pix = PixelData();
            d1.filepath = '';
            d2 = ld0.get_data();
            d2.filepath = '';
            pix2 = d2.pix;
            d2.pix = PixelData();
            assertEqual(d1,d2);
            assertEqual(ld1.get_img_db_range(),ld0.get_img_db_range());
            
            pix2.recalc_pix_range();
            
            assertEqual(ld1.get_pix_range(),pix2.pix_range);
            assertEqual(pix1.pix_range,pix2.pix_range);
            ld1.delete();
            ld0.delete();
        end
        
        function obj = test_upgrade_v2_toV3_3(obj)
            test_source = fileparts(obj.test_dir);
            test_fname = 'w3d_sqw.sqw'; % v2 source test file
            source_file = fullfile(test_source,'test_symmetrisation',test_fname );
            test_file   = fullfile(tmp_dir(),test_fname);
            copyfile(source_file ,test_file);
            clob = onCleanup(@()delete(test_file));
            
            modify_pix_ranges(test_file)
            
            ld1 = faccess_sqw_v3_3();
            ld1 = ld1.init(test_file);
            
            ld0 = faccess_sqw_v2();
            ld0 = ld0.init(source_file);
            
            assertEqual(ld1.get_main_header('-keep_original'),ld0.get_main_header('-keep_original'));
            assertEqual(ld1.get_header(),ld0.get_header());
            d1 = ld1.get_data();
            pix1 = d1.pix;
            d1.pix = PixelData();
            d1.filepath = '';
            d2 = ld0.get_data();
            d2.filepath = '';
            pix2 = d2.pix;
            d2.pix = PixelData();
            assertEqual(d1,d2);
            assertEqual(ld1.get_img_db_range(),ld0.get_img_db_range());
            
            pix2.recalc_pix_range();
            
            assertEqual(ld1.get_pix_range(),pix2.pix_range);
            assertEqual(pix1.pix_range,pix2.pix_range);
            
            ld1=ld1.delete();
            
            
            % forcefully set up new (incorrect) pixels range as image_range
            % and ensure it set it up.
            modify_pix_ranges(test_file,'use_urange');
            ld1 = ld1.init(test_file);
            assertEqual(ld1.get_pix_range(),ld0.get_img_db_range());
            ld1.delete();
        end
        %
    end
end
