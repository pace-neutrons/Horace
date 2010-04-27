function one_sqw=select_pixels_hyperslab(one_sqw,dims,chunks,varargin)
% select a hyperslab of hdf5 data on an Hdd for future IO operations
%usage:
%   this=select_pixels_hyperslab(this,dims,chunks,npix)
% or
%   this=select_pixels_hyperslab(this,dims,chunks)
%
%
% where:
% dims   -- the dimensionality of the data (dnd object) on hdd
% chunks -- 
%      is either 
%           an MxN array of cells coordinates with M is the dimensionality
%           of the dnd object and N-- number of cells to select and optionql sqw_data
%      or
%           1D representation of such array (obtained e.g. by applying e.g. sub2ind
%           function)
%      N  - has to be equal to the number of pixels selected to write from
%           the memory (when using hdf5 write routines)
%
% npix -- if present is the array with information about number of pixels in each cell. 
%
%         if one_sqw.pixel_dataspace_layout is undefined,
%         this informaion is used to calculate the pixel datset layout in
%         the dataset file assuming that the dataset in the file has only
%         the data, speficied by npix;
%  
%  side effects:
%         calculates pixel dataspece layout if it is not calculated before and
%         data to calculate it are present; if it is empty and data are not
%         present, error is thrown. 
% 
%
% $Revision$ ($Date$)
%
% *** > have not been tested for 1D(0D?) object
%
if nargin<3 || nargin>4
%if nargin~=4
    help select_pixels_hyperslab
    error('HORACE:hdf_tools','select_pixels_hyperslab=> called with wrong number of arguments')
end
 if nargin==3
     if isempty(one_sqw.pixel_dataspace_layout)
         error('HORACE:hdf_tools','select_pixels_hyperslab=>calling short form of the function needs pixel_dataspace_layout to be defined')
     end
     
     ll         = numel(one_sqw.pixel_dataspace_layout);
     % the information on hdd equivalent to 
     cell_sizes = one_sqw.pixel_dataspace_layout(2:ll)-one_sqw.pixel_dataspace_layout(1:ll-1);
 end
if nargin==4
    npix         = varargin{1};
    cell_sizes   = reshape(npix,1,numel(npix));
    
    if isempty(one_sqw.pixel_dataspace_layout)
        one_sqw=build_pixel_dataspace_layout(one_sqw,npix);
    end    
    clear npix;
end


% calculate vectors indicating the location of pixels, selected by
% chunks, e.g. start position and 
% the size of the blocks of of pixels, selected by the array of chunks. 
%
    rank = numel(dims);
    if rank == size(chunks,1)   
        layout(1)=1;
        layout(2:rank+1)=cumprod(dims);

        cell_indexes = (chunks'*layout(1:rank)')'; % chunks start from 0  but Matlab arrays from 1;
    else
        if numel(chunks)==size(chunks,2)
            chunks=chunks';
        end
        if size(chunks,2)==1
            cell_indexes= chunks;
        else
            error('HORACE:hdf_tools','the size of data chunks do not agree with the dimensions of sqw object');    
        end
    end        
    cell_starts = one_sqw.pixel_dataspace_layout(cell_indexes); % hdf cells adresses start from 0 and this has to be reflected in the layout; 
    
    cell_sizes   = cell_sizes(cell_indexes);


    if ~all(cell_sizes)
        non_empty_cells  = (cell_sizes~=0);    
        cell_starts      = cell_starts(non_empty_cells);
        cell_sizes       = cell_sizes(non_empty_cells);
    end
   
%
% start hdf selection:       
selection_size  = sum(cell_sizes);
selection_array = zeros(selection_size,1);
one_sqw.pixes_selection_size=selection_size;

i=1;
ic=1;
while i<selection_size
    selection_array(i:(i+cell_sizes(ic)-1))  =cell_starts(ic):(cell_starts(ic)+cell_sizes(ic)-1);
    i=i+cell_sizes(ic);
    ic=ic+1;
end
H5S.select_elements(one_sqw.pixel_Space, 'H5S_SELECT_SET',fliplr(selection_array));



