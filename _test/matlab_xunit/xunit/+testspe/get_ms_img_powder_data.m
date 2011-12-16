function output_data = get_ms_img_powder_data(input_data,u,emode,analmode)
% function simulates reading input data necessay for powder plots
% from mslice interface
%
%
output_data =input_data;
if numel(u)~=2||min(u)<1||max(u)>4||u(1)==u(2)
    error('GET_MS_IMG_POWDER_DATA:invlid_argument',' u has to be 2-element vector with axis numbers form 1 to 4');    
end

output_data.u=u;

output_data.emode=emode;
output_data.axis_label=['a';'b'];
output_data.axis_unitlabel=['1';'2';'3'];
output_data.efixed=input_data.Ei;
output_data.analmode=analmode;
output_data.title_label='test_powder_img';


