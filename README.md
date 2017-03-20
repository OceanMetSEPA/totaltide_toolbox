# totaltide_toolbox

A MATLAB interface for Admiralty TotalTide

This library provides a MATLAB interface to the Admiralty Total Tide COM API, as well a number of custom functions which wrap commonly used functionality. 

Using this library allows Total Tide port locations to be discovered and time-series data describing astronomical water level variations to be generated.

## Dependencies
This library requires an authorised version of Admiralty Total Tide to be installed in order to be of any use

It also uses the [os_toolbox]{https://github.com/OceanMetSEPA/os_toolbox} in oder to provide coordinate conversion support.

## Examples
 

### Initialize port based on lon/lat
'''matlab
port = TotalTide.closestPort(-4.8858831,55.767350)

% port = Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort
%
%                      Number: '0398'
%                        Name: 'Millport'
%                    Latitude: 55.75
%                   Longitude: -4.933333
%                 StationType: 'PortHarmonic'
%                      IsPort: 1
%                    IsStream: 0
%                    Filtered: 1
%                     Country: 'Scotland'
%                    ZoneTime: 0
%                      Height: 1.91651478620743
%            HighestHighWater: 3.4
%             LowestHighWater: 2.7
%             HighestLowWater: 1
%              LowestLowWater: 0.4
%                MeanSeaLevel: 1.993
%      DaysToOrFromSpringTide: -4
%     HighestAstronomicalTide: 3.9
%      LowestAstronomicalTide: -0.1
%         MinimumDisplayScale: 5000000
%                  TypeOfPort: 'PortSecondaryHarmonic'
'''

### Initialize port based on OSGB easting/northing
'''matlab
port = TotalTide.closestPort(219055,656439, 'format', 'OSGB')
'''
### Examine port info
'''matlab
% print out all properties
get(port)

% retreive individual properties
port.name
port.Latitude
port.StationType
port.HighestHighWater
'''

###Get water levels from a window of time
'''matlab
% e.g. next 30 days at 20 min resolution
levels = TotalTide.getHeights(port, now, 30, 20)

% levels = 
%       time: [1x2160 double]
%     height: [1x2160 double]

'''

### Quickly plot generated water levels
'''matlab
TotalTide.plotHeights(h, port.name) % name optional

### Using the TotalTide API

Total Tide provides a greater range of functionality than described above. Full documentation for the Total Tide COM API is provided on the secured Total Tide developer [website](http://www.chersoft.co.uk/totaltidesdk/index.htm}

The base Total Tide API can be easily accessed using the TotalTide.connection object provided in this library: 

'''matlab
conn = TotalTide.connection;
'''

Using the returned object allows the raw API functions to be used. For example, finding a port by its Admiralty number identifier.

'''matlab
port = conn.StationByNumber('0332') 
'''
which returns single location associated with unique ID number.

Alternatively, ports can be found using their name
'''matlab
ports = tt.StationsByName('Millport',0)
'''
which returns a collection of locations based on the search term (the second argument indicates search type: 0 = ports only, 1 = streams 
% only and 2 = both)
'''matlab
ports.size % => 1 
'''
and an individual port can be isolated using the .Item() method
'''matlab
port = ports.Item(1)
'''
%%
















