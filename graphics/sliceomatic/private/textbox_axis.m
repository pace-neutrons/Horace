function textbox_axis(handle, type, textb)
% DJW 18/6/2007 - added fig and type to input arguments so handle can be
% used as callback. 

% THIS code will only work within libisis - can use gcf instead when
% outside libisis, this allows better control though. 

% *** Replace:
% [fig, axes, plot, other] = ixf_get_related_handles(handle);
% *** with:
fig=handle;

d=getappdata(fig,'sliceomatic');
switch textb
    case 'XNew'
 %       disp(['X text box pressed'])
        h=findobj(fig,'Tag','slice_u1');
        strval=get(h, 'string');
        val=str2num(strval);
        if val<=d.xlim(2) & val>=d.xlim(1)
            sliceomatic('XnewText',val);
        else
            disp(['Error in Input'])
        end
    case 'YNew'
 %       disp(['Y text box pressed'])
        h=findobj(fig,'Tag','slice_u2');
        strval=get(h,'String');
        val=str2num(strval);
        if val<=d.ylim(2) & val>=d.ylim(1)
            sliceomatic('YnewText',val);
        else
            disp(['Error in Input'])
        end
    case 'ZNew'
%        disp(['Z text box pressed'])
        h=findobj(fig,'Tag','slice_u3');
        strval=get(h,'String');
        val=str2num(strval);
        if val<=d.zlim(2) & val >= d.zlim(1)
            sliceomatic('ZnewText',val)
        else
            disp(['Error in Input'])
        end
    case 'ISONew1'
        h=findobj(fig,'Tag','iso_1');
        strval=get(h,'String');
        val=str2num(strval);
% ------------------------------------------------------
% *** TGP, 28 July 2005: replaced the following:
%         if val<=(max(max(max(d.data)))) & val >= min(min(min(d.data))) &(val  < d.clim(1,2))
%             sliceomatic('ISONew1',[val,d.clim(1,2)])
%         else
%             disp(['Error in input'])
%             set(h,'String',d.clim(1,1))
%         end
% *** with:
        if ~isempty(val)
            if val < d.clim(1,2)
                sliceomatic('ISONew1',[val,d.clim(1,2)])
            else
                disp(['Error in input - must be less than current maximum intensity setting'])
                set(h,'String',d.clim(1,1));
            end
        elseif isempty(strval)  % reset limits to data range
            c_lo = min(min(min(d.data)));
            c_hi = max(max(max(d.data)));
            set(h,'String',c_lo)
            h = findobj(fig,'Tag','iso_2');
            set(h,'String',c_hi)
            sliceomatic('ISONew1',[c_lo,c_hi])
        else
            disp(['Error in input'])
            set(h,'String',d.clim(1,1))
        end

   case 'ISONew2'
        h=findobj(fig,'Tag','iso_2');
        strval=get(h,'String');
        val=str2num(strval);
           
%         if val<=(max(max(max(d.data)))) & val >= min(min(min(d.data))) &(val > d.clim(1,1))
%             sliceomatic('ISONew2',[d.clim(1,1),val])
%         else
%             disp(['Error in input'])
%             set(h,'String',d.clim(1,2))
%         end

        if ~isempty(val)
            if val > d.clim(1,1)
                sliceomatic('ISONew1',[d.clim(1,1),val])
            else
                disp(['Error in input - must be greater than current minimum intensity setting'])
                set(h,'String',d.clim(1,2));
            end
        elseif isempty(strval)  % reset limits to data range
            c_lo = min(min(min(d.data)));
            c_hi = max(max(max(d.data)));
            set(h,'String',c_hi)
            h = findobj(fig,'Tag','iso_1');
            set(h,'String',c_lo)
            sliceomatic('ISONew2',[c_lo,c_hi])
        else
            disp(['Error in input'])
            set(h,'String',d.clim(1,2))
        end

end
