function  test_nested_sort_struct()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

np = 1:6;
spe_file = arrayfun(@(x)(['test_spe_file',num2str(7-x)]),np,'UniformOutput',false)';
efix = ones(6,1)*45;
psi = [1:2:12]';
omega = zeros(6,1);
dpsi = zeros(6,1);
gl = zeros(6,1);
gs = zeros(6,1);

pstruct=struct('filename',spe_file,'efix',num2cell(efix),...
    'psi',num2cell(psi),'omega',num2cell(omega),'dpsi',num2cell(dpsi),'gl',num2cell(gl),'gs',num2cell(gs));

names=fieldnames(pstruct)';     % row vector

% Sort structure array

ERR = struct('message','');
try
    [pstruct_sort,indp]=nestedSortStruct(pstruct,names);
    pass = true;
catch ERR
    pass = false;
end
assertTrue(pass,ERR.message);
assertEqual(indp,[6:-1:1]')
assertEqual(pstruct_sort(1).filename,'test_spe_file1');
assertEqual(pstruct_sort(1).psi,11);

