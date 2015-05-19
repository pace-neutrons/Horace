function colorslider_command(figureHandle_,cmd)
% Perform functions with colorslider

% Based on Libisis function ixf_color_slider which in turn is based on mslice
% function color_slider_ms.m
%
% T.G.Perring queries (28/3/11):
% *** Reasons to question some of the robustness e.g. trapping NaN in case of
%     options 'min' and 'max' - compare original mslice code.

slider_min=findobj(figureHandle_,'Tag','color_slider_min');
slider_min_value=findobj(figureHandle_,'Tag','color_slider_min_value');
slider_max=findobj(figureHandle_,'Tag','color_slider_max');
slider_max_value=findobj(figureHandle_,'Tag','color_slider_max_value');

i_min=get(slider_min,'Value');
i_max=get(slider_max,'value');
switch cmd
    
    case 'slider_max'
        % === slider move, top
        if i_max==i_min % do not change i_max if range becomes 0
            i_min = i_max - 0.01;
        end
        
    case 'slider_min'
        if i_max == i_min
            i_max = i_min + 0.01;
        end
        
    case 'min'
        % Only change i_min if numeric value entered and would not make range=0
        temp=get(slider_min_value,'String');
        if str2double(temp)==i_max % do not change i_min if range becomes 0
            i_min=get(slider_min,'value');
        else
            i_min=str2double(temp);
        end
        
    case 'max'
        % only change i_max if numeric value entered and would not make range=0
        temp = get(slider_max_value,'String');
        if str2double(temp)==i_max % do not change i_min if range becomes 0
            i_max=get(slider_min,'value');
        else
            i_max=str2double(temp);
        end
        
    otherwise
        disp('Unknown slider command. Return.');
        return;
        
end

temp=min(i_min,i_max);
i_max=max(i_min,i_max);
i_min=temp;
c_bar=findobj(figureHandle_,'Tag','Colorbar');
if verLessThan('matlab','8.4')
    if ~strcmp(get(c_bar,'YScale'),'linear')
        return
    end
end

caxis([i_min i_max]);
range=abs(i_max-i_min);
set(slider_min,'Min',i_min-range/2,'Max',i_max-range*0.1,'Value',i_min);
set(slider_max,'Min',i_min+range*0.1,'Max',i_max+range/2,'Value',i_max);
set(c_bar,'YLim',[i_min i_max]);
set(get(c_bar,'Children'),'YData',[i_min i_max]);
i_min_round = truncdig(i_min,3);
i_max_round = truncdig(i_max,3);
set(slider_min_value,'String',num2str(i_min_round));
set(slider_max_value,'String',num2str(i_max_round));
%end
