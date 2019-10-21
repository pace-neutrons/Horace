function efix = check_efix_defined_correctly(this)
% get efix value defined by the class or message
% why it is not defined
%
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%

if isempty(this.loader__)
    efix = this.efix__;
else
    if ismember('efix',this.loader__.defined_fields())
        efix = this.loader__.efix;
    else
        efix = this.efix__;
    end
end

if isempty(efix)
    return;
end
if isempty(this.en)
    return
end
histo_mode = true;
if ~isempty(this.S)
    nen = size(this.S,1);
    if nen == numel(this.en) || numel(this.en)<2
        histo_mode = false;
    end
end

if this.emode == 1
    if histo_mode
        bin_bndry = 0.5*(this.en(end)+this.en(end-1));
    else
        bin_bndry = this.en(end);
    end
    if (efix<bin_bndry)
        efix = sprintf('Emode=1 and efix incompartible with max energy transfer, efix: %f max(dE): %f',efix,bin_bndry);
    end
elseif this.emode == 2
    efix_min = min(efix);
    if histo_mode
        bin_bndry = 0.5*(this.en(1)+this.en(2));
    else
        bin_bndry = this.en(1);
    end
    
    
    if efix_min+bin_bndry<0
        efix = sprintf('Emode=2 and efix is incompartible with min energy transfer, efix: %f min(dE): %f',efix,bin_bndry);
    end
else
    efix = 'no efix for elastic mode';
end
