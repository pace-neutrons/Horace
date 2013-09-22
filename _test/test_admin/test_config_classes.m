function test_config_classes
% Test basic functionality of configuration classes
%
%   > >test_config_classes

%banner_to_screen(mfilename)

% Set test config classes
set(test_config,'default');
set(test1_config,'default');
set(test2_config,'default');

% Get structure
conf=get(config);
s0_def=get(test_config);
s1_def=get(test1_config);
s2_def=get(test2_config);

% ----------------------------------------------------------------------------
% Test getting values from a configuration
% ----------------------------------------------------------------------------
s2_def_pub=get(test2_config,'-pub');
if ~isequal(fieldnames(s2_def_pub),{'v1';'v2'}) || ...
        ~isequal(s2_def.v1,s2_def_pub.v1) || ~isequal(s2_def.v2,s2_def_pub.v2)
    error('Problem with: get(test2_config,''-pub'')')
end

[v1,v3]=get(test2_config,'v1','v3');
if ~isequal(s2_def.v1,v1) || ~isequal(s2_def.v3,v3)
    error('Problem with: get(test2_config,''v1'',''v3'')')
end

% This should fail because V3 is upper case, but the field is v3
try
    [v1,v3]=get(test2_config,'v1','V3');
    ok=false;
catch
    ok=true;
end
if ~ok
    error('Problem with: get(test2_config,''v1'',''V3'')')
end

% This should fail because v3 is a sealed field
try
    [v1,v3]=get(test2_config,'v1','v3','-pub');
    ok=false;
catch
    ok=true;
end
if ~ok
    error('Problem with: get(test2_config,''v1'',''v3'',''-pub'')')
end


% ----------------------------------------------------------------------------
% Test ghanging values and saving
% ----------------------------------------------------------------------------
set(test2_config,'v1',-30);
s2_sav=get(test2_config);

% Change the config without saving, change to default without saving - see that this is done properly
set(test2_config,'v1',55,'-buffer');
s2_buf=get(test2_config);

set(test2_config,'def','-buffer');
s2_tmp=get(test2_config);

if isequal(s2_tmp,s2_buf)
    error('Error in config classes code')
end
if ~isequal(s2_tmp,s2_def)
    error('Error in config classes code')
end

% Change the config without saving, change to save values, see this done properly
set(test2_config,'v1',55,'-buffer');
s2_buf=get(test2_config);

set(test2_config,'save');
s2_tmp=get(test2_config);

if isequal(s2_tmp,s2_buf)
    error('Error in config classes code')
end
if ~isequal(s2_tmp,s2_sav)
    error('Error in config classes code')
end

% Try to alter a sealed field
try
    set(test2_config,'v4','Whoops!');
    ok=false;
catch
    ok=true;
end
if ~ok
    error('Error in config classes code')
end

% Try to alter a sealed field using root set method
try
    set(test1_config,'v3','Whoops!');
    ok=false;
catch
    ok=true;
end
if ~ok
    error('Error in config classes code')
end



% ----------------------------------------------------------------------------
% Success announcement
% --------------------
disp(' ')
disp('Tests passed')
disp(' ')
