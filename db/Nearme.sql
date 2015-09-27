SELECT DISTINCT ON (l2."LocationId") p."Nickname",
    l2."LocationId",
    l2."UserId",
    l2."AccuracyRadius",
    ST_AsGeoJSON(l2."Point") as Point,
    l2."DateLogged",
    ST_AsGeoJSON(l2."LocationCircle") as LocationCircle,
    p.*
   FROM location."LoggedLocations" l1,
    location."LoggedLocations" l2,
    profile."Profile" p,
    profile."Users" u
  WHERE l1."LocationId" <> l2."LocationId"
	/* $1 = lon, $2 = lat. In that order */
        AND st_dwithin( ST_GeomFromText('POINT('|| $1 ||' '|| $2 || ')', 4326),
                        l2."Point",
                        350::double precision)
        AND u."Id" = l2."UserId"
        AND u."profileid" = p."profileid"
  ORDER BY l2."LocationId", st_distance(l1."Point", l2."Point");
