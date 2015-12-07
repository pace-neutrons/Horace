classdef test_sqw_reader< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        sample_dir;
        sample_file;
        positions
        fid
    end
    
    
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_sqw_reader(name)
            this=this@TestCase(name);
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w3d_sqw.sqw');
            this.fid = fopen(this.sample_file);
            theSqw = sqw();
            [mess,main_header,header,det_tmp,datahdr,this.positions,npixtot,data_type,file_format,current_format] = get_sqw (theSqw,this.fid,'-h');
            if ~isempty(mess)
                error('Can not read sample file %s header, error: %s',this.sample_file,mess)
            end
            cleanup_obj=onCleanup(@()fclose(this.fid));
            
            
        end
        
        %% Symmetrisation tests
        function this = test_reader(this)
            pos_s = this.positions.s;
            pos_e = this.positions.e;
            n_bin = (pos_e-pos_s)/8;
            npix_start_pos =this.positions.npix;  % start of npix field
            pix_start_pos  =this.positions.pix;   % start of pix field
            
            
            sr =  sqw_reader(this.fid,npix_start_pos,n_bin,pix_start_pos,10);
            
            
            pix = sr.get_pix_for_bin(1);
          
        end
        
    end
end




