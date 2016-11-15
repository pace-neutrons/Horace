classdef pix_combine_info
    % Helper class used to carry out and proivde combibe pixels info
    % for write_nsqw_to_sqw algorithm
    %
    properties(Access = protected)
        n_pixels_ = undefined;
    end
    
    properties(Access=public)
      infiles;
      pos_npixstart;
      pos_pixstart;
      run_label;
      npixtot;        
    end
    properties(Dependent)    
        npixels;
    end
    
    
    methods
        function obj = pix_combine_info(infiles,pos_npixstart,pos_pixstart,run_label,npixtot)
            obj.infiles = infiles;
            obj.pos_npixstart= pos_npixstart;
            obj.pos_pixstart = pos_pixstart;
            obj.run_label    = run_label;
            obj.npixtot     = npixtot;
            obj.n_pixels_ = sum(npixtot);
        end
    end
    
end

