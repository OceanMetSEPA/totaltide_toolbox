function [ port, distance ] = closestPort(x,y,varargin)
    % Returns the nearest tide monitoring station to a given location based on 
    % Admirality TotalTide. The target location can be specified in either decimal 
    % degrees (lat,lng) or as an easting/northing pair. The query is scoped to 
    % the northern part of the UK only (sectors "H" and "N" in the OS grid) in 
    % order to minimize the search space.
    %
    % Distances are calculated along great circles rather than with reference to 
    % any particluar water body, so care must be taken to ensure that the result is
    % appropriate to the context under consideration.
    %
    % Usage:
    % TotalTide.closestStation(x, y) 
    %   where x,y are long/lats
    %
    % TotalTide.closestStation(x, y, 'format', 'OSGB')
    %   where x,y are easting/northing
    %
    % OUTPUT:
    %    An instance of TotalTide::IPort. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_port.html
    %
    % EXAMPLES:
    %
    %    sta = TotalTide.closestStation(56.223399966767325, -5795766414163874) % assumes decimal degree lat/lng pair
    %    sta = TotalTide.closestStation(56.223399966767325, -5795766414163874, 'format', 'LL') % same results as above but explicitly
    %    declares decimal degree, lat/lng format using 'LL'
    %    sta = TotalTide.closestStation(164789, 709911, 'format', 'OSGB') % declare easting/northing
    %    format using 'OSGB'
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - catCoordinates.m
    %  - TotalTide.northUKPorts.m
    %  - greatCircleDistance.m
    
    if nargin==0
      help TotalTide.closestPort
      return
    end
    
    format = 'LL';
    scope  = 'uk';
    
    for i = 1:length(varargin)
      if ischar(varargin{i}) 
          if strcmpi(varargin{i}, 'format')
              format = varargin{i + 1};
          elseif strcmpi(varargin{i}, 'scope')
              scope = varargin{i + 1};
          end
      end
    end

    % If easting/northing format declared in third argument, convert to
    % decimal degrees
    if strcmpi(format, 'EN') | strcmpi(format, 'OSGB')
       [lng,lat] = OS.catCoordinates(x, y);
    else
       % Otherwise, just assign the passed in lat/lng to the appropriate vars
       lat = y;
       lng = x;
    end

    % Get the candidate stations from TotalTide
    if strcmpi(class(scope), 'Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IStations')
        search_domain = scope;
    elseif strcmpi(scope, 'uk') 
        search_domain = TotalTide.portsInUK();
    elseif strcmpi(scope, 'scotland') 
        search_domain = TotalTide.portsInScotland();
    elseif isnumeric(scope) & length(scope) == 4
        search_domain = TotalTide.portsInBounds(scope(1), scope(2), scope(3), scope(4));
    end

    min_distance = 99999999999;
    closestPortIndex = 0;

    % Iterate through the northern UK stations and identify the closest one to
    % the target location
    for p = 1:search_domain.Count

       distance = TotalTide.greatCircleDistance(lng, lat, search_domain.Item(p).Longitude,search_domain.Item(p).Latitude);

       if distance < min_distance
           min_distance = distance;
           closestPortIndex = p;
       end

    end

    % Return the winner!
    port = search_domain.Item(closestPortIndex);
    distance = min_distance;
    get(port)
end

