% Test changes to functions

%% =============================================================================
% Create data

data_rbmnf3 = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';
data_fe = 'D:\data\Fe\sqw_Toby\Fe_ei787.sqw';

proj_110 = projaxes([1,1,0],[0,0,1]);
w1 = cut_sqw(data_rbmnf3,proj_110,[0.45,0.55],[-0.5,0.01,1.5],[-0.05,0.05],[5,0,6],'-pix');

proj_100 = projaxes([1,0,0],[0,1,0]);
w2 = cut_sqw (data_fe, proj_100, 0.05, 0.05, [-0.02,0.02], [150,160], '-pix');

proj_110 = projaxes([1,1,0],[0,0,1]);
ww1 = cut_sqw(data_rbmnf3,proj_110,[0.45,0.55],[-0.5,0.01,1.5],[-0.05,0.05],[-2,0,12],'-pix');

proj_100 = projaxes([1,0,0],[0,1,0]);
ww2 = cut_sqw (data_fe, proj_100, 0.05, 0.05, [-0.1,0.1], [150,170], '-pix');



%% =============================================================================
% Test equivalence of tobyfit_DGfermi_res_init and tobyfit_DGfermi_resconv_init

[ok_ref,mess_ref,lookup_ref] = testgateway_tobyfit(sqw, 'tobyfit_DGfermi_resconv_init',{w1,w2});

[ok_ref,mess,lookup] = testgateway_tobyfit(sqw, 'tobyfit_DGfermi_res_init',{w1,w2});

if ~isequal(lookup_ref,lookup)
    tmp = {rmfield(lookup{1},{'moderator','aperture','chopper'})};
    if ~isequal(lookup_ref,tmp)
        error('Aarghh!')
    end
end



%% =============================================================================
% Tests

[ok_ref,mess,lookup] = testgateway_tobyfit(sqw, 'tobyfit_DGfermi_res_init',[w1,w2],35);


[ok_ref,mess,lookup,npix] = testgateway_tobyfit(sqw, 'tobyfit_DGfermi_res_init',[w1,w2],{35,(30:40)'});


