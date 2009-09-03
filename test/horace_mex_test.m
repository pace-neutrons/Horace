function error_list=horace_mex_test(varargin)
% function runs tests of all mex files, generated for Horace
%
% usage:
% error_list=horace_mex_test(spe_file_name) 
% or
% error_list=horace_mex_test(spe_file_name,'full')
%
% Parameters:
% spe_file_name  -- the name of the spe file to test the spw files
%                   generation if not present, 
%
% 'full'        -- it second parameter is present, and equal 'fill' the function checks mex files results
%                  with the results, obtained from matlab calculations (slow)
nTests = 1;     % number of tests enabled

error_list=cell(nTests,1);
%% TEST DIFFERENT PARTS OF "gen_sqw()
% 
%% get par file

try %using fortran routine
    par1=get_par_fortran(par_file_name);
catch %using matlab routine
     error_list{1} = ' get_par_fortran failed';
end
 par2=get_par_matlab(par_file_name);

%% calculate projections:
c=get_neutron_constants;
k_to_e = c.k_to_e; % picked up by calc_proj_c;

% Convert to projection axes 

% Calculate Q in spectrometer coordinates for each pixel 
try     % using ? routine
    error(' use matlab')
    mem = horace_memory();
    nThreads=mem.threads; % picked up by calc_proj_c;

    ucoords =calc_projections_c(spec_to_proj,data, det,efix, k_to_e,emode,nThreads);
catch   %using matlab routine
    warning('Problem with C-code compilation: using calc_proj_matlab.m');   
    qspec = calc_qspec (efix, k_to_e,emode, data, det);      
%    ucoords = calc_proj_matlab (spec_to_proj, qspec);
    ucoords = spec_to_proj*qspec(1:3,:);
    ucoords = [ucoords;qspec(4,:)];   
end    
%      for i=1:size(ucoords,2)
%          if(sum(abs(ucoords(:,i)-ucoords1(:,i)))>1.e-6)
%              msg=sprintf(' difference for el N %d ,e1: %e %e %e %e; e2:%e %e %e %e',i,ucoords(:,i),ucoords1(:,i));
%              disp(msg);
%          end
%      end
%      disp(' comparison completed');


