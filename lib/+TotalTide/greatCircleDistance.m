function [ km ] = greatCircleDistance(lon1, lat1, lon2, lat2)
    % Calculates the distance between two locations on the Earth's surface. 
    % Locations are specified as lat/lng pairs using decimal degrees, and 
    % distances are calculated using the Haversine formula whcih approximates the
    % Earth as a sphere. 
    %
    % Usage:
    %      greatCircleDistance(lon1, lat1, lon2, lat,2)
    % 
    % OUTPUT:
    %      Numeric value representing distance in km
    %
    % 
    %

    if nargin==0
      help greatCircleDistance
      return
    end

    R = 6371; % Earth's radius in km

    % This is the Haversine formula
    
    lon1 = lon1 * pi ./ 180;
    lat1 = lat1 * pi ./ 180;
    lon2 = lon2 * pi ./ 180;
    lat2 = lat2 * pi ./ 180;

    delta_lat = lat2 - lat1;    % difference in latitude
    delta_lon = lon2 - lon1;    % difference in longitude
    a = sin(delta_lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta_lon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));

    km = R * c;                             % distance in km
end

