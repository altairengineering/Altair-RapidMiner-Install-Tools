CREATE TABLE DOCUMENT_TEMPLATE(
   ID INTEGER NOT NULL,
   NAME TEXT,
   SHORT_DESCRIPTION TEXT,
   AUTHOR TEXT,
   DESCRIPTION TEXT,
   CONTENT TEXT,
   LAST_UPDATED DATE,
   CREATED DATE
);

INSERT INTO DOCUMENT_TEMPLATE(id, name, short_description, author,
                              description, content, last_updated, created)
WITH base(id, n1,n2,n3,n4,n5,n6,n7) AS
(
  SELECT id
        ,MIN(CASE WHEN rn = 1 THEN nr END)
        ,MIN(CASE WHEN rn = 2 THEN nr END)
        ,MIN(CASE WHEN rn = 3 THEN nr END)
        ,MIN(CASE WHEN rn = 4 THEN nr END)
        ,MIN(CASE WHEN rn = 5 THEN nr END)
        ,MIN(CASE WHEN rn = 6 THEN nr END)
        ,MIN(CASE WHEN rn = 7 THEN nr END)
  FROM generate_series(1,100000) id     -- number of rows
  ,LATERAL( SELECT nr, ROW_NUMBER() OVER (ORDER BY id * random())
             FROM generate_series(1,900) nr
          ) sub(nr, rn)
   GROUP BY id
), dict(lorem_ipsum, names) AS
(
   SELECT 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris lacus arcu, blandit non semper elementum, fringilla sodales est. Ut porttitor blandit sapien pellentesque pretium. Donec ut diam sed urna venenatis hendrerit. Nulla eros arcu, mattis vitae congue cursus, tincidunt sed turpis. Curabitur non enim diam, eget elementum dolor. Vivamus enim tortor, tempor at vehicula ac, malesuada id est. Praesent at nibh eget metus dapibus dapibus. Donec arcu orci, sagittis eu interdum vitae, facilisis quis nibh.
Mauris luctus molestie velit, at vestibulum magna cursus sit amet. Nulla in accumsan libero. Donec sed sem lectus. Mauris congue sapien et diam euismod vitae scelerisque diam tincidunt. Praesent a justo enim, vitae venenatis dolor. Donec in tortor at magna dapibus suscipit sit amet a libero. Vivamus porttitor rhoncus tellus, at luctus nisl semper bibendum. Fusce eget accumsan orci. Qout'
         ,'{"James","John","Jimmy","Jessica","Jeffrey","Jonathan","Justin","Jaclyn","Jodie"}'::text[]
)
SELECT b.id, sub.*
FROM base b
,LATERAL (
     SELECT names[b.n1 % 9+1]
           ,substring(lorem_ipsum::text, b.n2, 20)
           ,names[b.n3 % 9+1]
           ,substring(lorem_ipsum::text, b.n4, 100)
           ,substring(lorem_ipsum::text, b.n5, 200)
           ,NOW() - '1 day'::INTERVAL * (b.n6 % 365)
           ,(NOW() - '1 day'::INTERVAL * (b.n7 % 365)) - '1 year' :: INTERVAL
      FROM dict
) AS sub(name,short_description, author,description,content, last_updated, created);
