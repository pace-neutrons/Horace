function [data, mess] = get_spe_datablock (fid, data_in)
%  Read the a block of data corresponding to one .spe file from a binary file created
% by gen_hkle.
%
% Syntax:
%   >> [data,mess] = get_spe_datablock (fid)            % read to new data structure
%   >> [data,mess] = get_spe_datablock (fid, data_in)   % append to existing data structure
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Data structure to which the grid data
%              fields below will be added.
%
% Output:
% -------
%   data.ei     Incident energy used for spe file (meV)
%   data.psi    Psi angle (deg)
%   data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%   data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%   data.file   File name of .spe file corresponding to the block being read
%   data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%   data.v      Array containing the components along the mslice projection
%              axes u1, u2, u3 for each pixel in the .spe file.
%              Note: size(data.v) = [3, no. dets * no. energy bins]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.S      Intensity vector [row vector]
%   data.ERR    Variance vector [row vector]
%
%   mess        Error message; blank if all is OK, non-blank otherwise
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

data = [];
if nargin==2
    if isstruct(data_in)
        data = data_in;
    else
        mess = 'ERROR: Check the type of input argument data_in';
        return
    end
end

[data.ei,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
[data.psi,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
[data.cu,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
[data.cv,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
[n,count,ok,mess] = fread_catch(fid, 1, 'int32'); if ~all(ok); return; end;
[data.file,count,ok,mess] = fread_catch(fid, [1,n], '*char'); if ~all(ok); return; end;
[data.size,count,ok,mess] = fread_catch(fid, [1,2], 'int32'); if ~all(ok); return; end;
nt= data.size(1)*data.size(2);
[data.v,count,ok,mess] = fread_catch(fid, [3,nt], 'float32'); if ~all(ok); return; end;
[data.en,count,ok,mess] = fread_catch(fid, [1,data.size(2)], 'float32'); if ~all(ok); return; end;
[data.S,count,ok,mess] = fread_catch(fid, [1,nt], 'float32'); if ~all(ok); return; end;
[data.ERR,count,ok,mess] = fread_catch(fid, [1,nt], 'float32'); if ~all(ok); return; end;

