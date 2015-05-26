function [elev_angle,sunrisehour, solar_noon, sunset_hour]=aurinko(yyyy,month,day,hour,lat,lon,lon_timezone) %aurinko(yyyy,month,day,hour)
%function [elev_angle, dec_angle]=aurinko(yyyy,month,day,hour) %aurinko(yyyy,month,day,hour)
      %dec_angle,potentialpar]=aurinko(jd,hour)

%paiva vuoden alusta (julian day) 01.01.xxxx = 1

if nargin==4
lat = 61 + 51/60; % latitude of Hyde
lon = 24 + 17/60; % longitude of Hyde
lon_timezone = 30; % longitude of time zone
end



jd = datenum(yyyy,month,day)-datenum(yyyy-1,12,31);

angle_earth_axis = pi*23.45./180;

day_angle = 2 .* pi / 365.242 .* (jd - 1);

time_eq = 0.017 + 0.4281 .* cos(day_angle) - 7.351 .* sin(day_angle)...
      - 3.349 .* cos(2*day_angle) - 9.371 .* sin(2.*day_angle); % in mins

solar_noon = 12. + ( 4  .* (lon_timezone - lon) - time_eq) ./ 60.;

dec_angle = angle_earth_axis .* sin(2 .* pi .* (284. + jd)/365.242);
%dec_angle = 2*pi*(23.45/360)*cos(2*pi*(jd-172)/365.242);
%%******solar declination Wilson (1979) 
%Shifted in time, not to be used
%dec_angle = 0.006918 -0.399912*cos(day_angle) + 0.010257*sin(day_angle) - 0.006758*cos(2*day_angle)...
%+ 0.000907*sin(2*day_angle) - 0.002697*cos(3*day_angle) + 0.00148*sin(3*day_angle);

sunriseangle = acos(-(sin(lat.*pi/180.) * sin(dec_angle))./(cos(lat.*pi/180.) .* cos(dec_angle)));
sunrisehour = solar_noon - sunriseangle.*12./pi;
sunset_hour = solar_noon + sunriseangle.*12./pi;

hour_angle = pi .* (hour - solar_noon) ./ 12.;

elev_angle = asin(sin(lat.*pi/180.) .* sin(dec_angle) +...
     cos(lat.*pi./180.) .* cos(dec_angle) .* cos(hour_angle)); % radians
 
% elev_angle = elev_angle * 180/pi; % degrees
