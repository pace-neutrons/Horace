function [ok,message,wout] = checkfields (w, mspec_ok)
% Check validity of all fields for an object
%
%   >> [ok, message, wout] = checkfields (w)
%
% Input:
% ------
%   w           Structure or object of the class
%       units           Valid units code or cell array of units codes
%       IX_dataset_2d   IX_dataset_2d or array of IX_dataset_2d
%       tofpar          Time-of-flight parameters object or array of objects
%
%   mspec_ok    =true then multiple spectra can be provided. For use by constructor
%               but not allowed in get or set methods.
%
% Output:
% -------
%   ok          ok=true if valid, =false if not
%   message     Message if not a valid object, empty string if is valid.
%   wout        Output structure or object of the class
%               wout can be an altered version of the input structure or object that must
%               have the same fields. For example, if a column array is provided for a field
%               value, but one wants the array to be a row, then checkfields could take the
%               transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
%
%  
%       units           Units code if single spectrum; or structure array with field 'units', with one element
%                      per spectrum, with same shape as the array of IX_dataset_2d.
%       IX_dataset_2d   IX_dataset_2d or array of IX_dataset_2d, updated to have captions matching units codes
%       tofpar          Array of time-of-flight parameter objects, one per spectrum, with same shape as the
%                      array of IX_dataset_2d.

% Original author: T.G.Perring

fields = {'units';'IX_dataset_2d';'tofpar'};

ok=false;
message='';
wout=w;

if nargin==1
    mspec_ok=false;
end
    
if isequal(fieldnames(w),fields)
    % Check spectra
    if isa(wout.IX_dataset_2d,'IX_dataset_2d') && ~isempty(wout.IX_dataset_2d)
        nspec=numel(wout.IX_dataset_2d);
        if nspec>1 && ~mspec_ok
            message='Single dataset only is allowed'; return
        end
        for i=1:nspec
            [dummy,sz]=dimensions(wout.IX_dataset_2d(i));
            if sz(2)~=1
                message='Every dataset must contain the data for a single spectrum'; return
            end
            if ~ishistogram(wout.IX_dataset_2d(i),1)
                message='Every dataset must be a histogram spectrum'; return
            end
            if ~wout.IX_dataset_2d(i).x_distribution
                message='Every dataset must be a distribution'; return
            end
        end
    else
        message='Must provide one or more spectra'; return
    end
    
    % Check par
    if isa(wout.tofpar,'tofpar')
        npar=numel(wout.tofpar);
        if npar==1 && nspec>1
            wout.tofpar=repmat(wout.tofpar,size(wout.IX_dataset_2d));
        elseif npar~=1 && npar==nspec
            wout.tofpar=reshape(wout.tofpar,size(wout.IX_dataset_2d));
        elseif npar~=1 && npar~=nspec
            message='Check number of time-of-flight parameter objects'; return
        end
    else
        message='Must provide time-of-flight parameter object(s)'; return
    end
    
    % Check units
    [ok_units,wout.units]=str_make_cellstr(wout.units);
    if ok_units
        wout.units=lower(wout.units);
        nunits=numel(wout.units);
        if nunits==1 && nspec>1
            wout.units=repmat(wout.units,size(wout.IX_dataset_2d));
        elseif nunits~=1 && nunits==nspec
            wout.units=reshape(wout.units,size(wout.IX_dataset_2d));
        elseif nunits~=1 && nunits~=nspec
            message='Check number of units codes'; return
        end
        if npar==1 && nunits==1     % scalar input for both
            [ok_valid_units,xlab,xunit]=units_to_caption(wout.units(1),wout.tofpar(1).emode);
            if nspec>1
                xlab=repmat(xlab,size(wout.IX_dataset_2d));
                xunit=repmat(xunit,size(wout.IX_dataset_2d));
            end
        else                        % one or both of units and tofpar was an array length number of spectra
            if npar==1
                emode=repmat(wout.tofpar(1).emode,size(wout.IX_dataset_2d));
            else
                emode=zeros(size(wout.IX_dataset_2d));
                for i=1:npar
                    emode(i)=wout.tofpar(i).emode;
                end
            end
            [ok_valid_units,xlab,xunit]=units_to_caption(wout.units,emode);
            ok_valid_units=all(ok_valid_units);
        end
        if ~ok_valid_units
            message='Check units code(s) is/are valid and consistent with emode in the time-of-flight parameter set(s)'; return
        end
        % Set units field to values suitable for use in class constructor and get/set routines
        if nspec==1
            wout.units=wout.units{1};
        else
            wout.units=reshape(cell2struct(wout.units(:),'units',2),size(wout.IX_dataset_2d));
        end
    else
        message='Units code(s) must be character strings or cell array of character strings'; return
    end
    
    % Set captions of spectra
    for i=1:numel(wout.IX_dataset_2d)
        wout.IX_dataset_2d(i).x_axis=IX_axis(xlab{i},xunit{i});    % *** crying out for a set_simple
    end
    
else
    message='Fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
