function [mess, position, npixtot] = put_sqw_data_npix_and_pix_to_file (outfile, npix, pix, varargin)
% Write npix and pix to a new file with the same format as put_sqw (non-sparse format)
%
%   >> [mess, position, npixtot] = put_sqw_data_npix_and_pix_to_file (outfile, npix, pix)
%   >> [mess, position, npixtot] = put_sqw_data_npix_and_pix_to_file (...,'file_format',fmt)
%
% Input:
% ------
%   outfile     File name, or file identifier of open file, to which to append data
%   npix        Array containing the number of pixels in each bin
%   pix         Array containing data for each pixel:
%              Each column of the of the array (which has size [9,npixtot] where npixtot=sum(npix)) contains:
%                   u1      -|
%                   u2       |  Coordinates of pixel in the projection axes of the original sqw file(s)
%                   u3       |
%                   u4      -|
%                   irun        Run index in the header block from which pixel came
%                   idet        Detector group number in the detector listing for the pixel
%                   ien         Energy bin number for the pixel in the array in the (irun)th header
%                   signal      Signal array
%                   err         Error array (variance i.e. error bar squared)
%   file_format [Optional] File format to be written (appversion object). If not given, then
%              assumes the current default.
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   position    Position (in bytes from start of file) of large fields:
%                   position.npix   position of array npix (in bytes) from beginning of file
%                   position.pix    position of array pix (in bytes) from beginning of file
%   npixtot     Total number of pixels written to file

% T.G.Perring 10 August 2007

position = struct('npix',[],'pix',[]);
npixtot = [];

% Check file format
if numel(varargin)==2 && ischar(varargin{1}) && strcmpi(varargin{1},'file_format')
    fmt_ver=varargin{2};
    [ok,mess]=fmt_check_file_format(fmt_ver);
    if ~ok, return, end
elseif isempty(varargin)
    fmt_ver=fmt_check_file_format();    % get default file format
else
    mess='Invalid optional argument(s)';
    return
end

% Open output file
[mess,filename,fid,fid_input]=put_sqw_open(outfile);
if ~isempty(mess), return, end

% Write npix and pix in the same format as put_sqw_data (non-sparse format)
data=struct('npix',npix,'pix',pix);
[mess,pos_tmp,npixtot] = put_sqw_data_signal (fid, fmt_ver, data);
if ~isempty(mess), return, end
position=updatestruct(position,pos_tmp);

% Close file if necessary
if ~fid_input
    fclose(fid);
end
