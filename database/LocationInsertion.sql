--Get points from http://www.gps-coordinates.net/

insert into location."LoggedLocations"("UserId", "AccuracyRadius", "Point", "DateLogged") 
VALUES (1, 12, ST_GeomFromText('POINT(-113.593883 53.522043)', 4326), now());

select * from location."LoggedLocations";