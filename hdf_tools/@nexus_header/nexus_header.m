classdef nexus_header
% class intended to allow sqw files to be treated as a nexus files
% it simply adds nexus attributes to sqw file.
% Class have to be invoked  manually (through composition) 
% as it is necessary to move file check methods from spe_header here;
%
%
% $Revision$ ($Date$)
%
    properties(GetAccess='private', SetAccess='private') 
% attributes to be written into the file in order to          
        NeXus_version='4.1.0';
        file_name    ='undefined';        
        HDF5_Version ='';
        file_time =   '';
        % ugly dublication but I am unable to obtain the list of the
        % private fields;
        attrib_name={'NeXus_version','file_name','HDF5_Version','file_time'};
    end
    methods 
        function this=nexus_header()
         [major,minor,release]=H5.get_libversion();
         this.HDF5_Version=[int2str(major),'.',int2str(minor),'.',int2str(release)];         
         this.file_time=sprintf('%4.0f-%02.0f-%02.0fT%02.0f:%02.0f:%02.0f+01:00',clock());            
        end         
        function this=write_nexus(this,hdf_fileID,fileName)           
        % function used to add nexus attributes to an previously opened
        % hdf5 file
       
            [path,name,ext]=fileparts(fileName);
            this.file_name = [name,ext];
            this.file_time=sprintf('%4.0f-%02.0f-%02.0fT%02.0f:%02.0f:%02.0f+01:00',clock());
            strType=cell(1,numel(this.attrib_name));
            space=H5S.create('H5S_SCALAR');            
            for i=1:numel(strType)
                strType{i}=H5T.copy ('H5T_C_S1');
            end
            H5T.set_size (strType{1}, numel(this.NeXus_version));
            H5T.set_size (strType{2}, numel(this.file_name));
            H5T.set_size (strType{3}, numel(this.HDF5_Version));
            H5T.set_size (strType{4}, numel(this.file_time));            
            
            attr=cell(1,numel(strType));
            for i=1:numel(strType)
                try
                    attr{i}=H5A.open(hdf_fileID,this.attrib_name{i},'H5P_DEFAULT');
                catch
                   attr{i}= H5A.create (hdf_fileID, this.attrib_name{i}, strType{i}, space, 'H5P_DEFAULT');                   
                end
            end
            H5A.write (attr{1}, strType{1}, this.NeXus_version);            
            H5A.write (attr{2}, strType{2}, this.file_name);            
            H5A.write (attr{3}, strType{3}, this.HDF5_Version);            
            H5A.write (attr{4}, strType{4}, this.file_time);                        
            for i=1:numel(strType)
                H5A.close(attr{i});
                H5T.close(strType{i});
            end
            
        end
    end %methods
end % classdef