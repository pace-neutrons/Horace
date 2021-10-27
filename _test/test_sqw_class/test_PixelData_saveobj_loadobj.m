classdef test_PixelData_saveobj_loadobj < TestCase & common_sqw_class_state_holder
    
    properties
        data_folder;
    end
    
    
    methods (Access = private)
        
        function [pix_data,pix_range] = get_random_pix_data_(~, rows)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, rows);
            pix_range = [min(data(1:4,:),[],2),max(data(1:4,:),[],2)]';
            pix_data = PixelData(data);
            
        end
        function ref_range = get_ref_range(~,data)
            ref_range = [min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end
        
    end
    
    methods
        
        function obj = test_PixelData_saveobj_loadobj(~)
            obj = obj@TestCase('test_PixelData_saveobj_loadobj');
            obj.data_folder = fullfile(fileparts(mfilename('fullpath')),'data');
        end
        function test_load_save_modern_format_array(obj)
            data = obj.get_random_pix_data_(100);
            pix1 = PixelData(data);
            data = obj.get_random_pix_data_(120);
            pix2 = PixelData(data);
            pix = [pix1,pix2];
            
            test_file = fullfile(tmp_dir,'test_load_save_pix.mat');
            clob = onCleanup(@()delete(test_file));
            save(test_file,'pix');
            
            ds = load(test_file);
            assertEqual(size(ds.pix),size(pix));
            assertEqual(ds.pix(1),pix(1));
            assertEqual(ds.pix(2),pix(2));
        end
        
        function test_load_save_modern_format(obj)
            data = obj.get_random_pix_data_(100);
            pix1 = PixelData(data);
            test_file = fullfile(tmp_dir,'test_load_save_pix.mat');
            clob = onCleanup(@()delete(test_file));
            save(test_file,'pix1');
            
            ds = load(test_file);
            assertEqual(ds.pix1,pix1);
        end
        function test_load_sqw_v3_5_0(obj)
            data = fullfile(obj.data_folder,'sqw_v3_5_0_collection.mat');
            %           profile on
            ds = load(data);
            %            profile off
            %            profile viewer
            assertTrue(isfield(ds,'cut_list'));
            ds = ds.cut_list;
            assertTrue(isa(ds,'sqw'));
            assertEqual(numel(ds),4);
            ds = ds(1);
            pix = ds.data.pix;
            assertTrue(isa(pix,'PixelData'))
            assertEqual(pix.num_pixels,9363)
        end
        %
        function test_from_saveobj_loadobj_array(obj)
            data = obj.get_random_pix_data_(100);
            pix1 = PixelData(data);
            data = obj.get_random_pix_data_(200);
            pix2 = PixelData(data);
            data = obj.get_random_pix_data_(150);
            pix3 = PixelData(data);
            data = obj.get_random_pix_data_(120);
            pix4 = PixelData(data);
            pix = [pix1,pix2;pix3,pix4];
            
            pic_strc = saveobj(pix);
            
            rec_pix = PixelData.loadobj(pic_strc);
            
            assertEqual(pix(1),rec_pix(1));
            assertEqual(pix(2),rec_pix(2));
            assertEqual(pix(3),rec_pix(3));
            assertEqual(pix(4),rec_pix(4));
        end
        %
        function test_to_struct_from_struct_array(obj)
            data = obj.get_random_pix_data_(100);
            pix1 = PixelData(data);
            data = obj.get_random_pix_data_(200);
            pix2 = PixelData(data);
            data = obj.get_random_pix_data_(150);
            pix3 = PixelData(data);
            data = obj.get_random_pix_data_(120);
            pix4 = PixelData(data);
            pix = [pix1,pix2;pix3,pix4];
            
            pic_strc = struct(pix);
            
            rec_pix = PixelData(pic_strc);
            
            assertEqual(pix(1),rec_pix(1));
            assertEqual(pix(2),rec_pix(2));
            assertEqual(pix(3),rec_pix(3));
            assertEqual(pix(4),rec_pix(4));
        end
        function test_saveobj_loadobj(obj)
            [data,pix_range] = obj.get_random_pix_data_(100);
            pix = PixelData(data);
            assertEqual(pix.num_pixels,100);
            assertEqual(pix.pix_range,pix_range);
            
            pic_strc = saveobj(pix);
            rec_pix = PixelData.loadobj(pic_strc);
            
            assertEqual(pix,rec_pix);
        end
        
        function test_to_struct_from_struct(obj)
            [data,pix_range] = obj.get_random_pix_data_(100);
            pix = PixelData(data);
            assertEqual(pix.num_pixels,100);
            assertEqual(pix.pix_range,pix_range);
            
            pic_strc = struct(pix);
            
            rec_pix = PixelData(pic_strc);
            
            assertEqual(pix,rec_pix);
        end
        
        
    end    
end
