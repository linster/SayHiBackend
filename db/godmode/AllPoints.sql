SELECT DISTINCT ON (l2."LocationId") p."Nickname",
    l2."LocationId",
    l2."UserId",
    l2."AccuracyRadius",
    ST_AsGeoJSON(l2."Point") as Point,
    l2."DateLogged",
    ST_AsGeoJSON(l2."LocationCircle") as LocationCircle
   FROM
    location."LoggedLocations" l2,
    profile."Profile" p,
    profile."Users" u
  WHERE u."Id" = l2."UserId" AND p."profileid" = u."profileid"
