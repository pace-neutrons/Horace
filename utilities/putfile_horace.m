function [file_internal,mess] = putfile_horace(varargin)
% Check input file name(s) for Horace functions that expect file data source, prompting if necessary
%
%   >> file_internal = function_get_file (infile)
%
% Input:
% ------
%   infile          Input file name (character string, character array, cell array of file names)
%                   If absent, prompt for a file name
%                   Used as file filter if a character string that is not a file e.g. '*.d0d;*.d1d;*.d2d;*.d3d;*.d4d'.
%                   Checks files exist
% Output:
% -------
%   file_internal   File name or (if more than one) cell array of file names


% Check input file name(s)
mess='';
if nargin==0
    file_internal=putfile;    % prompt for a single file name - no filter applied
    if isempty(file_internal)
        mess='No output file name given';
    end
elseif nargin==1
    if ischar(varargin{1}) && length(size(varargin{1}))==2
        infile=cellstr(varargin{1});
    elseif iscellstr(varargin{1})
        infile=varargin{1};
    else
        file_internal='';
        mess='Output data file name(s) must be character string, 2D character array or cell array of character strings';
        return
    end
    if numel(infile)==1
        infile=strtrim(infile{1});  % cellstr only trims trailing whitespace, so use strtrim
        if isempty(infile)
            file_internal=putfile;
        else
            file_internal=infile;   % *** better to check if file is a valid name, if not use as file filter
        end
        if isempty(file_internal)
            mess='No output file name given';
        end
    else
        for i=1:numel(infile)
            infile{i}=strtrim(infile{i});
            if isempty(infile{i})
                file_internal='';
                mess='At least one output data file name is blank';
                return
            end
        end
        file_internal=infile;
    end
else
    file_internal='';
    mess='Check number of input arguments';
end
