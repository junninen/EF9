function varargout = EF9_gui(varargin)
% EF9_GUI MATLAB code for EF9_gui.fig
%      EF9_GUI, by itself, creates a new EF9_GUI or raises the existing
%      singleton*.
%
%      H = EF9_GUI returns the handle to a new EF9_GUI or the handle to
%      the existing singleton*.
%
%      EF9_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EF9_GUI.M with the given input arguments.
%
%      EF9_GUI('Property','Value',...) creates a new EF9_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EF9_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EF9_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EF9_gui

% Last Modified by GUIDE v2.5 16-Nov-2014 15:37:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EF9_gui_OpeningFcn, ...
    'gui_OutputFcn',  @EF9_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EF9_gui is made visible.
function EF9_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EF9_gui (see VARARGIN)

% Choose default command line output for EF9_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EF9_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global parPath

dcm_obj = datacursormode(handles.figure1);
set(dcm_obj,'UpdateFcn',@gui_text_disp_fun)


if isempty(varargin)
    %defaults
    set(handles.smth1_tm,'String',1)
    set(handles.smth1_dp,'String',5)
    
    set(handles.smth2_tm,'String',5)
    set(handles.smth2_dp,'String',9)
    
    %set(handles.lowLim,'String','EF9_lim_fun_cdf')
    %set(handles.limFun_par,'String','[1.1,8,9,4]')
    set(handles.RNPF_dur,'String',2)
    set(handles.RNPF_conc,'String',10)
    set(handles.lat,'String',61.85)
    set(handles.lon,'String',24.283)
    set(handles.timeZone_lon,'String',30)
    set(handles.upperLim,'String',15)
    set(handles.lowLim,'String',2)
    
    ef_param=struct(...
        'smoothing1_fun',[],...
        'smoothing1',[],...
        'smoothing2_fun',' ',...
        'smoothing2',[],...
        'lim_fun',[],...
        'lim_fun_par',[],...%min,max,mu,sigma. min max in log10(conc) and mu and sigma in bin_number (not nm)
        'lat',[],...
        'lon',[],...
        'time_zone_lon',[],...
        'RNPF_duration',[],... %duration of event (bounding box), hours
        'RNPF_rel_conc',[]);
    
    setappdata(handles.figure1,'ef_param',ef_param);
    setappdata(handles.figure1,'srs','dmps');
    
else
    if ischar(varargin{1})
        %assume it is a EF_data_file
        %try to load
        ef=load(varargin{1});
        if strcmp(ef.dataType,'EF9_gui_data');
            %defaults
            set(handles.smth1_tm,'String',ef.ef_param.smoothing1(2))
            set(handles.smth1_dp,'String',ef.ef_param.smoothing1(1))
            
            set(handles.smth2_tm,'String',ef.ef_param.smoothing2(2))
            set(handles.smth2_dp,'String',ef.ef_param.smoothing2(1))
            
            %set(handles.lowLim,'String','EF9_lim_fun_cdf')
            %set(handles.limFun_par,'String','[1.1,8,9,4]')
            set(handles.RNPF_dur,'String',ef.ef_param.RNPF_duration)
            set(handles.RNPF_conc,'String',ef.ef_param.RNPF_rel_conc)
            set(handles.lat,'String',ef.ef_param.lat)
            set(handles.lon,'String',ef.ef_param.lon)
            set(handles.timeZone_lon,'String',ef.ef_param.time_zone_lon)
            set(handles.upperLim,'String',ef.ef_param.dpLim)
            %         set(handles.lowLim,'String',ef.ef_param.dpLowLim)
            set(handles.lowLim,'String',0)
            
            set(handles.startDate,'String',datestr(ef.hmD.meta.startTime,'dd-mm-yyyy'))
            set(handles.stopDate,'String',datestr(ef.hmD.meta.endTime,'dd-mm-yyyy'))
            
            set(handles.pathParam,'String',ef.pathParam)
            ef_param=ef.ef_param;
            
            setappdata(handles.figure1,'ef_param',ef_param);
            setappdata(handles.figure1,'srs',ef.srs);
            
            
            setappdata(handles.figure1,'hmD',ef.hmD);
            setappdata(handles.figure1,'datI',ef.datI);
            sci_plot(handles)
            
            eval(sprintf('nrE=size(ef.hmD.obj.%s,1)',ef.srs));
            evList=cell(nrE,1);
            for i=1:nrE
                eval(sprintf('id=ef.hmD.obj.%s(i).evID;',ef.srs));
                evList{i}=sprintf('Event ID=%s',id);
            end
            set(handles.listbox1,'String',evList)
            
            
        else
            disp('EF9_gui: wrong data type')
            return
        end
        
    end
end


set(handles.working,'visible','off')

% --- Outputs from this function are returned to the command line.
function varargout = EF9_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in date_pop.
function date_pop_Callback(hObject, eventdata, handles)
% hObject    handle to date_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns date_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from date_pop


% --- Executes during object creation, after setting all properties.
function date_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to date_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smth1_tm_Callback(hObject, eventdata, handles)
% hObject    handle to smth1_tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smth1_tm as text
%        str2double(get(hObject,'String')) returns contents of smth1_tm as a double


% --- Executes during object creation, after setting all properties.
function smth1_tm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth1_tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startDate_Callback(hObject, eventdata, handles)
% hObject    handle to startDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startDate as text
%        str2double(get(hObject,'String')) returns contents of startDate as a double


% --- Executes during object creation, after setting all properties.
function startDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopDate_Callback(hObject, eventdata, handles)
% hObject    handle to stopDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopDate as text
%        str2double(get(hObject,'String')) returns contents of stopDate as a double


% --- Executes during object creation, after setting all properties.
function stopDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smth1_dp_Callback(hObject, eventdata, handles)
% hObject    handle to smth1_dp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smth1_dp as text
%        str2double(get(hObject,'String')) returns contents of smth1_dp as a double


% --- Executes during object creation, after setting all properties.
function smth1_dp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth1_dp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in smth1_meth.
function smth1_meth_Callback(hObject, eventdata, handles)
% hObject    handle to smth1_meth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns smth1_meth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smth1_meth


% --- Executes during object creation, after setting all properties.
function smth1_meth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth1_meth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smth2_tm_Callback(hObject, eventdata, handles)
% hObject    handle to smth2_tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smth2_tm as text
%        str2double(get(hObject,'String')) returns contents of smth2_tm as a double


% --- Executes during object creation, after setting all properties.
function smth2_tm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth2_tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smth2_dp_Callback(hObject, eventdata, handles)
% hObject    handle to smth2_dp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smth2_dp as text
%        str2double(get(hObject,'String')) returns contents of smth2_dp as a double


% --- Executes during object creation, after setting all properties.
function smth2_dp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth2_dp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in smth2_meth.
function smth2_meth_Callback(hObject, eventdata, handles)
% hObject    handle to smth2_meth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns smth2_meth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smth2_meth


% --- Executes during object creation, after setting all properties.
function smth2_meth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smth2_meth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lowLim.
function lowLim_Callback(hObject, eventdata, handles)
% hObject    handle to lowLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lowLim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lowLim


% --- Executes during object creation, after setting all properties.
function lowLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function limFun_par_Callback(hObject, eventdata, handles)
% hObject    handle to limFun_par (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limFun_par as text
%        str2double(get(hObject,'String')) returns contents of limFun_par as a double


% --- Executes during object creation, after setting all properties.
function limFun_par_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limFun_par (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RNPF_dur_Callback(hObject, eventdata, handles)
% hObject    handle to RNPF_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RNPF_dur as text
%        str2double(get(hObject,'String')) returns contents of RNPF_dur as a double

doFilter(handles)
sci_plot(handles)


% --- Executes during object creation, after setting all properties.
function RNPF_dur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RNPF_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RNPF_conc_Callback(hObject, eventdata, handles)
% hObject    handle to RNPF_conc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RNPF_conc as text
%        str2double(get(hObject,'String')) returns contents of RNPF_conc as a double

doFilter(handles)
sci_plot(handles)


% --- Executes during object creation, after setting all properties.
function RNPF_conc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RNPF_conc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lat_Callback(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lat as text
%        str2double(get(hObject,'String')) returns contents of lat as a double


% --- Executes during object creation, after setting all properties.
function lat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lon_Callback(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lon as text
%        str2double(get(hObject,'String')) returns contents of lon as a double


% --- Executes during object creation, after setting all properties.
function lon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeZone_lon_Callback(hObject, eventdata, handles)
% hObject    handle to timeZone_lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeZone_lon as text
%        str2double(get(hObject,'String')) returns contents of timeZone_lon as a double


% --- Executes during object creation, after setting all properties.
function timeZone_lon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeZone_lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pathParam_button.
function pathParam_button_Callback(hObject, eventdata, handles)
% hObject    handle to pathParam_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn,pn]=uigetfile('*.txt','Select hm_param file...')
if fn~=0
    set(handles.pathParam,'String',[pn,fn])
end

params=hm_readInstrumentParam([pn,fn]);

ins=cell(1);
for i=1:length(params)
    ins{i}=params(i).name;
end
set(handles.instList,'String',ins)
ins=get(handles.instList,'String');
Isel=1;
setappdata(handles.figure1,'srs',ins{Isel,:});

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
evSel=get(hObject,'Value');
setappdata(handles.figure1,'evSel',evSel)
hmD=getappdata(handles.figure1,'hmD');
ef_param=getappdata(handles.figure1,'ef_param');
srs=getappdata(handles.figure1,'srs');
eval(['dp=hmD.meta.',srs,'.dp{1};'])
eval(['dat=hmD.',srs,'{1}(2:end,3:end);'])

[~,I20]=min(abs(dp-ef_param.dpLim*1e-9));
[~,Ilow]=min(abs(dp-ef_param.dpLowLim*1e-9));

% dat=dat(:,Ilow:I20);
dp2=dp(Ilow:I20);

eval(['[Iev{1:length(hmD.obj.',srs,')}]=deal(hmD.obj.',srs,'.Iev);']);
Iev=find(cell2mat(Iev));

eval(['ev=hmD.obj.',srs,'(Iev(evSel));'])

%show info about the event
nfo={...
    sprintf('Start time=%s',datestr(ev.startTims)),...
    sprintf('Duration=%1.2fh',ev.duration),...
    sprintf('normConcentration=%1.2f??',ev.normConc),...
    sprintf('During Light Hours=%1.0f',ev.duringLightHours),...
    sprintf('Min intensity=%2.2f??',ev.MinIntensity),...
    sprintf('Mean intensity=%2.2f??',ev.MeanIntensity),...
    sprintf('Max intensity=%2.2f??',ev.MaxIntensity),...
    sprintf('Sun rise=%2.1f',ev.sunRisingHour),...
    sprintf('Sun set=%2.1f',ev.sunSetHour)...
    };

%GR
for i=1:length(ev.GR)
    str=sprintf('GR_%02.0f-%02.0fnm=%2.2fnm/h',dp2(i)*1e9,dp2(i+1)*1e9,ev.GR(i));
    
    nfo=[nfo,{str}];
end

set(handles.listbox2,'string',nfo)

%zoom plot
set(handles.axes2,'xlim',[ev.startTims-1/24,ev.startTims+ev.duration/24+1/24]);

%H_xdatetick_int(((range([ev.startTims-1/24,ev.startTims+ev.duration/24+1/24]))/5)*24)
datetick(handles.axes2,'keeplimits');
% --- Executes during object creation, after setting all properties.

% plot timeseries


dat=dat(:,Ilow:I20);
dp2=dp(Ilow:I20);


o=findobj(handles.axes4,'Tag','ts');
delete(o)
col=jet(length(ev.GR));
for i=1:length(ev.GR)
    
    %     eval(['plotD=hmD.',srs,'{1}(ev.Isel,i+2);'])
    plotD=dat(ev.Isel,i);
    mxs(i)=max(plotD);
    eval(['line(hmD.meta.',srs,'.tim{1}(ev.Isel),plotD,''parent'',handles.axes4,''tag'',''ts'',''color'',col(i,:))'])
    % plot(handles.axes4,hmD.meta.dmps.tim{1}(ev.Isel),hmD.dmps{1}(ev.Isel,i+2)),
    % hold all
    xlim(get(handles.axes2,'xlim'))
end
set(handles.axes4,'ylim',[0 max(mxs)*1.1])


function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.working,'visible','on')
drawnow
ef_param=getappdata(handles.figure1,'ef_param');

startD=datenum(get(handles.startDate,'String'),'DD-mm-YYYY');
stopD=datenum(get(handles.stopDate,'String'),'DD-mm-YYYY');
h=get(handles.smth1_meth,'Value');
f=get(handles.smth1_meth,'String');
s1_fun=f{h};
h=get(handles.smth2_meth,'Value');
f=get(handles.smth2_meth,'String');
s2_fun=f{h};
s11=str2double(get(handles.smth1_dp,'String'));
s12=str2double(get(handles.smth1_tm,'String'));
s21=str2double(get(handles.smth2_dp,'String'));
s22=str2double(get(handles.smth2_dp,'String'));

% lim_fun=['@',get(handles.lowLim,'String')];
% lim_fun_par=eval(get(handles.limFun_par,'String'));

lowLim=str2double(get(handles.lowLim,'String'));
%disp('EF9_gui: LowLimit not used')
upLim=str2double(get(handles.upperLim,'String'));

lat=str2double(get(handles.lat,'String'));
lon=str2double(get(handles.lon,'String'));
tim_lon=str2double(get(handles.timeZone_lon,'String'));
dur=str2double(get(handles.RNPF_dur,'String'));
rel=str2double(get(handles.RNPF_conc,'String'));
srs=getappdata(handles.figure1,'srs');

parPath=get(handles.pathParam,'String');

ef_param.smoothing1_fun=s1_fun;
ef_param.smoothing1=[s11,s12];
ef_param.smoothing2_fun=s2_fun;
ef_param.smoothing2=[s21 s22];
ef_param.dpLim=upLim;%nm
ef_param.dpLowLim=lowLim;%nm
%ef_param.lim_fun=eval(lim_fun);
%ef_param.lim_fun_par=lim_fun_par;%min,max,mu,sigma. min max in log10(conc) and mu and sigma in bin_number (not nm)
ef_param.lat=lat;
ef_param.lon=lon;
ef_param.time_zone_lon=tim_lon;
ef_param.RNPF_duration=dur; %duration of event (bounding box), hours
ef_param.RNPF_rel_conc=rel; %concentration / (Dp range (nm)*duration (h)),
setappdata(handles.figure1,'ef_param',ef_param);

ef_message(handles, 'Searching and anlysing the events')
drawnow
tic
[hmD,datI]=EF9_search([startD,stopD],ef_param,'doPlot',0,'parPath',parPath,'srs',srs);
setappdata(handles.figure1,'datI',datI)

t=toc;
srs=getappdata(handles.figure1,'srs');
eval(sprintf('nrE=size(hmD.obj.%s,1)',srs));
msg=sprintf('Found %2.0f events in %3.1fsec',nrE,t);
ef_message(handles, msg)
setappdata(handles.figure1,'hmD',hmD);

%set list of events
evList=cell(nrE,1);
for i=1:nrE
    eval(sprintf('id=hmD.obj.%s(i).evID',srs));
    evList{i}=sprintf('Event ID=%s',id);
end
set(handles.listbox1,'String',evList)

%plot
sci_plot(handles)
doFilter(handles)



function sci_plot(handles)
%plot

%%    figure(9),
%     ax(1)=subplot(2,1,1),
hmD=getappdata(handles.figure1,'hmD');
srs=getappdata(handles.figure1,'srs');
datI=getappdata(handles.figure1,'datI');
ef_param=getappdata(handles.figure1,'ef_param');

eval(['dp=hmD.meta.',srs,'.dp{1};'])
eval(['tim=hmD.meta.',srs,'.tim{1};'])

cutSize=ef_param.dpLim*1e-9;%nm
lowLim=ef_param.dpLowLim*1e-9;

[~,I20]=min(abs(dp-cutSize));
[~,Ilow]=min(abs(dp-lowLim));

dp2=dp(Ilow:I20);

try
    pcolor(tim',dp2',double(datI)','parent',handles.axes1),
    shading(handles.axes1,'flat')
    colormap(handles.axes1,'gray')
    H_xdatetick_int(24,[],[],handles.axes1);
    %datetick('x','mmm/dd','keepticks','keeplimits')
    set(handles.axes1,'yscale','log')
    grid off
end
%% lower panel
eval(['s=hmD.obj.',srs,';'])
co=cat(1,s.Centroid);
dpDif=diff(dp2)*1e9; %in nm

axes(handles.axes2)
hm_plot(hmD,srs)
colormap(handles.axes2,'jet')
% pcolor(real(log10(dat'))),shading flat,caxis([1 4])
%hold on, plot(co(:,1),co(:,2),'ok'),

hold on
for i=1:length(s)
    
    if s(i).Iev
        plot(s(i).ConvexHullTim(:,2),s(i).ConvexHullTim(:,1),'k','linewidth',2)
        plot(s(i).ConvexHullTim(:,2),s(i).ConvexHullTim(:,1),'k.-')
        
        
        for im=1:size(datI,2)-1
            if s(i).GR1_fval(im)<10
                plot([s(i).mode1MaxTm(im)],[dp2(im)],'.w','markerfacecolor','w','markersize',20)
                plot([s(i).mode1MaxTm(im),s(i).mode1MaxTm(im)+(dpDif(im)/s(i).GR(im))/24],[dp2(im),dp2(im+1)],'.-k','markersize',12)
            end
        end
    end
end
hold off
title(handles.axes2,' ')
h=zoom;
set(h,'ActionPostCallback',@postzoomcallback)
set(h,'enable','on')

linkaxes([handles.axes1,handles.axes2,handles.axes4],'x')

%linkprop([handles.axes1,handles.axes2,handles.axes4],{'xlim'})
H_xdatetick_int(24,[],[],handles.axes1);
H_xdatetick_int(24,[],[],handles.axes4);

drawnow
set(handles.working,'visible','off')



function ef_message(handles,msg)
%
% print message to message box
%

set(handles.msgBox,'String',msg);

function res=postzoomcallback(obj,evd)
%
%
fh=get(evd.Axes,'parent');
axs=findobj(fh,'Type','axes');
for i=1:length(axs)
    datetick(axs(i),'keeplimits')
end
H_xdatetick_int(24,[],[],axs(3));

%datetick(evd.Axes,'keeplimits')



function upperLim_Callback(hObject, eventdata, handles)
% hObject    handle to upperLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperLim as text
%        str2double(get(hObject,'String')) returns contents of upperLim as a double


% --- Executes during object creation, after setting all properties.
function upperLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pathParam_make.
function pathParam_make_Callback(hObject, eventdata, handles)
% hObject    handle to pathParam_make (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


hm_setParamGUI;

global parPath
if parPath~=0
    set(handles.pathParam,'String',parPath)
end


% --- Executes on button press in zoomX.
function zoomX_Callback(hObject, eventdata, handles)
% hObject    handle to zoomX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hmD=getappdata(handles.figure1,'hmD');
srs=getappdata(handles.figure1,'srs');
eval(['tim=hmD.meta.',srs,'.tim{1};'])
mnmx=[min(tim),max(tim)];

set(handles.axes1,'xlim',mnmx)
set(handles.axes2,'xlim',mnmx)
set(handles.axes4,'xlim',mnmx)

axs=findobj(handles.figure1,'Type','axes');
for i=1:length(axs)
    datetick(axs(i),'x','dd/mm','keeplimits')
end
H_xdatetick_int(24,[],[],handles.axes1);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hmD=getappdata(handles.figure1,'hmD');
ef_param=getappdata(handles.figure1,'ef_param');
srs=getappdata(handles.figure1,'srs');
datI=getappdata(handles.figure1,'datI');
pathParam=get(handles.pathParam,'String');

dataType='EF9_gui_data';

uisave({'dataType','hmD','ef_param','srs','datI','pathParam'},'EF9_data')


% --- Executes on button press in deleteEvent.
function deleteEvent_Callback(hObject, eventdata, handles)
% hObject    handle to deleteEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evSel=getappdata(handles.figure1,'evSel');
hmD=getappdata(handles.figure1,'hmD');
srs=getappdata(handles.figure1,'srs');
ef_param=getappdata(handles.figure1,'ef_param');

if ~isempty(evSel)
    eval(['hmD.obj.',srs,'(evSel)=[];'])
    evSel=[];
end

eval(['nrE=length(hmD.obj.',srs,');'])
%set list of events
evList=cell(nrE,1);
for i=1:nrE
    eval(sprintf('id=hmD.obj.%s(i).evID',srs));
    evList{i}=sprintf('Event ID=%s',id);
end
set(handles.listbox1,'Value',1)
set(handles.listbox1,'String',evList)
set(handles.listbox2,'string',[' '])

setappdata(handles.figure1,'evSel',evSel);
setappdata(handles.figure1,'hmD',hmD);

sci_plot(handles)


% --- Executes on button press in filterCheck.
function filterCheck_Callback(hObject, eventdata, handles)
% hObject    handle to filterCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filterCheck

doFilter(handles)
sci_plot(handles)

function doFilter(handles)
%
% read filtering parameters and make filtering
% result is saved to hmD.obj.srs.Iev

hmD=getappdata(handles.figure1,'hmD');
srs=getappdata(handles.figure1,'srs');
dur=str2num(get(handles.RNPF_dur,'String'));
conc=str2num(get(handles.RNPF_conc,'String'));
Ilight=get(handles.lightHours,'Value');
Ifilt=get(handles.filterCheck,'Value');
eval(['nrE=length(hmD.obj.',srs,');'])
if Ifilt
    if Ilight
        for i=1:nrE
            eval(['hmD.obj.',srs,'(i).Iev=hmD.obj.',srs,'(i).duration>dur & hmD.obj.',srs,'(i).duringLightHours==1 & hmD.obj.',srs,'(i).normConc>conc;'])
        end
    else
        for i=1:nrE
            eval(['hmD.obj.',srs,'(i).Iev=hmD.obj.',srs,'(i).duration>dur & hmD.obj.',srs,'(i).normConc>conc;'])
        end
    end
else
    %     remove filtering and set all events as NPF
    for i=1:nrE
        eval(['hmD.obj.',srs,'(i).Iev=true;'])
    end
end

setappdata(handles.figure1,'hmD',hmD);
populateEventlist(handles)



% --- Executes on button press in lightHours.
function lightHours_Callback(hObject, eventdata, handles)
% hObject    handle to lightHours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lightHours

doFilter(handles)
sci_plot(handles)

function populateEventlist(handles)

hmD=getappdata(handles.figure1,'hmD');
srs=getappdata(handles.figure1,'srs');


eval(['nrE=length(hmD.obj.',srs,');'])
%set list of events
evList=cell(1,1);
h=0;
for i=1:nrE
    eval(sprintf('Iev=hmD.obj.%s(i).Iev;',srs));
    if Iev
        h=h+1;
        eval(sprintf('id=hmD.obj.%s(i).evID;',srs));
        evList{h}=sprintf('Event ID=%s',id);
    end
end
set(handles.listbox1,'Value',1)
set(handles.listbox1,'String',evList)
set(handles.listbox2,'string',[' '])

% setappdata(handles.figure1,'evSel',evSel);


% --- Executes on selection change in instList.
function instList_Callback(hObject, eventdata, handles)
% hObject    handle to instList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns instList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from instList

ins=get(handles.instList,'String');
Isel=get(handles.instList,'Value');
setappdata(handles.figure1,'srs',ins{Isel});

% --- Executes during object creation, after setting all properties.
function instList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function dataCursor_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to dataCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function output_txt = gui_text_disp_fun(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text sttring (string or cell array of strings).
pos = get(event_obj,'Position');
ln = get(event_obj,'Target');
type=get(ln,'Type');
switch type
    case 'line'
        ax=get(ln,'Parent');
        % axTag=get(ax,'Tag');
        lns=findobj(ax,'type','line');
        % for i=1:length(lns)
        set(lns,'linewidth',1)
        % end
        set(ln,'LineWidth',2)
        output_txt={datestr(pos(1)),...
            sprintf('Conc: %2.2f cm-3',pos(2))};
    case 'surface'
        output_txt={datestr(pos(1)),...
            sprintf('Size: %2.1f nm',pos(2)*1e9)};
        
end



