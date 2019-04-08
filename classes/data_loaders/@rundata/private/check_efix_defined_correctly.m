function efix = check_efix_defined_correctly(this)
% get efix value defined by the class or message
% why it is not defined
%
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
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


if this.emode == 1
    bin_bndry = this.en(end);
    if (efix<bin_bndry)        
        efix = sprintf('Emode=1 and efix incompartible with max energy transfer, efix: %f max(dE): %f',efix,bin_bndry);
    end
elseif this.emode == 2
    bin_bndry = this.en(1);
    if efix+bin_bndry<0
        efix = sprintf('Emode=2 and efix is incompartible with min energy transfer, efix: %f min(dE): %f',efix,bin_bndry);
    end
else
    efix = 'no efix for elastic mode';
end
