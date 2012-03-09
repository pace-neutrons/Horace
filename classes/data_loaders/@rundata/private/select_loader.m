function this=select_loader(this,varargin)
% method selects the data loader for the rundata class as function of
% supplied file names and defines other data fields, if they are specified 
% by command line arguments
%
% it assumes that the first and, if present second argument in varargin are
% the data_file_name and parameters_file_name
% 
% Usage: (private, used by rundata constructor);
%>>this=select_loader(this,'data_file.nxspe',['par_file.par'],varargin{2:end})
%>>this=select_loader(this,'data_file.spe',   'par_file.par',varargin{2:end})
%>>this=select_loader(this,'data_file.spe_h5','par_file.par',varargin{2:end})
%  
% where varagin{:} has the form: 
% 'field', value -- with field to be an existing rundata field name and 
%          value -- its desired value, which may redefine the value, specified in the 
%                   correspondent spe or par file. 
%
% $Author: Alex Buts 20/10/2011
% 
% $Revision$ ($Date$)
%
  
if nargin==1; return; end


if isa(varargin{1},'char')    % build from a file;
    [first_file,lext] =check_file_exist(varargin{1},this.supported_extensions);
    switch(lext)
           case('.spe')
               % set up spe and par files and check if all necessary
               % arguments are present; second argument in this case
               % has to be a par file name;
               if nargin==2
                    this.loader= loader_ascii(first_file); 
                    [this.n_detectors,this.en,this.loader]     =get_run_info(this.loader);
               else
                  if nargin>2
                    this.loader= loader_ascii(first_file,varargin{2});       
                    [this.n_detectors,this.en,this.loader]     =get_run_info(this.loader);                  
                    if nargin>3
                           % set up values which are defined by arguments 
                            this=parse_arg(this,varargin{3:end});
                        % get number of detectors defined in par file                                                             
                    end
                    end
               end
           case('.spe_h5')
               this.loader= loader_speh5(first_file);  
               [this.n_detectors,this.en,this.loader]  =get_run_info(this.loader); 
               if nargin>2
                   % second argument has to be a par file name;
                   [this.det_par,la] = load_par(loader_ascii(),varargin{2});                    
                   % get detectors info from ascii par file loader;
                   this.n_detectors=get_run_info(la);  
                   % set the par file name to ascii par file name
                   this.loader.par_file_name = la.par_file_name;
   
                   if nargin>3
                       % set up values which are defined by other arguments 
                       this=parse_arg(this,varargin{3:end});                   
                   end
               else
                   error('RUNDATA:invalid_argument','providing spe_h5 file %s as the source of data needs par file to be defined too\n',first_file);                  
               end
           case('.nxspe')
               this.loader                           = loader_nxspe(first_file);  
               [this.n_detectors,this.en,this.loader]= get_run_info(this.loader);                
               %
               if nargin >2   % everything is defined by nxspe, which is all what needed for powder
                   modyfieres = 2;
                   if ischar(varargin{2})
                       try  % if second parameter an existing par-filename, it owerrides par-data within nxspe file;
                           second_file       = check_file_exist(varargin{2},'.par');
                           par_is_file       = true;
                       catch % no, it is probably an parameter                       
                           second_file        = '';
                           par_is_file        = false;
                       end
                       if par_is_file
                        [this.det_par,la] = load_par(loader_ascii(),second_file);
                           spe_detectors     = get_run_info(la);
                           if spe_detectors ~=this.n_detectors
                               error('RUNDATA:invalid_argument', ...
                               'Can not use this par detector file with this nxspe file\n ascii par %s and nxspe %s files inconsistent; \n ascii detectors %d, nxspe %d',...
                               second_file,first_file,spe_detectors,this.n_detectors);
                           end
                           this.loader.par_file_name=second_file;
                           modyfieres=3;
                       end
                   end
                   % all other parameters are present in command line;
                   if nargin>=modyfieres; 
                       this=parse_arg(this,varargin{modyfieres:end});                            
                   end                
               end
           otherwise                
              error('RUNDATA:invalid_argument','file %s exist but the file extention %s is not recognized by the program',first_file,lext);
    end  % swith over the data formats

else % function accepts only char arguments;
   error('RUNDATA:invalid_argument','unsupported first argument');        
end

 
   
