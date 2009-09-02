function [data,this]=exportData(this)
% gateway routine to other parts of the program
% written for compartibility of the new class with previous program.
% data has following fields:
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%   data.filename  ? if it is full file name or the short one?
%   data.filepath

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Ibon Bustinduy: catch with Matlab routine if fortran fails

% If no input parameter given, return
delete_data=false;
if(~this.data_loaded)
    this=loadData(this);
    delete_data=true;
end

data.S        = this.S;
data.ERR      = this.ERR;
data.en       = this.en;
data.filename = this.fileName;
data.filepath = this.fileDir;
[ne,ndet]=size(data.S);
disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);
if(delete_data)
    this=deflate(this);
end
end
