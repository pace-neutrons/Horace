classdef test_sqw_reader< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        sample_dir;
        sample_file;
        positions
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
            
            
            
        end
        
        %% Symmetrisation tests
        function this = test_reader(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/8;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            
            sr =  sqw_reader(this.sample_file,npix_start_pos,n_bin,pix_start_pos,10);
            
            f = @()(sr.get_pix_for_bin(0));
            assertExceptionThrown(f,'SQW_READER:read_pix');
            
            pix = sr.get_pix_for_bin(1);
            assertEqual(size(pix),[9,3]);
            pix = sr.get_pix_for_bin(2);
            assertEqual(size(pix),[9,3]);
            cleanup_obj=onCleanup(@()sr.delete());
        end
        
    end
end




