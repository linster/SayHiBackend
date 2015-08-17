--Get points from http://www.gps-coordinates.net/

INSERT INTO location."LoggedLocations"("UserId", "AccuracyRadius", "Point", "DateLogged") 
	VALUES 
	((select p."UserId" from profile."Profile" p WHERE p."Nickname" = 'Josh'), 
		12, 
		ST_GeomFromText('POINT( -113.593888 53.520427)', 4326), 
		now()
	);

SELECT p."Nickname", l."DateLogged",  l.*
FROM location."LoggedLocations" l, 
profile."Profile" p
WHERE p."UserId" = l."UserId";


select p."UserId", p."Nickname" from profile."Profile" p;
(select p."UserId" from profile."Profile" p WHERE p."Nickname" = 'Boris');

delete from location."LoggedLocations"  where "UserId" = 5;