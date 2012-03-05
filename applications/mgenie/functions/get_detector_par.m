function detpar = get_detector_par (source)
% Get secondary spectrometer information for all detectors for the current data source or from a file
%
%   >> detpar = get_detector_par        % Get from the currently assigned run
%   >> detpar = get_detector_par (file) % Get from detector.dat file
%
%   >> ok = get_detector_par (detpar)   % Check structure is valid
%
%   detpar is a structure with fields (all row vectors):
%     'det_no'
%     'delta'
%     'x2'
%     'code'
%     'twotheta'
%     'azimuth'
%     'wx'
%     'wy'
%     'wz'
%     'ax'
%     'ay'
%     'az'
%     'dead_time'
%     'xs'
%     'thick'
%     'index'
%
%   See detector.dat format documentation for full details


% Read from file, if provided, or if structure test fields are valid
if exist('source','var') && ~isempty(source)
    if ischar(source) && size(source,1)==1 && exist(source,'file')   % want it to be a file that it exists - no prompting
        try
            % try loading as spectra.dat
            detpar=load_detector_file(source);
        catch
            try
                % try interpreting as a detector.dat generator file
                tmpfile=fullfile(tempdir,['detector_',str_random(20),'.dat']);
                detector_table(source,tmpfile);
                % Read from generated file
                detpar=load_detector_file(tmpfile);
                try
                    delete(tmpfile)
                catch
                    warning(['Unable to delete temporary file: ',tmpfile])
                end
            catch
                rethrow(lasterror)
            end
        end
    elseif isstruct(source)
        detpar=source;     % pass straight through - *** add a test later ***
    else
        error('Invalid input - must be file name to read from, or structure to test for validity')
    end
    
else
    % Get from currently assigned raw file
    detpar.det_no=gget('udet');
    detpar.delta=gget('delt');
    detpar.x2=gget('len2');
    detpar.code=gget('code');
    detpar.twotheta=gget('tthe');
    
    % Two formats acceptable:
    % - 15 columns, last three are detector parameters
    % - 19 columns, last four are detector parameters
    nuse=double(gget('nuse'));
    if ~(nuse==10 || nuse==14)
        detpar.azimuth=zeros(1,gget('ndet'));
        return
    end
    detpar.azimuth=gget('ut1');
    detpar.wx=gget('ut2');
    detpar.wy=gget('ut3');
    detpar.wz=gget('ut4');
    if nuse==14
        detpar.ax=gget('ut8');
        detpar.ay=gget('ut9');
        detpar.az=gget('ut10');
        detpar.dead=gget('ut11');
        detpar.xs=gget('ut12');
        detpar.thick=gget('ut13');
        detpar.index=gget('ut14');
    elseif nuse==10
        detpar.ax=gget('ut5');
        detpar.ay=gget('ut6');
        detpar.az=gget('ut7');
        detpar.dead=zeros(size(detpar.det_no));
        detpar.xs=gget('ut8');
        detpar.thick=gget('ut9');
        detpar.index=gget('ut10');
    end
    
end
