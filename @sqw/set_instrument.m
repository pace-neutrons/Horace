function varargout = set_instrument (varargin)
% Change the instrument in an sqw object or array of objects
%
%   >> wout = set_instrument (w, instrument)
%
%
% Input:
% -----
%   w           Input sqw object or array of objects
%
%   instrument  Instrument object or structure, or array of objects or
%              structures, with number of elements equal to the number of
%              runs contributing to the sqw object(s).
%               If the instrument is any empty object, then the instrument
%              is set to the default empty structure.
%
% Output:
% -------
%   wout        Output sqw object with changed instrument

% Original author: T.G.Perring
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)


% This routine is also used to set the instrument in sqw files, when it overwrites the input file.

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
narg=numel(args);
if narg==0
    % Nothing to do
    if w.source_is_file
        argout={};
    else
        argout{1}=w.data;
    end
elseif narg==1
    if isscalar(args{1}) && (isstruct(args{1}) || isobject(args{1}))
        instrument=args{1}; % single structure or object
    elseif isempty(args{1})
        instrument=struct;  % empty item indicates no instrument; set to default 1x1 empty structure
    else
        error('Instrument must be a scalar (or array of) structures or objects (or an empty argument to indicate ''no instrument'')')
    end
    
    % Check that the data has the correct type
    if ~all(w.sqw_type(:))
        error('Instrument can only be set or changed in sqw-type data')
    end
    
    % Change the instrument
    if w.source_is_file
        % Check the number of spe files matches the number of instruments
        ninst=numel(instrument);
        if ninst>1
            for i=1:numel(w.data)
                [mess,main_header]=get_sqw (w.data{i},'-hverbatim');
                if ~isempty(mess), error(mess), end
                if main_header.nfiles~=ninst
                    error('An array of instruments was given but its length does not match the number of spe files in (all) the sqw file(s) being altered')
                end
            end
        end
        % Change the instruments
        for i=1:numel(w.data)
            % Read the header part of the data
            [mess,h.main_header,h.header,h.detpar,h.data]=get_sqw (w.data{i},'-hisverbatim');
            if ~isempty(mess), error(mess), end
            % Change the header
            nfiles=h.main_header.nfiles;
            if nfiles>1
                tmp=h.header;   % to keep referencing to sub-fields to a minimum
                for ifiles=1:nfiles
                    if ninst==1
                        tmp{ifiles}.instrument=instrument;
                    else
                        tmp{ifiles}.instrument=instrument(ifiles);
                    end
                end
                h.header=tmp;
            else
                h.header.instrument=instrument;
            end
            % Write back out
            mess = put_sqw (w.data{i},h.main_header,h.header,h.detpar,h.data,'-his');
            if ~isempty(mess), error(['Error writing to file ',w.data{i},' - check the file is not corrupted: ',mess]), end
        end
        argout={};
    else
        wout=w.data;
        % Check the number of spe files matches the number of instruments
        ninst=numel(instrument);
        if ninst>1
            for i=1:numel(wout)
                if wout(i).main_header.nfiles~=ninst
                    error('An array of instruments was given but its length does not match the number of spe files in (all) the sqw object(s) being altered')
                end
            end
        end
        % Change the instruments
        for i=1:numel(wout)
            nfiles=wout(i).main_header.nfiles;
            if nfiles>1
                tmp=wout(i).header;   % to keep referencing to sub-fields to a minimum
                for ifiles=1:nfiles
                    if ninst==1
                        tmp{ifiles}.instrument=instrument;
                    else
                        tmp{ifiles}.instrument=instrument(ifiles);
                    end
                end
                wout(i).header=tmp;
            else
                wout(i).header.instrument=instrument;
            end
        end
        argout{1}=wout;
    end
else
    error('Check the number of input arguments')
end


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
