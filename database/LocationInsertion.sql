--Get points from http://www.gps-coordinates.net/

INSERT INTO location."LoggedLocations"("UserId", "AccuracyRadius", "Point", "DateLogged") 
	VALUES 
	((select p."UserId" from profile."Profile" p WHERE p."Nickname" = 'Rocky'), 
		12, 
		ST_GeomFromText('POINT( -113.565723 53.515238)', 4326), 
		now()
	);

SELECT l.*, p."Nickname"
FROM location."LoggedLocations" l, 
profile."Profile" p
WHERE p."UserId" = l."UserId";


select p."UserId", p."Nickname" from profile."Profile" p;
(select p."UserId" from profile."Profile" p WHERE p."Nickname" = 'Boris');

delete from location."LoggedLocations"  where "UserId" = 6;