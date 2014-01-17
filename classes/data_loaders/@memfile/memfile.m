classdef memfile<a_loader
    % class which resempbles data file stored to memory and loaded from
    % memory
    %
    % $Revision: 334 $ ($Date: 2014-01-16 13:40:57 +0000 (Thu, 16 Jan 2014) $)
    %
    % the properties common for all data loaders.
    properties(Dependent)
        % number of detectors in par file or in data file (should be
        % consistent if both are present;
        psi =[];
        efix =[];
    end
    
    properties(Access=protected)
        %
        efix_stor = [];
        psi_stor  = [];
    end
    %
    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext={'.memfile'};
        end
        function descr=get_file_description()
            % avoid description to not to try load this file from GUI
            descr ={};
        end
        
        function [ok,fh] = can_load(file_name)
            % check if the file name is spe file name and the file can be
            % loaded by loader_ascii
            %
            %Usage:
            %>>[ok,fh]=loader.is_loader_correct(file_name)
            % Input:
            % file_name -- the name of the file to check
            % Output:
            %
            % ok   -- True if the file can be processed by the loader_ascii
            % fh --  the structure, which describes spe file
            fh=[];
            ok = memfile_fs.instance().file_exist(file_name);
        end
        
        function [ndet,en,full_file_name,ei,psi]=get_data_info(file_name)
            % Load header information of nxspe MANTID file
            %
            % >> [ndet,en,full_file_name,ei,psi,nexus_ver,nexus_dir] = loader_nxspe.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % en    -- energy bins
            % full_file_name -- the full name (with path) of the source nxpse file
            % ei     -- incident energy
            % psi    -- crystal rotation angle (should be NaN if undefined, but some )
            % nexus_dir -- internal nexus folder name where the data are stored
            % nxspe_ver -- version of the nxspe data
            %
            %second form requests file to be already defined in loader
            %first form just reads file info from given spe file name.
            %
            if ~exist('file_name','var')
                error('MEMFILE:get_data_info',' has to be called with valid file name');
            end
            tf = memfile_fs.instance().load_file(file_name);
            ndet = tf.n_detectors;
            ei   = tf.efix;
            en    = tf.en;
            full_file_name = tf.file_name;
            psi = tf.psi;
        end
    end
    
    methods
        % constructor;
        function this=memfile(memfile_name,varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=a_loader();
            %   constructor, which specifies par file name:
            %>>this=a_loader(par_file_name);
            %   copy constructor:
            %>>this=a_loader(other_loader);
            %
            this=this@a_loader(varargin{:});
            if exist('memfile_name','var')
                this= this.init(memfile_name);
            else
                this = this.init();
            end
        end
        function this=init(this,memfile_name,full_par_file_name,varargin)
            %
            this.loader_defines ={'S','ERR','en','efix','psi','det_par','n_detectors'};
            if ~exist('memfile_name','var')
                return
            end
            if exist('full_par_file_name','var')
                this.par_file_name = full_par_file_name;
            end
            
            [this.n_detindata_stor,this.en_stor,this.data_file_name_stor,...
                this.efix_stor,this.psi_stor]=memfile.get_data_info(memfile_name);
            if isempty(this.par_file_name)
                this.n_detinpar_stor = this.n_detindata_stor;
            end
            
        end
        %
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names,
            % which are defined by current instance of loader class
            %
            % e.g. loader_ascii defines {'S','ERR','en','n_detectrs} if par file is not defined and
            % {'S','ERR','en','det_par'} if it is defined and loader_nxspe defines
            % {'S','ERR','en','det_par','efix','psi'}(if psi is set up)
            %usage:
            %>> fields= defined_fields(loader);
            %   loader -- the specific loader constructor
            %
            
            % the method returns the cellarray of fields names, which are
            % defined by ascii spe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = check_defined_fields(this);
        end
        function this=set_data_info(this,file_name)
            % method sets internal file information obtained for appropriate file
            % by get_data_info method;
            [this.n_detindata_stor,this.en_stor,this.data_file_name_stor,...
                this.efix_stor,this.psi_stor]=this.get_data_info(file_name);
            
        end
        function [det,this]=load_par(this,varargin)
            if isempty(this.par_file_name)
                mf = memfile_fs.instance().load_file(this.file_name);
                this.det_par = mf.det_par;
                det = mf.det_par;
            else
                det=load_par@a_loader(this,varargin{:});
                this.det_par = det;
            end
        end
        function this=save(this,file_name)
            % save memfile into its memory file system
            [~,fname,fext]=fileparts(file_name);
            if isempty(fext)
                fext='.memfile';
            end
            if strcmp('.memfile',fext)
                this.data_file_name_stor = [fname,fext];
                %
                
                memfile_fs.instance().save_file(fname,this);
            else
                error('MEMFILE:save',' can only save in file with extension .memfile and privided with %s',fext);
            end
        end
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR CLASS PROPERTIES     -------------------
        % -----------------------------------------------------------------
        function ef = get.efix(this)
            ef=this.efix_stor;
        end
        function this = set.efix(this,val)
            this.efix_stor = val;
        end
        function psi=get.psi(this)
            psi=this.psi_stor;
        end
        function this=set.psi(this,val)
            this.psi_stor=val;
        end
        % -----------------------------------------------------------------
        function [ok,mess,f_name]=check_file_exist(this,new_name)
            % method to check if file with extension correspondent to this loader exists
            [~,fn,fext] = fileparts(new_name);
            fbex = this.get_file_extension();
            if strcmp(fbex{1},fext)
                ok = memfile_fs.instance().file_exist(fn);
                if ok
                    mess ='';
                else
                    mess=['file: ',fn,fext,' does not exist'];
                end
                
                f_name = [fn,fext];
            else
                ok=false;
                mess='this loader can process memfiles only';
                f_name='';
            end
        end
        
    end
    
end
