classdef test_sqw_reader< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        sample_dir;
        sample_file;
        positions
        npixtot
        test_dir
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_sqw_reader(name)
            this=this@TestCase(name);
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w3d_sqw.sqw');
            fid = fopen(this.sample_file,'rb');
            if fid<1
                error('Can not open sample file %s',this.sample_file)
            end
            cleanup_obj=onCleanup(@()fclose(fid ));
            theSqw = sqw();
            [mess,main_header,header,det_tmp,datahdr,this.positions,npixtot,data_type,file_format,current_format] = get_sqw (theSqw,fid,'-h');
            if ~isempty(mess)
                error('Can not read sample file %s header, error: %s',this.sample_file,mess)
            end
            this.npixtot = npixtot;
            this.test_dir = tempdir;
            
        end
        
        % tests
        function this = test_reader_npix_in_cash(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4; % s and e written single precision! Stupid
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            
            sr =  sqw_reader(this.sample_file,npix_start_pos,n_bin,pix_start_pos,10);
            cleanup_obj=onCleanup(@()sr.delete());
            
            
            [pix_num,npix] = sr.get_npix_for_bin(1);
            assertEqual(double(pix_num),1);
            assertEqual(double(npix),3);
            [pix_num,npix] = sr.get_npix_for_bin(2);
            assertEqual(double(pix_num),4);
            assertEqual(double(npix),3);
            
            [pix_num,npix] = sr.get_npix_for_bin(7);
            assertEqual(double(pix_num),18);
            assertEqual(double(npix),1);
            
            
            [pix_num,npix] = sr.get_npix_for_bin(1);
            assertEqual(double(npix),3);
            assertEqual(double(pix_num),1);
            % check end of nbin buffer
            [pix_num,npix] = sr.get_npix_for_bin(4096);
            assertEqual(double(npix) ,6);
            assertEqual(double(pix_num),7887);
            % here pix should be retrieved from the buffer
            [pix_num,npix] = sr.get_npix_for_bin(1);
            assertEqual(double(pix_num),1);
            assertEqual(double(npix),3);
            % Gradual bin buffer advance
            [pix_num,npix] = sr.get_npix_for_bin(4097);
            assertEqual(double(npix) ,2);
            assertEqual(double(pix_num),7887+6);
            
            [pix_num,npix] = sr.get_npix_for_bin(8096);
            assertEqual(double(npix) ,0);
            assertEqual(double(pix_num),14159);
            
            [pix_num,npix] = sr.get_npix_for_bin(8097);
            assertEqual(double(npix) ,0);
            assertEqual(double(pix_num),14159);
            
        end
        function this=test_reader_npix_cash_miss(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            
            sr =  sqw_reader(this.sample_file,npix_start_pos,n_bin,pix_start_pos,5);
            cleanup_obj=onCleanup(@()sr.delete());
            
            
            % should clear bin buffer
            [pix_num,npix] = sr.get_npix_for_bin(8096);
            assertEqual(npix ,int64(0));
            assertEqual(double(pix_num),14159);
            % check buf end
            [pix_num,npix] = sr.get_npix_for_bin(8192);
            assertEqual(double(npix) ,0);
            assertEqual(double(pix_num),14159);
            
            % should clear bin buffer and start again
            [pix_num,npix] = sr.get_npix_for_bin(7);
            assertEqual(double(pix_num),18);
            assertEqual(double(npix),1);
            
            % should take data from bin buffer
            [pix_num,npix] = sr.get_npix_for_bin(4096);
            assertEqual(double(npix) ,6);
            assertEqual(double(pix_num),7887);
            
            % check end of the buffer
            nbins = sr.nbins;
            [pix_num,npix] = sr.get_npix_for_bin(nbins-1);
            assertEqual(double(npix) ,0);
            assertEqual(double(pix_num),1164180+1);
            [pix_num,npix] = sr.get_npix_for_bin(nbins);
            assertEqual(this.npixtot,double(pix_num+npix-1));
            
        end
        function this=test_reader_npix_cash_miss_simple(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            
            sr =  sqw_reader(this.sample_file,npix_start_pos,n_bin,pix_start_pos,5);
            cleanup_obj=onCleanup(@()sr.delete());
            
            nbins = sr.nbins;
            [pix_num,npix] = sr.get_npix_for_bin(nbins-1);
            assertEqual(npix ,int64(0));
            assertEqual(double(pix_num),1164180+1);
            [pix_num,npix] = sr.get_npix_for_bin(nbins);
            assertEqual(this.npixtot,double(pix_num+npix-1));
        end
        function this = test_read_pixels(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            the_sqw = read_sqw(this.sample_file);
            
            pns = reshape(the_sqw.data.npix,numel(the_sqw.data.npix),1);
            pps  = [0;cumsum(pns)];
            
            sr =  sqw_reader(this.sample_file,npix_start_pos,n_bin,pix_start_pos,'');
            cleanup_obj=onCleanup(@()sr.delete());
            
            f = @()(sr.get_pix_for_bin(0));
            assertExceptionThrown(f,'SQW_READER:get_npix_for_bin');
            
            f = @()(sr.get_pix_for_bin(n_bin+1));
            assertExceptionThrown(f,'SQW_READER:get_npix_for_bin');
            
            
            pix1 = sr.get_pix_for_bin(1);
            assertEqual(size(pix1),[9,3]);
            % this now should work from cash only
            [pix_num,npix] = sr.get_npix_for_bin(1);
            assertEqual(double(pix_num),1);
            assertEqual(double(npix),3);
            
            pix_info = the_sqw.data.pix(:,pps(1)+1:pps(1)+pns(1));
            assertEqual(single(pix_info),pix1);
            
            % end of pixel buffer
            pix2 = sr.get_pix_for_bin(2207);
            assertEqual(size(pix2),[9,2]);
            [pix_num,npix] = sr.get_npix_for_bin(2207);
            assertEqual(double(pix_num),4095);
            assertEqual(double(npix),2);
            
            pix_info = the_sqw.data.pix(:,pps(2207)+1:pps(2207)+pns(2207));
            assertEqual(single(pix_info),pix2);
            
            
            %
            pix3 = sr.get_pix_for_bin(4096);
            [pix_num,npix] = sr.get_npix_for_bin(4096);
            assertEqual(size(pix3),double([9,npix]));
            assertEqual(double(pix_num),7887);
            assertEqual(double(npix),6);
            
            pix_info = the_sqw.data.pix(:,pps(4096)+1:pps(4096)+pns(4096));
            assertEqual(single(pix_info),pix3);
            
            
            pix4 = sr.get_pix_for_bin(4097);
            [pix_num,npix] = sr.get_npix_for_bin(4097);
            assertEqual(size(pix4),double([9,npix]));
            assertEqual(double(pix_num),(7887+6));
            assertEqual(double(npix) ,(2));
            
            pix_info = the_sqw.data.pix(:,pps(4097)+1:pps(4097)+pns(4097));
            assertEqual(single(pix_info),pix4);
            
            
            pix4a = sr.get_pix_for_bin(8192);
            [pix_num,npix] = sr.get_npix_for_bin(8192);
            assertEqual(size(pix4a),[0,0]);
            assertEqual(double(npix) ,(0));
            assertEqual(double(pix_num),(14159));
            pix4a = sr.get_pix_for_bin(8193);
            [pix_num,npix] = sr.get_npix_for_bin(8193);
            assertEqual(size(pix4a),[0,0]);
            assertEqual(double(npix) ,(0));
            assertEqual(double(pix_num),(14159));
            
            
            nbins = sr.nbins;
            pix5 = sr.get_pix_for_bin(nbins);
            [pix_num,npix] = sr.get_npix_for_bin(nbins);
            assertEqual(size(pix5),[0,0]);
            assertEqual(double(npix) ,(0));
            assertEqual(this.npixtot,double(pix_num+npix-1));
            
            %profile on
            t0= tic;
            for i=1:100:nbins
                pix = sr.get_pix_for_bin(i);
                
                [pix_num,npix] = sr.get_npix_for_bin(i);
                if npix > 0
                    assertEqual(size(pix),double([9,npix]));
                    assertEqual(double(pix_num),(pps(i)+1));
                    pix_info = the_sqw.data.pix(:,pps(i)+1:pps(i)+pns(i));
                    assertEqual(single(pix_info),pix);
                end
            end
            t1=toc(t0);
            disp([' Time to process ',num2str(nbins/100),' containing ',...
                num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            %profile off
            %profile viewer
        end
        function this = test_read_pix_buf_mex(this)
            use_mex = get(hor_config,'use_mex');
            if ~use_mex
                return;
            end
            %
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            the_sqw = read_sqw(this.sample_file);
            
            pns = reshape(the_sqw.data.npix,numel(the_sqw.data.npix),1);
            pps  = [0;cumsum(pns)];
            log_level = get(hor_config,'log_level');
            
            
            in_file_par = {struct('file_name',this.sample_file,...
                'npix_start_pos',npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            params = [n_bin,1,100,log_level,false,false,100,64];
            dummy_out_file_par = struct('file_name','dummy_out','npix_start_pos',0,'pix_start_pos',1000,'file_id',0);
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,dummy_out_file_par,params);
            
            assertEqual(npix(1:43),uint64(pns(1:43)));
            
            assertEqual(pix_info(1),uint64(99))
            assertEqual(pix_info(2),uint64(43))
            assertEqual(pix_data,single(the_sqw.data.pix(:,1:99)))
            %cleanup_obj=onCleanup(@()sr.delete());
            
            params = [n_bin,1,this.npixtot,log_level,false,false,100,64];
            t0= tic;
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,dummy_out_file_par,params);
            t1=toc(t0);
            if log_level >1
                disp([' Time to process ',num2str(n_bin),' cells containing ',...
                    num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            end
            
            assertEqual(npix,uint64(pns));
            assertEqual(pix_info(1),uint64(this.npixtot))
            assertEqual(pix_info(2),uint64(n_bin))
            
            
            assertEqual(pix_data(:,1:2248),single(the_sqw.data.pix(:,1:2248)))
            
            assertEqual(pix_data(:,4095),single(the_sqw.data.pix(:,4095)))
            assertEqual(pix_data(:,4096),single(the_sqw.data.pix(:,4096)))
            assertEqual(pix_data(:,4097),single(the_sqw.data.pix(:,4097)))
            
            assertEqual(pix_data(:,7892),single(the_sqw.data.pix(:,7892)))
            assertEqual(pix_data(:,7893),single(the_sqw.data.pix(:,7893)))
            assertEqual(pix_data,single(the_sqw.data.pix))
            
        end
        %
        function this = test_rewrite_pixarray_mex(this)
            use_mex = get(hor_config,'use_mex');
            if ~use_mex
                return;
            end
            %
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            log_level = get(hor_config,'log_level');
            
            file_par = {struct('file_name',this.sample_file,'npix_start_pos',...
                npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            params = [n_bin,1,1000000,log_level,false,false,100,4096];
            out_file = fullfile(this.test_dir,'rewrite_pixarray_mex_sqw_rez.sqw');
            cleanup_obj=onCleanup(@()delete(out_file));
            
            out_file_par = struct('file_name',out_file,'npix_start_pos',0,...
                'pix_start_pos',0,'file_id',0);
            t0= tic;
            combine_sqw(file_par,out_file_par,params);
            t1=toc(t0);
            if log_level>1
                disp([' Time to process ',num2str(n_bin),' cells containing ',...
                    num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            end
            assertTrue(exist(out_file,'file')==2);
            
            fid = fopen(out_file,'r');
            pix = fread(fid,[9,this.npixtot],'float32');
            fclose(fid);
            %
            t0= tic;
            the_sqw = read_sqw(this.sample_file);
            t1=toc(t0);
            if log_level >1
                disp([' Direct read of file with ',num2str(n_bin),' cells containing ',...
                    num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            end
            assertEqual(pix(:,999992),the_sqw.data.pix(:,999992))
            assertEqual(pix(:,999993),the_sqw.data.pix(:,999993))
            assertEqual(pix,the_sqw.data.pix);
        end
        %
        function this=test_combine_two(this)
            [use_mex,thread_mode] = get(hor_config,'use_mex_for_combine','mex_combine_thread_mode');
            if ~use_mex
                return;
            end
            infiles = {fullfile(this.sample_dir,'w2d_qe_sqw.sqw'),fullfile(this.sample_dir,'w2d_qe_sqw.sqw')};
            outfile = fullfile(this.test_dir,'test_combine_two_sqw.sqw');
            cleanup_obj=onCleanup(@()delete(outfile));
            cleanup1  =onCleanup(@()set(hor_config,'mex_combine_thread_mode',thread_mode));
            
            set(hor_config,'mex_combine_thread_mode',0);
            dummy = sqw();
            write_nsqw_to_sqw (dummy, infiles, outfile,'allow_equal_headers');
            
            
            old_sqw = read_sqw(infiles{1});
            new_sqw = read_sqw(outfile);
            
            
            assertEqual(size(old_sqw.data.npix),size(new_sqw.data.npix));
            assertEqual(2*old_sqw.data.npix,new_sqw.data.npix);
            old_pix_size = size(old_sqw.data.pix);
            assertEqual(size(new_sqw.data.pix),[old_pix_size(1),2*old_pix_size(2)] );
            
        end
        
        function this=test_mex_nomex(this)
            use_mex = get(hor_config,'use_mex_for_combine');
            if ~use_mex
                return;
            end
            dummy = sqw();
            infiles = {fullfile(this.sample_dir,'w2d_qe_sqw.sqw'),fullfile(this.sample_dir,'w2d_qe_sqw.sqw')};
            
            outfile_nom = fullfile(this.test_dir,'test_combine_two_sqw_nomex.sqw');
            cleanup_obj1=onCleanup(@()delete(outfile_nom));
            cleanup_obj2=onCleanup(@()set(hor_config,'use_mex',1));
            outfile_mex = fullfile(this.test_dir,'test_combine_two_sqw_mex.sqw');
            cleanup_obj=onCleanup(@()delete(outfile_mex));
            
            
            set(hor_config,'mex_combine_thread_mode',-1);
            t0= tic;
            write_nsqw_to_sqw (dummy, infiles, outfile_nom,'allow_equal_headers');
            t2=toc(t0);
            
            % set single threading excecution
            set(hor_config,'mex_combine_thread_mode',0);
            t0= tic;
            write_nsqw_to_sqw (dummy, infiles, outfile_mex,'allow_equal_headers');
            t1=toc(t0);
            
            mex_sqw = read_sqw(outfile_mex);
            
            
            
            if get(hor_config,'log_level') >1
                disp([' Combining two files using mex  takes ',num2str(t1),'sec'])
                disp([' Combining two files with nomex takes ',num2str(t2),'sec'])
            end
            
            
            nomex_sqw = read_sqw(outfile_nom);
            assertEqual(mex_sqw.data.npix,nomex_sqw.data.npix);
            assertEqual(mex_sqw.data.pix,nomex_sqw.data.pix);
            
        end
        
        function this=test_large_bins(this)
            use_mex = get(hor_config,'use_mex_for_combine');
            if ~use_mex
                return;
            end
            
            proj = projection();
            cs=cut_sqw(this.sample_file,proj,[-1,1],[-1,1],[-1,1],[-1,101]);
            test_file = fullfile(this.test_dir,'test_large_bins_sqw.sqw');
            cleanup_obj1=onCleanup(@()delete(test_file));
            
            save(cs,test_file);
            
            anSQW = sqw();
            fid = fopen(test_file,'rb');
            if fid<1
                error('Can not open test file %s',test_file)
            end
            %cleanup_obj2=onCleanup(@()fclose(fid ));
            
            [mess,main_header,header,det_tmp,datahdr,pos,npix_tot,data_type,file_format,current_format] = get_sqw (anSQW,fid,'-h');
            fclose(fid);
            
            npix_start_pos =pos.npix;  % start of npix field
            pix_start_pos  =pos.pix;   % start of pix field
            
            
            params = [1,1,10000000,2,false,false,100,4096];
            in_file_par = {struct('file_name',test_file,'npix_start_pos',npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            out_file_par = struct('file_name','dummy_out','npix_start_pos',0,'pix_start_pos',1000,'file_id',0);
            
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,out_file_par,params);
            assertEqual(npix(1),pix_info(1));
            assertEqual(double(pix_info(1)),npix_tot)
            assertEqual(double(pix_info(2)),1)
            
            assertEqual(pix_data(:,1:npix_tot),single(cs.data.pix));
            
        end
        function this=test_mex_nomex_multi(this)
            use_mex = get(hor_config,'use_mex_for_combine');
            if ~use_mex
                return;
            end
            dummy = sqw();
            infiles = {fullfile(this.sample_dir,'w2d_qe_sqw.sqw'),fullfile(this.sample_dir,'w2d_qe_sqw.sqw')};
            
            outfile_nom = fullfile(this.test_dir,'test_combine_two_sqw_nomex.sqw');
            cleanup_obj1=onCleanup(@()delete(outfile_nom));
            cleanup_obj2=onCleanup(@()set(hor_config,'use_mex',1));
            outfile_mex = fullfile(this.test_dir,'test_combine_two_sqw_mex.sqw');
            cleanup_obj=onCleanup(@()delete(outfile_mex));
            
            
            set(hor_config,'use_mex_for_combine',false);
            t0= tic;
            write_nsqw_to_sqw (dummy, infiles, outfile_nom,'allow_equal_headers');
            t2=toc(t0);
            
            
            set(hor_config,'mex_combine_thread_mode',1);
            t0= tic;
            write_nsqw_to_sqw (dummy, infiles, outfile_mex,'allow_equal_headers');
            t1=toc(t0);
            
            mex_sqw = read_sqw(outfile_mex);
            
            
            
            if get(hor_config,'log_level') >1
                disp([' Combining two files using mex  takes ',num2str(t1),'sec'])
                disp([' Combining two files with nomex takes ',num2str(t2),'sec'])
            end
            
            
            nomex_sqw = read_sqw(outfile_nom);
            assertEqual(mex_sqw.data.npix,nomex_sqw.data.npix);
            assertEqual(mex_sqw.data.pix,nomex_sqw.data.pix);
            
        end
        
        
        function this=test_large_bins_multi(this)
            use_mex = get(hor_config,'use_mex');
            if ~use_mex
                return;
            end
            
            proj = projection();
            cs=cut_sqw(this.sample_file,proj,[-1,1],[-1,1],[-1,1],[-1,101]);
            test_file = fullfile(this.test_dir,'test_large_bins_sqw.sqw');
            cleanup_obj1=onCleanup(@()delete(test_file));
            
            save(cs,test_file);
            
            anSQW = sqw();
            fid = fopen(test_file,'rb');
            if fid<1
                error('Can not open test file %s',test_file)
            end
            %cleanup_obj2=onCleanup(@()fclose(fid ));
            
            [mess,main_header,header,det_tmp,datahdr,pos,npix_tot,data_type,file_format,current_format] = get_sqw (anSQW,fid,'-h');
            fclose(fid);
            
            npix_start_pos =pos.npix;  % start of npix field
            pix_start_pos  =pos.pix;   % start of pix field
            
            
            params = [1,1,10000000,2,false,false,100,4096,1];
            in_file_par = {struct('file_name',test_file,'npix_start_pos',npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            out_file_par = struct('file_name','dummy_out','npix_start_pos',0,'pix_start_pos',1000,'file_id',0);
            
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,out_file_par,params);
            assertEqual(npix(1),pix_info(1));
            assertEqual(double(pix_info(1)),npix_tot)
            assertEqual(double(pix_info(2)),1)
            
            assertEqual(pix_data(:,1:npix_tot),single(cs.data.pix));
            
        end
        function this=test_combine_two_multi(this)
            [use_mex,thread_mode] = get(hor_config,'use_mex_for_combine','mex_combine_thread_mode');
            if ~use_mex
                return;
            end
            infiles = {fullfile(this.sample_dir,'w2d_qe_sqw.sqw'),fullfile(this.sample_dir,'w2d_qe_sqw.sqw')};
            outfile = fullfile(this.test_dir,'test_combine_two_sqw.sqw');
            cleanup_obj=onCleanup(@()delete(outfile));
            cleanup1  =onCleanup(@()set(hor_config,'mex_combine_thread_mode',thread_mode));
            
            set(hor_config,'mex_combine_thread_mode',1);
            dummy = sqw();
            write_nsqw_to_sqw (dummy, infiles, outfile,'allow_equal_headers');
            
            
            old_sqw = read_sqw(infiles{1});
            new_sqw = read_sqw(outfile);
            
            
            assertEqual(size(old_sqw.data.npix),size(new_sqw.data.npix));
            assertEqual(2*old_sqw.data.npix,new_sqw.data.npix);
            old_pix_size = size(old_sqw.data.pix);
            assertEqual(size(new_sqw.data.pix),[old_pix_size(1),2*old_pix_size(2)] );
            
        end
        
        function this = test_read_pix_buf_mex_multithread(this)
            use_mex = get(hor_config,'use_mex_for_combine');
            if ~use_mex
                return;
            end
            %
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/4;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            the_sqw = read_sqw(this.sample_file);
            
            pns = reshape(the_sqw.data.npix,numel(the_sqw.data.npix),1);
            pps  = [0;cumsum(pns)];
            log_level = get(hor_config,'log_level');
            
            
            in_file_par = {struct('file_name',this.sample_file,...
                'npix_start_pos',npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            params = [n_bin,1,100,log_level,false,false,100,64,1];
            dummy_out_file_par = struct('file_name','dummy_out','npix_start_pos',0,'pix_start_pos',1000,'file_id',0);
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,dummy_out_file_par,params);
            
            assertEqual(npix(1:43),uint64(pns(1:43)));
            
            assertEqual(pix_info(1),uint64(99))
            assertEqual(pix_info(2),uint64(43))
            if any(any(abs(pix_data-the_sqw.data.pix(:,1:99))>1.e-4))
                non_equal = abs(pix_data-the_sqw.data.pix(:,1:99))>1.e-4;
                ii = find(non_equal);
                ind = ii(1)/9+1;
                fprintf('wrong multithrading reaing Pixel N %d\n Right pixel: 9%f\n Wrong pixel 9%f\n',...
                    ind,the_sqw.data.pix(:,ind),pix_data(:,ind));
            end
            assertEqual(pix_data,single(the_sqw.data.pix(:,1:99)))
            %cleanup_obj=onCleanup(@()sr.delete());
            
            params = [n_bin,1,this.npixtot,log_level,false,false,100,64,1];
            t0= tic;
            [pix_data,npix,pix_info] = combine_sqw(in_file_par,dummy_out_file_par,params);
            t1=toc(t0);
            if log_level >1
                disp([' Time to process ',num2str(n_bin),' cells containing ',...
                    num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            end
            
            if any(abs(double(npix)-pns)>1.e-4)
                non_equal = abs(double(npix)-pns)>1.e-4;
                ii = find(non_equal);
                ind = ii(1);
                fprintf('wrong multithrading reaing bin N %d Right nbin: %d, Wrong nbin %d\n',...
                    ind,pns(ind),npix(ind));
            end
            if any(any(abs(pix_data(:,1:2248)-the_sqw.data.pix(:,1:2248))>1.e-8))
                non_equal = abs(pix_data(:,1:2248)-the_sqw.data.pix(:,1:2248))>1.e-4;
                ii = find(non_equal);
                ind = floor(ii(1)/9)+1;
                fprintf(['wrong multithrading reaing Pixel N %d\n',...
                    ' Right pixel: %f|%f|%f|%f|%f|%f|%f|%f|%f\n Wrong pixel: %f|%f|%f|%f|%f|%f|%f|%f|%f\n'],...
                    ind,the_sqw.data.pix(:,ind),pix_data(:,ind));
            end
            if any(any(abs(pix_data-the_sqw.data.pix)>1.e-4))
                non_equal = abs(pix_data-the_sqw.data.pix)>1.e-4;
                ii = find(non_equal);
                ind = ii(1)/9+1;
                fprintf(['wrong multithrading reaing Pixel N %d\n',...
                    ' Right pixel: %f|%f|%f|%f|%f|%f|%f|%f|%f\n Wrong pixel: %f|%f|%f|%f|%f|%f|%f|%f|%f\n'],...
                    ind,the_sqw.data.pix(:,ind),pix_data(:,ind));
            end
            
            assertEqual(npix,uint64(pns));
            assertEqual(pix_info(1),uint64(this.npixtot))
            assertEqual(pix_info(2),uint64(n_bin))
            
            assertEqual(pix_data(:,1:2248),single(the_sqw.data.pix(:,1:2248)))
            
            assertEqual(pix_data(:,4095),single(the_sqw.data.pix(:,4095)))
            assertEqual(pix_data(:,4096),single(the_sqw.data.pix(:,4096)))
            assertEqual(pix_data(:,4097),single(the_sqw.data.pix(:,4097)))
            
            assertEqual(pix_data(:,7892),single(the_sqw.data.pix(:,7892)))
            assertEqual(pix_data(:,7893),single(the_sqw.data.pix(:,7893)))
            
            assertEqual(pix_data,single(the_sqw.data.pix))
            
        end
        
        
    end
end


