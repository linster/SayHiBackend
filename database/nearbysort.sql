-- DROP VIEW location."Nearby";

--Given a user, get all the users "nearby"

--Nearby: 5km away. If <10 users match that, then just get everyone in order of proximity

 SELECT "LoggedLocations"."LocationId",
    "LoggedLocations"."UserId",
    "LoggedLocations"."AccuracyRadius",
    "LoggedLocations"."Point",
    "LoggedLocations"."DateLogged",
    "Profile"."ProfileId",
    "Profile"."BusinessCardId",
    "Profile"."Chattiness",
    "Profile"."ConversationTopics"
   FROM location."LoggedLocations",
    profile."Users",
    profile."Profile"
  WHERE "LoggedLocations"."UserId" = "Users"."Id" AND "Users"."Id" = "Profile"."UserId";


--First working version of the query.
SELECT DISTINCT ON (l2."LocationId") p."Nickname", l2.*
FROM
location."LoggedLocations" l1,
location."LoggedLocations" l2,
profile."Profile" p
WHERE 
	l1."LocationId" = 5
	AND l1."LocationId" <> l2."LocationId"
	AND ST_DWithin(l1."Point", l2."Point", 750) --Must be 750 meters or closer together to get returned.
	AND p."UserId" = l2."UserId"
ORDER BY l2."LocationId", ST_Distance(l1."Point", l2."Point")	
--Also, limit date.
