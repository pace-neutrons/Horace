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
[PAR,PHX,SPE,PROJ_F,PROJ_C,BIN_PIXELS,ACCUM_CUT,SORT_PIXELS]=deal(1:8);
%
nTests = 8;     % number of tests enabled
error_list=cell(2,nTests); % first cell -- test name, second cell -- test state
%

error_list{1,PAR}         = 'get_par_fortran test';
error_list{1,PHX}         = 'get_phx_fortran test'; % where it is?
error_list{1,SPE}         = 'get_spe_fortran test';
error_list{1,PROJ_F}      = 'calc_proj_fortran test';
error_list{2,PROJ_F}      = 'test disabled as currently more comprehensive test exists for PROJ_C';
error_list{1,PROJ_C}      = 'calc_proj_c test';
error_list{1,BIN_PIXELS}  = 'bin_pixels_c test';
error_list{1,ACCUM_CUT}   = 'accumulate_cut_c test';
error_list{1,SORT_PIXELS} = 'sort_pixels_by_bin_c test';


%% TEST DIFFERENT PARTS OF "gen_sqw()
% 
%% get par file

try %using fortran routine
    par1=get_par_fortran(par_file_name);
catch %using matlab routine
     error_list{1,1} = ' get_par_fortran failed';
end
 par2=get_par_matlab(par_file_name);
%% get spe file
       try
            [this.S,this.ERR,this.en] = get_spe_fortran(fullFileName);
            this.data_loaded=true;
        catch
            warning(' can not read data using fortran routines -- reverted to Matlab')
            [this.S,this.ERR,this.en] = get_spe_matlab(fullFileName);
            this.data_loaded=true;
        end

 
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
      for i=1:size(ucoords,2)
          if(sum(abs(ucoords(:,i)-ucoords1(:,i)))>1.e-6)
              msg=sprintf(' difference for el N %d ,e1: %e %e %e %e; e2:%e %e %e %e',i,ucoords(:,i),ucoords1(:,i));
              disp(msg);
          end
      end
      disp(' comparison completed');

%% Check bin pixels
try
%    error(' use matlab');
   % verify the grid consistency and build axis along the grid dimensions, c-program does not check the grid consistency;
   if size(urange,2)~=4
       error('Check size of urange - added by TGP who removed 3rd argument nd to construct_grid_size')
   end
    [grid_size,sqw_data.p]=construct_grid_size(grid_size_in,urange);
    mem = horace_memory();
%    nThreads=mem.threads; % picked up by bin_pixels_c directly;  
    nThreads=mem.threads; % picked up by bin_pixels_c directly;
%    nThreads=1; % picked up by bin_pixels_c directly;
%   sets this fields in-place: [sqw_data.pix,sqw_data.s,sqw_data.e,sqw_data.npix]=bin_pixels_c(sqw_data,urange,grid_size);
%  ************** !!! DANGEROUS !!! ***********************************
%   bin_pixels_c modifies data in-place saving memory but
%   if one saved sqw_data or any of its fields in an array before or after
%   this, both arrays will be modified (untill disjoined)
% %     [scratch, sort_in_place]=bin_pixels_c(sqw_data,urange,grid_size); % not implemented yet
% %     if(~sort_in_place)
% %         sqw_data=scratch;
% %     end
%    error(' use matlab')
%   sqw_data1=sqw_data;
   bin_pixels_c(sqw_data,urange,grid_size);
%  ************** !!! DANGEROUS !!! ***********************************
%
% write_results_to_aFile('c_data.dat');

 catch
    warning(' problem with C-routine to rebin data, using matlab fucntions');
    [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
    sqw_data.pix=sqw_data.pix(:,ix);
    sqw_data.p=p;
    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
    sqw_data.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalise data

    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalise variance
    clear ix ibin   % biggish arrays no longer needed
    nopix=(sqw_data.npix==0);
    sqw_data.s(nopix)=0;
    sqw_data.e(nopix)=0;
%    write_results_to_aFile('data_difr.dat');
%    wff('diffMat.dat');

    clear nopix     % biggish array no longer needed
end
%% Calculate projections
% Calculate Q in spectrometer coordinates for each pixel 
try     % using ? routine
%    error(' use matlab')
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
%% Accumulate cut
try
%   throw(' use matlab');
%[urange_step_pix_recent, ok, ix,s1,e1,npix1]=accumulate_cut_c(v,s,e,npix,...
%                                         rot_ustep,trans_bott_left,ebin,trans_elo,...
%                                          urange_step,pax,parameters);
 % if s, e and npix are not present as the output arguments, ([urange_step_pix_recent, ok, ix, {s, e, npix}]) 
% they will be modified on-place to avoid copying !!!! it is dangerous !!! 
[urange_step_pix_recent, ok, ix]=accumulate_cut_c(v,s,e,npix,...
                                         rot_ustep,trans_bott_left,ebin,trans_elo,...
                                         urange_step,pax,parameters);
                                     
urange_step_pix =[min(urange_step_pix(1,:),urange_step_pix_recent(1,:));max(urange_step_pix(2,:),urange_step_pix_recent(2,:))];  % true range of data
npix_retain     = size(ix,1);
catch
 if horace_info_level>=1   
      warning(' Can not accumulate_cut using C routines; using Matlab');
 end
  [s, e, npix, urange_step_pix, npix_retain, ok, ix] = accumulate_cut_matlab (s, e, npix, urange_step_pix, keep_pix,...
                                                         v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
end
%% sort_pixels_by_bin
               try
                 clear v ok ix_add    % clear big arrays
                 pix = sort_pixels_by_bins(pix,ix,npix);
                 clear ix    % clear big arrays 
                catch
                    if horace_info_level>=1
                        warning(' can not sort_pixels_by_bins using c-routines, using Matlab')
                    end
                    [ix,ind]=sort(ix);  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
                    clear ix v ok ix_add    % clear big arrays so that final output variable pix is not way up the stack
                    pix=pix(:,ind);         % reorders pix
                end


end
%%
    function wff(fileName)
          fid = fopen(fileName,'w+');
      for ie=30:31
          for iz=24:47
              for iy=20:40
                  for iix=20:50
                        fprintf(fid, ' %f',sqw_data.npix(iix,iy,iz,ie)-sqw_data1.npix(iix,iy,iz,ie));
                  end
                  fprintf(fid, '\n');
               end
           end
      end
     fclose(fid);


    end
    function write_results_to_aFile(fileName)
      fid = fopen(fileName,'w+');
      Sum=0;
      for ie=1:size(sqw_data.s,4)
          for iz=1:size(sqw_data.s,3)
              for iy=1:size(sqw_data.s,2)
                  for iix=1:size(sqw_data.s,1)
                      if(abs(sqw_data.npix(iix,iy,iz,ie)-sqw_data1.npix(iix,iy,iz,ie))>1e-6)
                        fprintf(fid, 'ind: | %d %d %d %d | n1= %f | n2= %f !! s1= %f | s2= %f\n',...
                                  iix,iy,iz,ie,...
                                  sqw_data.npix(iix,iy,iz,ie),sqw_data1.npix(iix,iy,iz,ie),...
                                  sqw_data.s(iix,iy,iz,ie),sqw_data1.s(iix,iy,iz,ie)...                                  
                              );

                      end
                   end
               end
           end           
      end
       fprintf(fid,'N-pixels: %f',Sum);
       fclose(fid);        
        
    end
