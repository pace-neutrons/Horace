function isisraw=gget_init
% Initialises names for fields in the ISIS RAW file format
%
%   >> gget_init

% Names given to elements of array fields (for ease of access: e.g. uA.hr is otherwise RRPB(8) !)
% ------------------------------------------------------------------------------------------------
% Header section: (user_name is not extracted, as is part of RUN section too)
hdr.name={'rid','short_title','start_date','start_time','ua_hours'};
hdr.begin=[1;29;53;65;73];
hdr.end  =[8;52;63;72;80];  % we make start_date have only 11 characters, not 12 (for consistency with end_date)

% Run section:
run.name={'user_name','user_day1','user_day2','user_night','user_inst',...
                  'run_duration','run_scalar','good_charge','total_charge','good_frames','total_frames','end_date','end_time'};
run.raw_name={'user','user','user','user','user',...
                      'irpb','irpb','rrpb','rrpb','irpb','irpb','crpb','crpb'};
run.index = [1,2,3,4,5,...
                     1,2,8,9,10,11,17,20];
   
             
% Valid raw file field names (including names for mixed type arrays) (Look after case of UTnn, SEnn, RSEnn and CSEnn in gget)
% -------------------------------------------------------------------
% valid names (assumes only one time channel boundary regime)
field.name={'hdr', 'ver1', 'add', 'form',...
'ver2','run', 'titl', 'user', 'rpb', 'irpb', 'rrpb', 'crpb',...
'ver3', 'name', 'ivpb', 'rvpb', 'ndet', 'nmon', 'nuse', 'mdet', 'monp', 'spec', 'delt', 'len2', 'code', 'tthe',... 
'ver4', 'spb', 'ispb', 'rspb', 'cspb', 'nsep', 'se01', 'rse01', 'cse01',...
'ver5', 'daep', 'crat', 'modn', 'mpos', 'timr', 'udet',...
'ver6', 'ntrg', 'nfpp', 'nper', 'pmap', 'nsp1', 'ntc1', 'tcm1', 'tcp1', 'pre1', 'tcb1',...
'ver8', 'cnt1'};


% Fill up fields in global variable
% ---------------------------------
isisraw.hdr=hdr;
isisraw.run=run;
isisraw.field=field;
