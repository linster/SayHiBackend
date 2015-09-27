SELECT 
   rc."CategoryName",
   avg(r."Stars") AS "AverageRating"
   FROM profile."Ratings" r,
   profile."RatingCategories" rc,
   profile."Users" u1,
   profile."Users" u2
WHERE --$1 is r.userid and r.ratingwho = $2, another user id.
   u1."profileid" = $1 AND u2."profileid" = $2 AND
   r."UserId" = u1."Id" AND r."RatingWho" = u2."Id"
   AND r."CategoryId" = rc."Id"
   GROUP BY rc."CategoryName";

