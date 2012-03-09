function [this,is_redefined]= check_loader_redefined(this)
% method redefines spe and par reader if data or par file names are
% present among input parameters of the class method;
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%

 is_redefined=false;
 if ~isempty(this.data_file_name) % new file name is defined among the parameters; data_loader has to be redefined;
        dat_file_name=this.data_file_name;
        this.data_file_name='';
        is_redefined=true;
 else
        dat_file_name='';
 end
 if ~isempty(this.par_file_name)
        par_fname=this.par_file_name;
        this.par_file_name='';
        is_redefined=true;        
 else
        par_fname='';
 end
 % files are defined
 if ~isempty(dat_file_name) % file reader has to be redefined;
     if ~isempty(par_fname)
            this.loader='';
            warning('off','MATLAB:structOnObject');
            this=rundata(dat_file_name,par_fname,struct(this));
            warning('on','MATLAB:structOnObject');            
     else
            this.S =[];
            this.ERR=[];
            this.en =[];
            this.n_detectors=[];
            this.det_par=[];
            this=select_loader(this,dat_file_name);            
     end
 else % only par data have to be redefened, and this meand ascii file reader
     if ~isempty(par_fname)
        % second argument has to be a par file name;
         [this.det_par,la] = load_par(loader_ascii(),par_fname);                    
         % get detectors info from ascii par file loader;
         if ~isempty(this.n_detectors) 
            n_det_s = get_run_info(la);
            if n_det_s~=this.n_detectors
                error('RUNDATA:check_loader_redefined',' number of detectors is not consistent with number of data points')
            end
         else
            this.n_detectors=get_run_info(la);
         end
     end
 end