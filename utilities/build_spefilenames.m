function [spefiles,psi]=build_spefilenames(spefile_template, run_nums, psi_beg, psi_step, psi_end, spefiles_in, psi_in)
% Build (and accumulate) spe file names for use in Horace with ISIS data. Small utility to make life a bit easier
%
%   >> [spefiles,psi] = build_spefilenames (spefile_template, run_nums,...
%                                                   psi_beg, psi_step, psi_end)
%   >> [spefiles,psi] = build_spefilenames (spefile_template, run_nums,...
%                                                   psi_beg, psi_step, psi_end, spefiles_in, psi_in)
%
% Input:
% ------
%   spefile_template    File name for spe file, including path, where the run number
%                      is denoted by an asterisk e.g. 'c:\temp\map*_4to1.spe'
%                       The output cell array of file names will be constructed
%                      from the list of run numbers substituting in the position of *
%                      appropriately padded with leading zeros. For example,
%                      run number 1234 in the above becomes 'c:\temp\map01234_4to1.spe' 
%
%   run_nums            Array of run numbers
%   psi_beg             Starting angle of psi (deg)
%   psi_step            Step size of psi (deg)
%   psi_end             Final value of psi (deg)
%
% Optional:
%   spefiles_in         Input list of spe filenames to which to accumulate
%   psi_in              Input array of psi angles to which to accumulate
%
%
% EXAMPLE OF USE:
%   >> % First group of files:
%   >> [spe_file,psi]=build_spefilenames('c:\temp\map*_4to1.spe',15835:15880,0,2,90);
%
%   >> % Append a second group of files:
%   >> [spe_file,psi]=build_spefilenames('c:\temp\map*_4to1.spe',15883:15927,1,2,89,spe_file,psi);

% $Revision$ ($Date$)

% Check input parameters
if isempty(spefile_template)||~ischar(spefile_template)||numel(size(spefile_template))>2||size(spefile_template,1)~=1
    error('Template for spe file name must be a single character string')
else
    ind=strfind(spefile_template,'*');
    if numel(ind)<1
        error('Cannot find location(s) to substitute with run number in spe filename template')
    end
end
    
if isempty(run_nums)||~isnumeric(run_nums)||any(run_nums-round(run_nums)~=0)||any(run_nums)<0
    error('Run numbers must be integers and greater or equal to zero')
end

psi=psi_beg:psi_step:psi_end;
if numel(psi)~=numel(run_nums)
    error('Number of runs and the number of psi angles do not match')
end

% Check arrays to which to append
if exist('spefiles_in','var')
    if ~iscellstr(spefiles_in)
        error('Existing spe filenames to which to append must be a cell array of strings')
    else
        for i=1:numel(spefiles_in)
            if isempty(spefiles_in{i})||numel(size(spefiles_in{i}))>2||size(spefiles_in{i},1)~=1
                error('All input spe filenames must be non-empty character strings')
            end
        end
    end
    nspe_in=numel(spefiles_in);
else
    nspe_in=0;
end

if exist('psi_in','var')
    if ~isnumeric(psi_in)
        error('Existing psi values to which to append must be a numeric array')
    end
    npsi_in=numel(psi_in);
else
    npsi_in=0;
end

if nspe_in==npsi_in
    if nspe_in>0
        append=true;
    else
        append=false;
    end
else
    error('NUmber of file names and psi values do not match in the arrays to which new values are to be appended')
end

% Construct new files and psi arrays
spefiles=cell(1,numel(run_nums));
for i=1:numel(run_nums)
    [runchar,mess]=runno_char(run_nums(i));
    if ~isempty(mess)
        error(mess)
    end
    spefiles{i}=strrep(spefile_template,'*',runchar);
end

if append
    spefiles=[reshape(spefiles_in,1,nspe_in),spefiles];
    psi=[psi_in(:)',psi];
end

%-------------------------------------------------------------------------------------------------
function [runchar,mess]=runno_char(runno)
% Convert run number into character string
% Assumes ISIS format i.e. 5 digits or 8 digits, i.e.
%  - if       0 <= runno <= 99999       padded with zeros to make 5 characters long
%  - if  100000 <= runno <= 99999999    padded with zeros to make 8 characters long

if runno<0
    runchar=''; mess='Run number must be in the range 0-99999999'; return
elseif runno<=99999
    ndigits=5;
elseif runno<=99999999
    ndigits=8;
else
    runchar=''; mess='Run number must be in the range 0-99999999'; return
end

runchar = num2str(runno);
xlen = ndigits - length(runchar);
if xlen > 0
    runchar = [repmat('0', 1, xlen) runchar];
end
mess='';
