SELECT DISTINCT ON (l2."LocationId") p."Nickname",
    l2."LocationId",
    l2."UserId",
    l2."AccuracyRadius",
    ST_AsGeoJSON(l2."Point") as Point,
    l2."DateLogged",
    ST_AsGeoJSON(l2."LocationCircle") as LocationCircle
   FROM location."LoggedLocations" l1,
    location."LoggedLocations" l2,
    profile."Profile" p
  WHERE l1."LocationId" <> l2."LocationId"
        AND st_dwithin(	ST_GeomFromText('POINT('|| $1 ||' '|| $2 || ')', 4326), 
			l2."Point", 
			350::double precision)
        AND p."UserId" = l2."UserId"
  ORDER BY l2."LocationId", st_distance(l1."Point", l2."Point");
