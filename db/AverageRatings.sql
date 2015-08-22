SELECT 
   rc."CategoryName",
   avg(r."Stars") AS "AverageRating"
   FROM profile."Ratings" r,
   profile."RatingCategories" rc
WHERE r."UserId" = $1 AND r."RatingWho" = $2 
   AND r."CategoryId" = rc."Id"
   GROUP BY rc."CategoryName";

