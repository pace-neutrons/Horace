function mess = combine(dummy_spe,weight,spedir,spefiles,spefileout)
% Weighted combination of spe files together. If a pixel is bad in any one of the
% spe files, it is masked as bad in the output file. 
%
%   >> mess = add(spe,weight,spedir,spefiles,spefileout)
%
%   weight      Array of weights. The final output will not be further normalised.
%              Can be negative e.g. to take the difference between two files use
%              weights [1,-1]
%
%   spedir      Default directory containing the spe files e.g. 'c:\temp\mt_data\spe\'
%               (If argument spe file names in argument spefiles (below) contains the
%              full path, then spedir is ignored. Can set spedir='' i.e. blank string)
%
%   spefiles    Cell array of spe file names e.g. {'map01234.spe','map01299.spe'}
%               If full path is given for a file, then that overides the path in spedir
%              for that file.
%
%   spefileout  Name of spe file to contain the overall sum e.g. 'map01234_99.spe'
%               Default: place in the directory spedir if a full path is not given


mess='';

% Check the input parameters
% -----------------------------
% Check weights are numeric
if ~isnumeric(weight)
    mess='weights must be a numeric array';
    return
end

% Check default directory exists
if isempty(spedir)
    spedir='';
elseif ~ischar(spedir)||~length(size(spedir))==2||~size(spedir,1)==1
    mess='Default directory must be a character string';
    return
else
    if ~exist(spedir,'dir')
        mess=['Default directory for .spe files does not exist (',spedir,')'];
        return
    end
end
    
% Check input files form a cell array of strings, construct full path for each file, and check they exist
if ~iscellstr(spefiles)
    mess='.spe file names must be a cell array of form {''file_1.spe'',''file2.spe'',...}';
    return
else
    for i=1:numel(spefiles)
        if isempty(spefiles{i})||~length(size(spefiles{i}))==2||~size(spefiles{i},1)==1
            mess='.spe file names must be a cell array of form {''file_1.spe'',''file2.spe'',...}';
            return
        else
            filepath=fileparts(spefiles{i});
            if isempty(filepath)
                spefiles{i}=fullfile(spedir,spefiles{i});
            end
            if ~exist(spefiles{i},'file')
                mess=['Cannot find input .spe file ',spefiles{i}];
                return
            end
        end
    end
end

% Check number of weights and spefiles are inconsistent
if numel(weight)~=numel(spefiles),
    mess=[num2str(numel(weight)),' weights not consistent with ',num2str(numel(spefiles)),' spe files given.'];
    return
end

% Check output file name is OK, and construct full path if required
if isempty(spefileout)||~ischar(spefileout)||~length(size(spefileout))==2||~size(spefileout,1)==1
    mess='Output file name must be a character string';
    return
else
    filepath=fileparts(spefileout);
    if isempty(filepath)
        spefileout=fullfile(spedir,spefileout);
    else
        if ~exist(filepath,'dir')
            mess=['Output directory for .spe file does not exist (',filepath,')'];
            return
        end
    end
end


% Parse input
% ------------
% Check consistency of spe files - do this on header, to save reading in vast amounts of data and then failing.
for i=1:numel(spefiles)
    [tmp,ok,mess]=get_spe_header(spefiles{i});
    if ok
        if i==1
            header=tmp;
        else
            if header.ndet~=tmp.ndet
                mess='Number of detectors not all the same'; return
            elseif numel(header.en)~=numel(tmp.en)
                mess='Number of energy bins not all the same'; return
            elseif header.en~=tmp.en    % might generalise to accept a certain tolerance
                mess='Energy bin boundaries not all the same'; return
            end
        end
    else
        return
    end
end
clear header tmp


% Add spe files, one at a time
% ------------------------------
% Accumulate signal
for i=1:numel(weight)
    [data,ok,mess]=get_spe(spefiles{i});    % get_spe puts signal=NaN for null data (August 2009)
    if ~ok,
        mess=['Could not read .spe file ',spefiles{i}]; return
    end
    ok_pix=~isnan(data.S);	% true where pixel has data and false where detector has 'nulldata' in current data set
    if i==1     % first time, so initialise output en, S, ERR2
        ne = size(data.S,1);
        ndet=size(data.S,2);
        en=data.en;
        cumm_ok_pix = ok_pix;                       % cumulative OK pixels: 1 (data) 0 (nulldata) for all files loaded so far
        cumm_S = weight(i)*data.S;
        cumm_ERR2 = (weight(i)^2)*(data.ERR.^2);
    else
        cumm_ok_pix = cumm_ok_pix & ok_pix;
        cumm_S = cumm_S + weight(i)*data.S;
        cumm_ERR2 = cumm_ERR2 + (weight(i).^2)*(data.ERR.^2);
    end
    % Information about unmasked detectors and bad pixels
    % ----------------------------------------------------
    % For the current file
    masked_detector=all(~ok_pix,1);     % detector is masked if all pixels are null
    ndet_ok=sum(~masked_detector);      % number of unmasked detectors
    npix_bad=sum(reshape(~ok_pix(:,~masked_detector),[ne*ndet_ok,1]));   % number of bad pixels in unmasked detectors
    disp(sprintf('Current file masked detectors %d; other bad pixels %d',(ndet-ndet_ok),npix_bad));
    
    % For accumulated file
    masked_detector=all(~cumm_ok_pix,1);% detector is masked if all pixels are null
    ndet_ok=sum(~masked_detector);      % number of unmasked detectors
    npix_bad=sum(reshape(~cumm_ok_pix(:,~masked_detector),[ne*ndet_ok,1]));   % number of bad pixels in unmasked detectors
    disp(sprintf('     Overall masked detectors %d; other bad pixels %d',(ndet-ndet_ok),npix_bad));
    disp(' ')

end
clear data  % clear data so can recycle in output

% Normalise and scale data for output
data.filename='';
data.filepath='';
data.S=cumm_S;
data.ERR=sqrt(cumm_ERR2);
data.en=en;

data.S(~cumm_ok_pix)=NaN;
data.ERR(~cumm_ok_pix)=0;


% Save accumulated data
save(spe(data),spefileout);
