function varargout=load_data(this,new_file_name)
% function loads memfile data into run_data structure
%
% this function is the method of memfile class
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%usage:
%>>[S,ERR]         = load_data(this,[new_file_name])
%>>[S,ERR,en]      = load_data(this,[new_file_name])
%>>[S,ERR,en,this] = load_data(this,[new_file_name])
%>>this            = load_data(this,[new_file_name])
%
%
%
% $Revision: 334 $ ($Date: 2014-01-16 13:40:57 +0000 (Thu, 16 Jan 2014) $)
%

if exist('new_file_name','var')
    % check the new_file_name describes correct file, got internal file
    % info and obtain this info.
    this.file_name = new_file_name;
end

filename =this.file_name;
if isempty(filename )
    error('MEMFILE:load_data',' input .memfile file is not defined')
end


tmf = memfile_fs.instance().load_file(filename);
data{1}  = tmf.S;
data{2}  = tmf.ERR;
if isempty(this.en)
    this.en_stor =tmf.en;
end
data{3} = this.en;

this.S_stor   = data{1};
this.ERR_stor = data{2};

if nargout==1
    varargout{1}=this;
else
    min_val = nargout;
    if min_val>3;
        min_val=3;
        varargout{4}=this;
    end
    varargout(1:min_val)={data{1:min_val}};
    
end
