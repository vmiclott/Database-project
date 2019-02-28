select email as writeremail, article.starttime as articlestarttime
from article_fieldtrip
inner join article using(articleid)
inner join fieldtrip using(fieldtripid)
inner join article as article2 using(personid)
inner join article_fieldtrip as article_fieldtrip2 on(article2.articleid=article_fieldtrip2.articleid)
inner join fieldtrip as fieldtrip2 on(article_fieldtrip2.fieldtripid=fieldtrip2.fieldtripid)
inner join person using(personid)
where (fieldtrip2.fieldtripfrom>fieldtrip.fieldtripfrom and fieldtrip2.fieldtripfrom<fieldtrip.fieldtripto) or (fieldtrip.fieldtripfrom>fieldtrip2.fieldtripfrom and fieldtrip.fieldtripfrom<fieldtrip2.fieldtripto)