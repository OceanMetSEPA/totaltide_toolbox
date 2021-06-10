function [ conversionFactor,uncertainty,dists ] = cd2odn(lon,lat,vorfCD2ODN)
% Obtain the conversion factor needed to convert Chart Datum (CD) to Ordnance Datum Newlyn (ODN)
%
% This function uses a look-up table created from the .vrf files stored here:
% vrfPath='\\sepa-fp-01\DIR SCIENCE\EQ\Oceanmet\data\ocean\VORF\VORF_Scotland_CD_to_ODN\VORF_Scotland_CD_to_ODN'
% % Look-up table generated using following code:
% vrfFiles=fileFinder(vrfPath,'.vrf')
% vorfCD2ODN = vertcat(cell2mat(cellfun(@dlmread,vrfFiles,'Unif',0)));
%
% This data is stored in 'vorfCD2ODN.mat' in here:
% '\\sepa-fp-01\DIR SCIENCE\EQ\Oceanmet\tools\Matlab\VDriveLibrary\Data'
% Synching the library will provide you with a local copy.
%
% INPUTS:
% longitude (eastings) - this can be a scalar, vector or 2d matrix of values
% latitude (northings) - as above (must be same size)
%
% Optional Input: vorfCD2ODN dataset (if not provided, the function should be able to find it)
%
% OUTPUT:
% Height(s) of Ordnance Datum (Newlyn) relative to Chart Datum for given
%           point(s). To convert from OD to CD, add this value (for positive depths).
% uncertainty - reported error in these height values
%
% EXAMPLE:
% % Convert a depth of 0.37 m(OD) at Millport to CD
% % Location of Millport = (-4.93, 55.75)
% datumOffset=cd2odn(-4.93,55.75) % = 1.6205 (c.f. -1.62m in TableIII of TotalTide help)
% depthOD = 0.37 + datumOffset % = 1.9905m
%
% % Get offsets for D3D Grid:
% d3dGrid=wlgrid('read','\\sepa-fp-01\DIR SCIENCE\EQ\Oceanmet\models\ocean\d3dTemplates\FOC\grid.grd');
% focDatumOffsets=cd2odn(d3dGrid.X,d3dGrid.Y);
%
% % Aberdeen:
% cd2odn(396000,807000) % returns 2.2466 (c.f. -2.25 in TableIII)
%
% As noted in "VORF notes and caveats.doc", there is a discrepancy at
% Tobermory. For coordinates of tide port in TotalTide:
% lon=degreeConverter([-6,4],1)
% lat=degreeConverter([56,37],1)
% cd2odn(lon,lat) % = 2.13 (c.f. -2.39m in TableIII)
%
% *************************************************************************
% NB:
% This function returns POSITIVE values
% c.f. Table III of TotalTide which lists the "Height in meters of chart
% datum relative to Ordnance Datum in the United Kingdom", where all the
% values are NEGATIVE. Make sure you add/subtract the relevant number
% appropriately.
% *******************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   cd2odn.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Jul 03 2014 15:03:02  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
if nargin==0
    help TotalTide.cd2odn
    return
end


%% Code below saves user the bother of passing the VORF dataset as the 3rd argument.
if ~exist('vorfCD2ODN','var') % user didn't pass VORF dataset?
    if evalin('base','exist(''vorfCD2ODN'')') % can it be found in base workspace?
        vorfCD2ODN=evalin('base','vorfCD2ODN;'); % if so, load it.
        %        fprintf('VORF Data obtained from base workspace\n')
    else  % not in base workspace?
        try % then attempt to load data from mat file
            evalin('base','vorfCD2ODN=importdata(''vorfCD2ODN.mat'');');
            vorfCD2ODN=evalin('base','vorfCD2ODN;'); % and copy it to function workspace
            fprintf('VORF Data loaded from mat file\n')
        catch
            error('Couldn''t access VORF data - please check for ''vorfCD2ODN.mat'' file')
        end
    end
end

%% Size checks
% Get sizes of inputs:
xsize=size(lon);
ysize=size(lat);
if ~isequal(xsize,ysize)
    error('Lon / lat inputs must have same size')
end
% we'll work with column vectors. But if user passed us a grid, we'll
% convert back at the end
lon=lon(:);
lat=lat(:);
% If inputs are big, they might be eastings/northings
vals=[lon;lat];
if all(abs(vals(~isnan(vals)))>90) % input coordinates more like Eastings/Northings
    %    fprintf('Converting to latlongs...\n')
    [lon,lat]=OS.catCoordinates(lon,lat);
end

%% Allocate space for output
N=length(lon);
conversionFactor=NaN(N,1);
uncertainty=NaN(N,1);
dists=NaN(N,1);

%% Vorf resolution = 0.008 degrees. If you request a point within Vorf domain, there should be a valid point within
minDist=sqrt(2*0.008^2)/2;
% If there's not, we'll issue a warning

%% filter vorfCD2ODN to speed things up a bit
minx=min(lon)-minDist;
maxx=max(lon)+minDist;
miny=min(lat)-minDist;
maxy=max(lat)+minDist;
% Define polygon covering range of input values:
pgx=[minx,minx,maxx,maxx];
pgy=[miny,maxy,maxy,miny];
% Which VORF points are within our grid of interest?
k=inpolygon(vorfCD2ODN(:,2),vorfCD2ODN(:,1),pgx,pgy);
% Only keep those within polygon
vorfCD2ODN=vorfCD2ODN(k,:);
if isempty(vorfCD2ODN)
    error('No VORF data near your point(s)')
end

%% Loop though points:
for i=1:N
    x=lon(i);
    y=lat(i);
    if ~isnan(x) && ~isnan(y)
        % find distance from point to every vorf points
        % (Don't bother with square root as we're interested in rank order)
        dist=sqrt((x-vorfCD2ODN(:,2)).^2+(y-vorfCD2ODN(:,1)).^2);    % (Note that VORF files store data as 'lat,lon')
        if dist>minDist
            warning('No nearby VORF point found for %f, %f',x,y)
        end
        index=dist==min(dist); % Find minimum distance
        % Use offset at nearest VORF point. We could be a bit fancier and do
        % some interpolation using a few nearest neighbours, but effect on
        % result likely to be much smaller than reported uncertainty. So
        % don't bother.
        val=vorfCD2ODN(index,3); % extract conversion factor (column 3)
        err=vorfCD2ODN(index,4); % and error
        if length(val)>1 % if we were equidistant between points, we'll have multiple values
            val=mean(val); % just take the average
            err=mean(err);
        end
        % store these in our array
        conversionFactor(i)=val;
        uncertainty(i)=err;
        dists(i)=min(dist);
    end
end

%% Make sure outputs same size as inputs
conversionFactor=reshape(conversionFactor,xsize);
uncertainty=reshape(uncertainty,xsize);
dists=reshape(dists,xsize);

end
