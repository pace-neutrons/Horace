classdef test_hdf_pix_group < TestCase
    %Unit tests to validate hdf_pix_group class
    %
    
    properties
    end
    
    methods
        function obj = test_hdf_pix_group(varargin)
            if nargin == 0
                class_name = 'test_hdf_pix_group';
            else
                class_name = varargin{1};
            end
            obj = obj@TestCase(class_name);
        end
        function close_fid(obj,fid,file_h,group_id)
            H5G.close(group_id);
            if ~isempty(file_h)
                H5G.close(fid);
                H5F.close(file_h);
            else
                H5F.close(fid);
            end
        end
        
        
        function test_read_write(obj)
            f_name = [tempname,'.nxsqw'];
            clob2 = onCleanup(@()delete(f_name));
            
            
            arr_size = 100000;
            pix_writer = hdf_pix_group(f_name,arr_size,16*1024,'-use_matlab');
            assertTrue(exist(f_name,'file')==2);
            pix_alloc_size = pix_writer.max_num_pixels;
            chunk_size     = pix_writer.chunk_size;
            assertEqual(chunk_size,16*1024);
            assertTrue(pix_alloc_size >= arr_size);
            
            data = ones(9,100);
            pos = [2,arr_size/2,arr_size-size(data,2)];
            pix_writer.write_pixels(pos(1),data);
            
            pix_writer.write_pixels(pos(2),2*data);
            
            pix_writer.write_pixels(pos(3),3*data);
            clear pix_writer;
            
            
            pix_reader = hdf_pix_group(f_name,'-use_matlab');
            assertEqual(chunk_size,pix_reader.chunk_size);
            assertEqual(pix_alloc_size,pix_reader.max_num_pixels);
            
            
            pix1 = pix_reader.read_pixels(pos(1),size(data,2));
            pix2 = pix_reader.read_pixels(pos(2),size(data,2));
            pix3 = pix_reader.read_pixels(pos(3),size(data,2));
            
            assertEqual(single(data),pix1);
            assertEqual(single(2*data),pix2);
            assertEqual(single(3*data),pix3);
            
            
            
            % check correct group created
            [fid,group_name,group_id,file_h,rec_version] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            
            [~,short_name] = fileparts(f_name);
            assertEqual(pix_reader.nxsqw_version,rec_version);
            assertEqual(group_name,['sqw_',short_name]);
            
            clear pix_reader;
            clear clob1;
            
            pix_reader = hdf_pix_group(f_name,'-use_matlab');
            pix3 = pix_reader.read_pixels(pos(3),size(data,2));
            pix2 = pix_reader.read_pixels(pos(2),size(data,2));
            pix1 = pix_reader.read_pixels(pos(1),size(data,2));
            
            
            
            assertEqual(single(data),pix1);
            assertEqual(single(2*data),pix2);
            assertEqual(single(3*data),pix3);
            
            delete(pix_reader);
            clear pix_reader;
            
            clear clob2;
        end
        %
        function test_missing_file(obj)
            f_name = [tempname,'.nxsqw'];
            
            
            clob2 = onCleanup(@()delete(f_name));
            
            f_missing = @()hdf_pix_group(f_name);
            % new file needs more than one argument for
            % creation
            assertExceptionThrown(f_missing,'HDF_PIX_GROUP:invalid_argument');
            
        end
        %
        function test_multiblock_read(obj)
            f_name = [tempname,'.nxsqw'];
            
            clob2 = onCleanup(@()delete(f_name));
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(f_name,arr_size,1024,'-use_matlab');
            assertTrue(exist(f_name,'file')==2);
            
            data = repmat(1:arr_size,9,1);
            pix_acc.write_pixels(1,data);
            
            pos = [10,100,400];
            npix = 10;
            [pix,completed] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(2,1:10),single(10:19));
            assertEqual(pix(9,11:20),single(100:109));
            assertEqual(pix(1,21:30),single(400:409));
            assertTrue(completed);
            
            pos = [10,2000,5000];
            npix =[1024,2048,1000];
            [pix,completed] = pix_acc.read_pixels(pos,npix);
            
            assertEqual(pix(3,1:1024),single(10:1033));
            %             assertEqual(numel(pos),2);
            %             assertEqual(numel(npix),2);
            assertTrue(completed);
            
            [pix,completed] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(1,1:1024),single(10:(9+1024)));
            assertEqual(pix(1,1025:1024+2048),single(2000:(1999+2048)));
            assertEqual(pix(1,3073:3072+1000),single(5000:(4999+1000)));
            assertTrue(completed);
            
            
            % single read operation as total size is smaller than the block
            % size
            pos = [10,1000,2000];
            npix =[128,256,256];
            [pix,completed] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(1,385:(384+256)),single(2000:(1999+256)));
            assertTrue(completed);
            
            clear pix_acc;
            
            clear clob2;
        end
        %
        function  test_mex_reader(obj)
            if isempty(which('hdf_mex_reader'))
                skipTest('The hdf mex reader was not found in the Matlab path.');
            end
            % use when mex code debuging only
            %clob0 = onCleanup(@()clear('mex'));
            
            f_name = [tempname,'.nxsqw'];
            clob1 = onCleanup(@()delete(f_name));
            
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(f_name,arr_size,1024,'-use_mex');
            
            assertTrue(exist(f_name,'file')==2);
            
            writer_clob = onCleanup(@()delete(pix_acc));
            
            data = repmat(1:arr_size,9,1);
            for i=1:9
                data(i,:) = data(i,:)*i;
            end
            pix_acc.write_pixels(1,data);
            
            
            
            pix_read = hdf_pix_group(f_name,'-use_mex');
            mex_reader_clob = onCleanup(@()delete(pix_read));
            
            assertEqual(uint64(pix_acc.max_num_pixels),pix_read.max_num_pixels);
            assertEqual(uint64(pix_acc.chunk_size),pix_read.chunk_size);
            assertEqual(uint64(pix_acc.cache_nslots),pix_read.cache_nslots);
            assertEqual(pix_acc.cache_size,pix_read.cache_size);
            assertEqual(pix_acc.nxsqw_version,pix_read.nxsqw_version);
            
            clear writer_clob;
            %-------------------------------------------------------------
            pos = 50;
            npix=5*1000;
            % test do nothing
            [pix_array,finished]=pix_read.read_pixels(pos,npix,0);
            assertVectorsAlmostEqual(size(pix_array),[9,0]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(0));
            assertEqual(pos0,uint64(0));
            
            % test reading part of a single pixels block.
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(0));
            assertEqual(pos0,uint64(2000));
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(1):(2000+pos(1)-1))));
            
            % Test subsequent read operation
            pos = [2,50,6000];
            npix =[10,5*1000,10];
            % new read operation from new array. read_op completed should
            % be forced to true to clear the cache from the previous read
            % operation.
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000,1);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(1));
            assertEqual(pos0,uint64(1990));
            
            assertElementsAlmostEqual(pix_array(:,1:10),single(data(:,pos(1):(npix(1)+pos(1)-1))));
            assertElementsAlmostEqual(pix_array(:,11:2000),single(data(:,pos(2):(1990+pos(2)-1))));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,uint64(1));
            assertEqual(pos0,uint64(3990));
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(2)+1990:(3990+pos(2)-1))));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,1020]);
            assertTrue(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,uint64(3));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1:1010),single(data(:,pos(2)+3990:(5000+pos(2)-1))));
            assertElementsAlmostEqual(pix_array(:,1011:1020),single(data(:,pos(3):(10+pos(3)-1))));
            
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048,4);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(2));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            %-------------------------------------------------------------
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            % new read operation forcefully starts from the beginning
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048,true);
            
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,uint64(2));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048);
            assertVectorsAlmostEqual(size(pix_array),[9,1000]);
            assertTrue(finished);
            
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,uint64(3));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1:1000),single(data(:,5000:5000+999)));
            
            % check limits
            [pix_array,finished]=pix_read.read_pixels([1,100000],[1,1],2048);
            assertTrue(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(2));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1),single(data(:,1)));
            assertElementsAlmostEqual(pix_array(:,2),single(data(:,100000)));
            
            % check partial buffer
            pos = [10,2000,5000];
            npix =[1024,1024,1000];
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(1));
            assertEqual(pos0,uint64(976));
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2000),single(data(:,2000:2000+975)));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            assertTrue(finished);
            assertVectorsAlmostEqual(size(pix_array),[9,1048]);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,uint64(3));
            assertEqual(pos0,uint64(0));
            assertElementsAlmostEqual(pix_array(:,1:48),single(data(:,2976:(2976+47))));
            assertElementsAlmostEqual(pix_array(:,49:1048),single(data(:,5000:(5000+999))))
            
            
            clear mex_reader_clob;
            clear clob1;
            clear clob0;
            
        end
        %
        function  test_matlab_multiblock_reader(obj)
            
            f_name = [tempname,'.nxsqw'];
            clob1 = onCleanup(@()delete(f_name));
            
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(f_name,arr_size,1024,'-use_matlab');
            
            assertTrue(exist(f_name,'file')==2);
            
            writer_clob = onCleanup(@()delete(pix_acc));
            
            data = repmat(1:arr_size,9,1);
            for i=1:9
                data(i,:) = data(i,:)*i;
            end
            pix_acc.write_pixels(1,data);
            
            
            
            pix_read = hdf_pix_group(f_name,'-use_matlab');
            mex_reader_clob = onCleanup(@()delete(pix_read));
            
            assertEqual(pix_acc.max_num_pixels,pix_read.max_num_pixels);
            assertEqual(pix_acc.chunk_size,pix_read.chunk_size);
            assertEqual(pix_acc.cache_nslots,pix_read.cache_nslots);
            assertEqual(pix_acc.cache_size,pix_read.cache_size);
            assertEqual(pix_acc.nxsqw_version,pix_read.nxsqw_version);
            
            clear writer_clob;
            %-------------------------------------------------------------
            pos = 50;
            npix=5*1000;
            % test do nothing
            [pix_array,finished]=pix_read.read_pixels(pos,npix,0);
            assertVectorsAlmostEqual(size(pix_array),[9,0]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,npix);
            assertEqual(pos0,pos);
            
            
            % test reading part of a single pixels block.
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,3000);
            assertEqual(pos0,2050);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(1):(2000+pos(1)-1))));
            
            % Test subsequent read operation
            pos = [2,50,6000];
            npix =[10,5*1000,10];
            % new read operation from new array. read_op completed should
            % be forced to true to clear the cache from the previous read
            % operation.
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000,1);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,[3010,10]);
            assertEqual(pos0,[2040,6000]);
            
            assertElementsAlmostEqual(pix_array(:,1:10),single(data(:,pos(1):(npix(1)+pos(1)-1))));
            assertElementsAlmostEqual(pix_array(:,11:2000),single(data(:,pos(2):(1990+pos(2)-1))));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,[1010,10]);
            assertEqual(pos0,[4040,6000]);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(2)+1990:(3990+pos(2)-1))));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,1020]);
            assertTrue(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertTrue(isempty(nblock0));
            assertTrue(isempty(pos0));
            assertElementsAlmostEqual(pix_array(:,1:1010),single(data(:,pos(2)+3990:(5000+pos(2)-1))));
            assertElementsAlmostEqual(pix_array(:,1011:1020),single(data(:,pos(3):(10+pos(3)-1))));
            
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048);
            %[pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048,4);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,1000);
            assertEqual(pos0,5000);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            %-------------------------------------------------------------
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            % new read operation forcefully starts from the beginning
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048,true);
            
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertEqual(nblock0,1000);
            assertEqual(pos0,5000);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2048);
            assertVectorsAlmostEqual(size(pix_array),[9,1000]);
            assertTrue(finished);
            
            [nblock0,pos0] = pix_read.get_read_info();
            
            assertTrue(isempty(nblock0));
            assertTrue(isempty(pos0));
            assertElementsAlmostEqual(pix_array(:,1:1000),single(data(:,5000:5000+999)));
            
            % check limits
            [pix_array,finished]=pix_read.read_pixels([1,100000],[1,1],2048);
            assertTrue(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertTrue(isempty(nblock0));
            assertTrue(isempty(pos0));
            assertElementsAlmostEqual(pix_array(:,1),single(data(:,1)));
            assertElementsAlmostEqual(pix_array(:,2),single(data(:,100000)));
            
            % check partial buffer
            pos = [10,2000,5000];
            npix =[1024,1024,1000];
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            % buffer modified to accept the whole block
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertFalse(finished);
            [nblock0,pos0] = pix_read.get_read_info();
            assertEqual(nblock0,1000);
            assertEqual(pos0,5000);
            
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            
            [pix_array,finished]=pix_read.read_pixels(pos,npix,2000);
            assertTrue(finished);
            assertVectorsAlmostEqual(size(pix_array),[9,1000]);
            [nblock0,pos0] = pix_read.get_read_info();
            assertTrue(isempty(nblock0));
            assertTrue(isempty(pos0));
            
            assertElementsAlmostEqual(pix_array(:,1:1000),single(data(:,5000:(5000+999))))
            
            
            clear mex_reader_clob;
            clear clob1;
            clear clob0;
            
        end
        
        function test_pix_ranges(obj)
            f_name = [tempname,'.nxsqw'];
            
            clob2 = onCleanup(@()delete(f_name));
            
            arr_size = 1000;
            pix_acc = hdf_pix_group(f_name,arr_size,1024);
            assertTrue(exist(f_name,'file')==2);
            
            assertEqual(pix_acc.pix_range,[inf(9,1),-inf(9,1)]);
            
            data = repmat(1:arr_size,9,1);
            pix_acc.write_pixels(1,data);
            assertEqual(pix_acc.pix_range,[ones(9,1),1000*ones(9,1)]);
            
            delete(pix_acc);
            
            pix_read = hdf_pix_group(f_name);
            assertEqual(pix_read.pix_range,[ones(9,1),1000*ones(9,1)]);
            delete(pix_read);
            
            clear clob2;
        end
    end
    
end

