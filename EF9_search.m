function [hmD,datI]=EF9_search(D,param,varargin)
%
% Classify diven date
%
%Example for V?rri?
% param=struct(...
%     'smoothing1_fun,'2dmedfilt'
%     'smoothing1',[3,9],...
%     'smoothing2_fun,'2dmeanfilt'
%     'smoothing2',[1 13],...
%     'dpLim',20,.. %nm
%     'dpLowLim',3,... %nm
%     'maxStep',20,...
%     'lim_fun','@cdf',...
%     'lim_fun_par',[1.6,4.1,8,3],...
%     'lat',67.7667,...
%     'lon',29.5833,...
%     'time_zone_lon',30);%min,max,mu,sigma. min max in conc and mu and sigma in bin_number (not nm)
%

%% extract inputs
%defaults

doPlot=0;
parPath='hm_param.txt';
srs='dmps';

%varargin
i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'doPlot',                i=i+1; doPlot = varargin{i};
            case 'parPath',               i=i+1; parPath = varargin{i};
            case 'srs',                   i=i+1; srs = varargin{i};
            otherwise, argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['Ignoring invalid argument #' num2str(i+1)]);
    end
    i = i+1;
end


if isstruct(D)
    if isfield(D,'Type')
        if strcmp(D.Type,'hm_dat')
            hmD=D;
        else
            error('EF9_search: wrong type of input structure, use hm_load or datenum' )
        end
    else
        error('EF9_search: wrong type of input structure, use hm_load or datenum')
    end
else
    hmD=hm_load(D,srs,'parPath',parPath);
end


%% smoothing
hmD=hm_smoothing(hmD,param.smoothing1_fun,param.smoothing1,srs);
% check if days are already combined into one matrix
eval(['nrDays=length(hmD.',srs,');']);
if nrDays>1
    hmD=hm_comb_days(hmD);
end
hmD=hm_smoothing(hmD,param.smoothing2_fun,param.smoothing2,srs);

%% parameters
%limFun=param.lim_fun;
eval(['tim=hmD.meta.',srs,'.tim{1};']);
eval(['dp=hmD.meta.',srs,'.dp{1};']);

%% limit
eval(['dat=hmD.',srs,'{1}(2:end,3:end);']);
[n,m]=size(dat);

datI= false(n,m);
%  lim=[ones(1,2)*2,linspace(2,7,size(dat,2)-2)];
%  lim=cdf('norm',1:size(dat,2),6,3)*(4.1-1.6)+1.6;
% lim=limFun(1:m,[param.lim_fun_par]);
%  lim=cdf('logn',hmD.meta.dmps.dp{1},10e-20,2.2)*(4.1-1.6)+1.6;
% if doPlot
%     figure(7),subplot(2,1,1),
%     eval(['plot(hmD.meta.',srs,'.dp{1},lim)'])
%     set(gca,'xscale','log')
%     subplot(2,1,2),plot(lim)
% end

% %apply limit for each size fraction
% for i=1:m
%     datI(:,i)=(log10(dat(:,i))>lim(i));
% end
eval(['dat=hmD.',srs,'{1}(2:end,3:end);'])
eval(['dp=hmD.meta.',srs,'.dp{1};'])

% [~,I20]=min(abs(dp-15e-9));
[~,I20]=min(abs(dp-param.dpLim*1e-9));
[~,I10]=min(abs(dp-10*1e-9));
[~,Ilow]=min(abs(dp-param.dpLowLim*1e-9));
dat=dat(:,Ilow:I20);
dp2=dp(Ilow:I20);
[n,m]=size(dat);
datI_10=dat-repmat(dat(:,I10-Ilow+1),1,m)>0;
datI_10(:,I10-Ilow+1:end)=false;
datI=dat-repmat(dat(:,I20-Ilow+1),1,m)>0;

% datI=datI | datI_10;
datI=datI_10;
%remove objects that have less than 10 pixels
datI = bwareaopen(datI,20);

% clean from unwanted features
% sedisk = strel('line',6,120);
% datI = imopen(datI, sedisk);


if doPlot
    figure(9),
    %     ax(1)=subplot(2,1,1),
    pcolor(tim',dp2',double(datI)'),shading flat,colormap gray
    H_xdatetick_int(24)
    datetick('x','mmm/dd','keepticks','keeplimits')
    set(gca,'yscale','log')
    %     if exist('datI_clean','var')
    %     ax(2)=subplot(2,1,2),
    %     pcolor(double(datI_clean)),shading flat,colormap gray
    %     linkaxes(ax,'x')
    %     end
end

s1  = regionprops(datI, dat, 'BoundingBox','PixelValues');
% clear datI

%% step through initial objects and evaluate the spectra 4 hours after the
%% object. Look for data values above threshold value during each event
datI2=false(size(dat));
tmStep=median(unique(diff(tim)));
evLength=12/24;
L=size(dat,1);
threshold=100;
for i=1:length(s1)
    %     bx_y=[s1(i).BoundingBox(1),s(i).BoundingBox(1)+s(i).BoundingBox(3),s(i).BoundingBox(1)+s(i).BoundingBox(3),s(i).BoundingBox(1),s(i).BoundingBox(1)];
    %     bx_x=[s1(i).BoundingBox(2),s(i).BoundingBox(2),s(i).BoundingBox(2)+s(i).BoundingBox(4),s(i).BoundingBox(2)+s(i).BoundingBox(4),s(i).BoundingBox(2)];
    %     s(i).BoundingBoxTim_y=dp(max(floor(bx_y),1));
    %     s(i).BoundingBoxTim_x=tim(max(floor(bx_x),1));
    
    %auto
    threshold=prctile(s1(i).PixelValues,25);
    
    ItmStart=max(floor(s1(i).BoundingBox(2)),1);
    Itm=ItmStart:min(ItmStart+round(evLength/tmStep),L);
    %     datI2(Itm,1:I20)=dat(Itm,1:I20)>threshold;
    datI2(Itm,:)=dat(Itm,:)>threshold;
    % datI2()=
    
    %nice try
    %     for ii=1:length(Itm)
    %         datI2(Itm(ii),find(datI2(Itm(ii),:)==0,1,'first'):end)=false;
    %     end
    
end
%remove objects that have less than 10 pixels
% datI2 = bwareaopen(datI2,20);
s  = regionprops(datI2, dat, 'all');

if doPlot
    figure(8),
    %     ax(1)=subplot(2,1,1),
    pcolor(tim',dp2',double(datI2)'),shading flat,colormap gray
    H_xdatetick_int(24)
    datetick('x','mmm/dd','keepticks','keeplimits')
    set(gca,'yscale','log')
    %     if exist('datI_clean','var')
    %     ax(2)=subplot(2,1,2),
    %     pcolor(double(datI_clean)),shading flat,colormap gray
    %     linkaxes(ax,'x')
    %     end
end


%minimum measurement size
Iok=~isnan(dat);
okDp=repmat(dp2,length(tim),1);
okDp(~Iok)=NaN;
minDp=min(okDp,[],2);
rangeDp=param.dpLim-minDp*1e9; %in nm

%concentration of 3-20nm

c3_20=hm_conc(hmD,srs,[param.dpLowLim param.dpLim]*1e-9);
% c1=hm_conc(hmD,'dmps',[3 4]*1e-9);
% c2=hm_conc(hmD,'dmps',[5 6]*1e-9);
% c3=hm_conc(hmD,'dmps',[9 11]*1e-9);
% c4=hm_conc(hmD,'dmps',[14 16]*1e-9);

dpDif=diff(dp2)*1e9; %in nm

% cs=NaN(size(c3_20,1),20);
%             dpDif=2; %nm
%
% for i=1:20
%     tmp=hm_conc(hmD,'dmps',[i i+dpDif]*1e-9);
%     cs(:,i)=tmp(:,2);
% end
cs_tm=c3_20(:,1);

%Calculate bounding box in time-units
Ibad=zeros(length(s),1);
for i=1:length(s)
    bx_y=[s(i).BoundingBox(1),s(i).BoundingBox(1)+s(i).BoundingBox(3),s(i).BoundingBox(1)+s(i).BoundingBox(3),s(i).BoundingBox(1),s(i).BoundingBox(1)];
    bx_x=[s(i).BoundingBox(2),s(i).BoundingBox(2),s(i).BoundingBox(2)+s(i).BoundingBox(4),s(i).BoundingBox(2)+s(i).BoundingBox(4),s(i).BoundingBox(2)];
    s(i).BoundingBoxTim_y=dp2(max(floor(bx_y),1));
    s(i).BoundingBoxTim_x=tim(max(floor(bx_x),1));
    s(i).ConvexHullTim(:,2)=tim(max(floor(s(i).ConvexHull(:,2)),1));
    s(i).ConvexHullTim(:,1)=dp2(max(floor(s(i).ConvexHull(:,1)),1));
    
    %sun rising hour
    [y,m,d,h]=datevec(s(i).BoundingBoxTim_x(1));
    [~,tr,~,ts]=aurinko(y,m,d,h);
    s(i).sunRisingHour=tr;
    s(i).sunSetHour=ts;
    
    %starting time
    s(i).startTims=s(i).BoundingBoxTim_x(1);
    s(i).evID=[datestr(s(i).startTims,'yyyymmddHHMMSSFFF')];
    startH=(s(i).startTims-floor(s(i).startTims))*24;
    s(i).duringLightHours=double(tr<startH & ts>startH);
    %duration
    s(i).duration=(s(i).BoundingBoxTim_x(3)-s(i).BoundingBoxTim_x(1))*24; %h
    
    %concentration during the event
    Isel=floor(bx_x(1)):floor(bx_x(3));
    Isel(Isel==0)=[];
    
    if length(Isel)==2
        Ibad(i)=1;
    else
        s(i).conc=c3_20(Isel,2);
        s(i).Isel=Isel;
        %average diameter range during the event
        s(i).avrRange=nanmean(rangeDp(Isel));
        
        %normalized concentration
        %     s(i).normConc=sum(s(i).conc)/(s(i).duration*s(i).avrRange)
        s(i).normConc=sum(s(i).conc)/(s(i).avrRange);
        
        % classify event days
        s(i).Iev=s(i).duration>param.RNPF_duration & s(i).duringLightHours==1 & s(i).normConc>param.RNPF_rel_conc;
        %     figure,plot([c3_5(Isel,2),c5_7(Isel,2),c7_9(Isel,2)])
        % growth rate
        for im=1:size(dat,2)-1
            tm=cs_tm(Isel,1);
            %             dat1=cs(Isel,im);
            %             dat2=cs(Isel,im+1);
            
            dat1=dat(Isel,im);
            dat2=dat(Isel,im+1);
            
            
            [gr,gr_init,fval]=growthRate(tm,dat1,dat2,dpDif(im));
            s(i).GR(im)=gr;
            s(i).GR1_fval(im)=fval;
            s(i).GR1_init(im)=gr_init;
            [mx,Imx]=max(dat1);
            s(i).mode1MaxTm(im)=tm(Imx);
            SlopeThreshold=.01;
            AmpThreshold=10;
            smoothwidth=3;
            peakgroup=3;
            
            [P,d]=findpeaks(tm,dat1,SlopeThreshold,AmpThreshold,smoothwidth,peakgroup);
            P(:,1)=dp2(im);%+dpDif/2;
            s(i).peaks{im}=P;
            
            s(i).predMode1MaxTm(im+1)=s(i).mode1MaxTm(im)+(dpDif(im)/s(i).GR(im))/24;
            
            
            
            %         s(i).position=P(:,2);
            %         s(i).height(im)=P(:,3);
            %         s(i).width(im)=P(:,4);
            s(i).nrPeaks(im)=length(P(:,1));
        end
        
        % find number of peaks in events
    end
end
s(Ibad==1)=[];

if doPlot
    co=cat(1,s.Centroid);
    figure(10),
    hm_plot(hmD,srs)
    % pcolor(real(log10(dat'))),shading flat,caxis([1 4])
    hold on, plot(co(:,1),co(:,2),'ok'),
    for i=1:length(s)
        plot(s(i).ConvexHullTim(:,2),s(i).ConvexHullTim(:,1),'k','linewidth',2)
        if s(i).Iev
            plot(s(i).ConvexHullTim(:,2),s(i).ConvexHullTim(:,1),'k.-')
        end
        %         plot(s(i).BoundingBoxTim_x,s(i).BoundingBoxTim_y,'k')
        %         text(s(i).ConvexHullTim(1,2),2.5e-9,num2str(i))
        %         %         text(s(i).ConvexHullTim(1,2),2.2e-9,num2str(s(i).normConc))
        %         text(s(i).ConvexHullTim(1,2),2.2e-9,num2str(s(i).GR1))
        
        for im=1:size(dat,2)-1
            if s(i).GR1_fval(im)<10
                plot([s(i).mode1MaxTm(im)],[dp2(im)],'.w','markerfacecolor','w','markersize',20)
                plot([s(i).mode1MaxTm(im),s(i).mode1MaxTm(im)+(dpDif(im)/s(i).GR(im))/24],[dp2(im),dp2(im+1)],'.-k','markersize',12)
            end
        end
        %         if s(i).GR2_fval<10
        %             plot([s(i).mode2MaxTm,s(i).mode2MaxTm+(5/s(i).GR2)/24],[10e-9,15e-9],'.-y')
        %         end
    end
    hold off
end

eval(['hmD.obj.',srs,'=s;'])


function [gr,gr_init,fval]=growthRate(tm,dat1,dat2,dpDif)
%
% calculate optimum shift between the two data
%tm  - datenum
%dat1 - concentration data of smaller size
%dat2 - concentration data of bigger size
%dpDif - size difference
%

tm=(tm-(tm(1)))*24; %time in hours
% dat1=H_scale(dat1);
% dat2=H_scale(dat2);


dat1=(dat1/sum(dat1)).^4;
dat2=(dat2/sum(dat2)).^4;

% search rough shift
stps=floor(length(dat1)/3);
err=NaN(stps,1);
for i=1:stps
    err(i)=norm(dat1(1:end-i)-dat2(1+i:end));
end
[~,Imn]=min(err);

init=Imn*(tm(2)-tm(1));

gr=NaN;
fval=NaN;
gr_init=init;
try
    opt = optimset('GradObj','off','Display','off','maxiter',100,'algorithm','sqp');
    % [par1]=fminsearch(@(par1) minDif(par1,tm,dat1,dat2),init,opt);
    ll=0.001;
    ul=3;
    [par1]=fmincon(@(par1) minDif(par1,tm,dat1,dat2),init,[],[],[],[],ll,ul,[],opt);
    
    if par1<ll+1e-3
        gr=NaN;
        fval=NaN;
        gr_init=NaN;
    else
        [fval,ci]=minDif(par1,tm,dat1,dat2);
        gr=dpDif/par1;
        gr_init=dpDif/init;
    end
end


function [fval,ci]=minDif(par,tm,dat1,dat2)
% par in hours
ci=interp1(tm,dat2,tm+par);
fval=nanmean(abs((dat1-ci)));

