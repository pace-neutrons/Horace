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
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
deflate_data=false;
if(~this.data_loaded)
    this=read(this,fullfile(this.fileDir,[this.fileName,this.fileExt]));   
    deflate_data=true;    
end

% TGP 16Jan 2011: replace line:  if isfield(this,'spe') % when it works?  with:
if any(strcmp(fields(this),'spe')) % isfield will return false if this is not explicitly a structure, which is impossible...
    data.S        = this.spe.S;
    data.ERR      = this.spe.ERR;
    data.en       = this.spe.en;
    data.filename = this.fileName;
    data.filepath = this.fileDir;    
    [ne,ndet]     = size(data.S);
    disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);
    if(deflate_data)
        this=deflate(this);
    end    
    % HACK -- if the structure is real speData, then this works, if not --
    % we are in spe despite calling this function on SPE data; How to deal
    % with that? unclear;
    if ~isempty(getEi(this))
     data.Ei = getEi(this);
    end
    if ~isempty(getPar(this))
        data.par = getPar(this);
    end    
else
    data.S        = this.S;
    data.ERR      = this.ERR;
    data.en       = this.en;   
    data.filename = this.filename;
    data.filepath = this.filepath;    
    if isfield(this,'Ei')
        if ~isnan(this.Ei)
            data.Ei=this.Ei;
        end
    end
    
end




