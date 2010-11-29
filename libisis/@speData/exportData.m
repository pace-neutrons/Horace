function [data,this]=exportData(this)
% gateway routine to other parts of the program
% written for compartibility of the new class with previous program.
% data has following fields:
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%   data.filename   short file name;
%   data.filepath

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
delete_data=false;
if(~this.data_loaded)
    this=read(this,fullfile(this.fileDir,this.fileName));   
    delete_data=true;    
end
if isfield(this,'spe') % when it works? 
    data.S        = this.spe.S;
    data.ERR      = this.spe.ERR;
    data.en       = this.spe.en;
    data.filename = this.fileName;
    data.filepath = this.fileDir;    
    [ne,ndet]     = size(data.S);
    disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);
    if(delete_data)
        this=deflate(this);
    end    
else
    data.S        = this.S;
    data.ERR      = this.ERR;
    data.en       = this.en;   
    data.filename = this.filename;
    data.filepath = this.filepath;    
end

