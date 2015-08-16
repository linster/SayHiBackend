

 --Create a user
 INSERT INTO profile."Users"("oAuthId", "Created") VALUES (null, current_timestamp);
 --Create a profile for the user
 INSERT INTO 
	profile."Profile"("UserId", "Chattiness", "ConversationTopics", "Nickname") 
 VALUES
	( (SELECT MAX("Id") FROM profile."Users"), 10, 
	'{"Computers", "Technology", "Otherthing"}', 'Vaclav');

 select * from profile."Users";
 select * from profile."Profile";


--Working on this.
 CREATE OR REPLACE FUNCTION newTestUser(username character, 
					chattiness smallint, 
					nickname character
					) AS
 $BODY$
 DECLARE
	--thing
 BEGIN
	
 END
 $BODY$
 LANGUAGE 'plpgsql';