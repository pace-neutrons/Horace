classdef test_sqw_reader< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        sample_dir;
        sample_file;
        positions
        npixtot
    end
    
    
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_sqw_reader(name)
            this=this@TestCase(name);
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w3d_sqw.sqw');
            fid = fopen(this.sample_file);
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
            
            files = {this.sample_file};
            file_par = {struct('npix_start_pos',npix_start_pos,'pix_start_pos',pix_start_pos,'file_id',0)};
            params = [n_bin,1,100];
            [pix_data,pix_info] = combine_sqw(files,file_par,params);
            
            assertEqual(pix_info(1),uint64(99))
            assertEqual(pix_info(2),uint64(42))
            assertEqual(pix_data(1:99),single(the_sqw.data.pix(1:99)))
            %cleanup_obj=onCleanup(@()sr.delete());
            
            params = [n_bin,1,this.npixtot];
            t0= tic;
            [pix_data,pix_info] = combine_sqw(files,file_par,params);
            t1=toc(t0);
            
            disp([' Time to process ',num2str(n_bin),' cells containing ',...
                num2str(this.npixtot),'pixels is ',num2str(t1),'sec'])
            
            assertEqual(pix_info(1),uint64(this.npixtot))
            assertEqual(pix_info(2),uint64(n_bin-1))
            
           
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




